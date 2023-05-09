import Foundation


class HomeViewModel : ObservableObject {
    
    @Published var transactions = [Transaction]()
    @Published var currencies = Rates(KGS: 85.1, RUB: 75.1)
    var isLoading : Bool = false

    
    func loadMore () async -> Void {
        isLoading = true
        // wait code
        isLoading = false
    }
//     GET Request /transactions route
    func fetchTransactions () -> Void {
        
        guard let url = URL(string: "http://212.152.40.222:50401/api/transactions") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let resData = data,
                error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300
            else {
                print("Error downloading")
                return
            }
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(df)
//            print(String(decoding: resData, as: UTF8.self))
            guard
                let jsonDecoded : [Transaction] = try? decoder.decode(
                    [Transaction].self,
                    from: resData
                )
            else {
                print("Decoder error")
                return
            }
            print("transactions were downloaded")
            DispatchQueue.main.async {
                self.isLoading = false
                self.transactions = jsonDecoded
            }
        }.resume()
    }
    
//    POST Request /newRow route
    func sendNewTransaction (trans: Transaction) -> Void {
        guard let url = URL(string: "http://212.152.40.222:50401/api/newRow") else { return }
        var urlRequest = URLRequest(url: url)
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateToJSON = df.string(from: trans.date)
                
        let transToJSON = TransactionToJSON(
            category: trans.category,
            subCategory: trans.subCategory,
            opex: trans.type,
            date: dateToJSON,
            sum: String(trans.sum)
        )
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try? JSONEncoder().encode(transToJSON)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Make the request
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil,
                  let resData = data
            else {
                print("error calling POST on /newRow/")
                print(error!)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(df)

            guard
                let jsonDecoded : [Transaction] = try? decoder.decode(
                    [Transaction].self,
                    from: resData
                )
            else {
                print("Decoder error")
                return
            }

            DispatchQueue.main.async {
                self.transactions = jsonDecoded
            }
        }
        task.resume()
    }
    
    func fetchCurrency () async -> Void {
//        let urlString = "https://api.apilayer.com/exchangerates_data/latest?base=USD&symbols=KGS,RUB"
        let urlString = "https://economia.awesomeapi.com.br/last/USD-RUB,USD-KGS"
        guard let url = URL(string: urlString) else { return  }
        
        // Setting HTTP-Request Headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let API_KEY = "eRYOrzPViD1ZMYvcXpYIdpLi2UtBVhoC"
        request.setValue(API_KEY, forHTTPHeaderField: "apikey")
        // Sending GET request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print("Currencies data has been recieved!")
//            print(String(data: data, encoding: .utf8))
            
            let curKGS : String = try JSONDecoder().decode(DTOcur.self, from: data).USDKGS.bid
            let curRUB : String = try JSONDecoder().decode(DTOcur.self, from: data).USDRUB.bid
            
            DispatchQueue.main.async {
                self.currencies = Rates(KGS: Double(curKGS) ?? 0, RUB: Double(curRUB) ?? 0 )
            }
        }
        catch {
            print("error: \(error)")
            return
        }
    }
    
}
