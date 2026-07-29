import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class HomeViewModel: ObservableObject, TransactionSendable {

    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var currencyRates: Rates? = nil
    @Published var amounts: [Amount]? = nil
    @Published var hotkeys: [Hotkey] = []
    // Since the transaction's ID is generated on FireBase,
    // And we want to avoid unnecessary UI re-render,
    // We need a place to store IDs and be able to use it whenever needed.
    private var transactionIdMap: [String: String] = [:] // [tempId: realId]

    //Search bar
    @Published var searchtext: String = ""
    @Published var selectedScope: CategoryEnum?
    var searchScopes: [CategoryEnum] = CategoryEnum.allCases

    //Pagination
    private var cancellable = Set<AnyCancellable>()
    var isLoading: Bool = false
    private var isHotkeyLoading: Bool = false
    private var lastDocument: DocumentSnapshot? = nil

    //Managers
    private(set) var currencyRatesService: CurrencyManager
    private(set) var transactionManager: TransactionManager
    private(set) var authManager: AuthenticationManager
            
    init(appContext: AppContext) {
        self.currencyRatesService = appContext.currencyRatesService
        self.transactionManager = appContext.transactionManager
        self.authManager = appContext.authManager
        addSubscribers()
        print("\(Date()): INIT HomeViewModel")
    }
    deinit {print("\(Date()): DEINIT HomeViewModel")}
        
    private func addSubscribers() {
        $searchtext
            .debounce(for: 1.0, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateTransactions()
            }
            .store(in: &cancellable)
        $selectedScope
            .sink { [weak self] _ in
                self?.updateTransactions()
            }
            .store(in: &cancellable)
    }

    // GET Request from Firebase DB
    func getTransactions() {
        print("getTransactions()")
        guard !isLoading else {
            print("Already loading...")
            return
        }
        self.isLoading = true
        Task {
            let user = try authManager.getAuthenticatedUser()
            let (DBTransactions, lastDocument) = await transactionManager.getLastNTransactions(
                limit: 20,
                userId: user.uid,
                lastDocument: self.lastDocument,
                searchText: searchtext.lowercased(),
                selectedCategoryId: selectedScope?.id
            )
            self.lastDocument = lastDocument
            let newTransactions = DBTransactions.compactMap {
                if let category = CategoryEnum(rawValue: $0.categoryId) {
                    return Transaction(DBTransaction: $0, category: category , currency: $0.currencyId)
                } else { return nil } // if couldn't find a category/currency, then skip
            }
            if !self.filteredTransactions.isEmpty {
                // append for pagination
                self.filteredTransactions.append(contentsOf: newTransactions)
            } else {
                self.filteredTransactions = newTransactions
            }
            
            print("\(Date()): HomeViewModel - New transactions have been loaded!")
            self.isLoading = false
        }
    }
    
    func getHomeTransactions() {
        print("getHomeTransactions()")
        Task {
            let user = try authManager.getAuthenticatedUser()
            let (DBTransactions, _) = await transactionManager.getLastNTransactions(
                limit: 5,
                userId: user.uid
            )
            let newTransactions = DBTransactions.compactMap {
                if let category = CategoryEnum(rawValue: $0.categoryId) {
                    return Transaction(DBTransaction: $0, category: category , currency: $0.currencyId)
                } else { return nil } // if couldn't find a category/currency, then skip
            }
            self.transactions = newTransactions
        }
    }

    func sendNewTransaction(transaction: Transaction) async throws {
        // Update local transactions and amounts
        if !self.transactions.isEmpty {
            self.transactions.insert(transaction, at: 0)
        } else {
            self.transactions = [transaction]
        }
        try localAmountUpdate(curId: transaction.currency, sumDiff: transaction.sum)

        let user = try authManager.getAuthenticatedUser()
        let deviceTransactionId = transaction.id
        do {
            // Use atomic operation to create transaction and update amounts together
            let newTransactionId = try await transactionManager.createTransactionWithAmountUpdate(transaction: transaction, userId: user.uid)
            
            // Get the new transaction ID from FireBase and update the device transaction's ID
            transactionIdMap[deviceTransactionId] = newTransactionId
            print("\(Date()): Transaction has been sent")
        } catch {
            // Rollback both UI changes on failure
            if let index = self.transactions.firstIndex(where: { $0.id == deviceTransactionId }) {
                self.transactions.remove(at: index)
            }
            try? localAmountUpdate(curId: transaction.currency, sumDiff: -transaction.sum)
            print(error)
            throw error
        }
    }

    func updateTransactions() {
        self.filteredTransactions = []
        self.lastDocument = nil
        getTransactions()
    }

    func deleteTransaction(transaction: Transaction) async throws {
        // Update locally
        self.transactions.remove(object: transaction)
        try localAmountUpdate(curId: transaction.currency, sumDiff: -transaction.sum)
        do {
            // Update backend
            let userId = try authManager.getAuthenticatedUser().uid
            var trans = transaction
            trans.id = transactionIdMap[trans.id] ?? trans.id // Find and use the real backend ID
            try await transactionManager.deleteTransactionWithAmountUpdate(transaction: trans, userId: userId)
            if self.transactions.count < 5 { // 5 is the limit for HomeView
                getTransactions()
            }
        } catch {
            // Restore transactions and amounts
            self.transactions.insert(transaction, at: 0)
            try? localAmountUpdate(curId: transaction.currency, sumDiff: transaction.sum)
            print(error)
            throw error
        }
    }

    func getUserAmounts() {
        Task {
            let user = try authManager.getAuthenticatedUser()
            do {
                self.amounts = try await transactionManager.getUserAmounts(userId: user.uid)
            } catch {
                print("\(Date()): HomeViewModel - Error while getting user amounts: \(error)")
            }
            print("\(Date()): HomeViewModel - Amounts have been updated!")
        }
    }

    private func localAmountUpdate(curId: Currency, sumDiff: Int) throws {
        guard let current = self.amounts else { throw AppError.noDataToPresent }
        self.amounts = current.map { amount in
            if amount.curId == curId {
                return Amount(curId: amount.curId, sum: amount.sum + sumDiff)
            }
            return amount
        }
    }

    func fetchCurrencyRates() -> Void {
        Task {
            let fetchedData = await currencyRatesService.fetchCurrencyRates()
            self.currencyRates = fetchedData
        }
    }

    func getHotkeys() -> Void {
        guard !isHotkeyLoading else {
            print("\(Date()): HomeViewModel - getHotkeys is already running")
            return
        }
        isHotkeyLoading = true
        defer { isHotkeyLoading = false }
        print("\(Date()): HomeViewModel - getHotkeys")
        Task {
            do {
                guard hotkeys.isEmpty else { throw AppError.noNeedToExecute }

                let user = try authManager.getAuthenticatedUser()
                let (FBTransactions, _) = await transactionManager.getLastNTransactions(limit: 300, userId: user.uid)
                let DBHotkeys = Dictionary(grouping: FBTransactions, by: {DBHotkey(categoryId: $0.categoryId, subcategory: $0.subcategory, count: 0)})
                    .map { (key, arr) in DBHotkey(categoryId: key.categoryId, subcategory: key.subcategory, count: arr.count) }
                    .sorted { $0.count > $1.count }

                self.hotkeys = DBHotkeys
                    .prefix(16)
                    .compactMap {
                        if let category = CategoryEnum(rawValue: $0.categoryId) {
                            return Hotkey(category: category, subcategory: $0.subcategory)
                        } else { return nil } //if couldn't find a category, then skip
                    }
            } catch {
                print(error)
            }
        }

    }

}

