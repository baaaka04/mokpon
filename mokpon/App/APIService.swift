import Foundation

class APIService {
    
    static let shared = APIService()
    
    func fetchHotkeys() async -> [[String]] {
        guard let url = URL(string: "http://212.152.40.222:50401/api/getFrequentTransactions") else { return [[]] }
        
        // Sending GET request
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let resData = try JSONDecoder().decode([[String]].self, from: data)
            return resData
        }
        catch {
            print("Fetching hotkeys error: \(error)")
            return [[]]
        }
    }
    //     GET Request /transactions route
    func fetchTransactions () async -> [Transaction] {
        guard let url = URL(string: "http://212.152.40.222:50401/api/transactions?limit=\(20)") else { return [Transaction]()}
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(df)
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let resData = try decoder.decode([Transaction].self, from: data)
            return resData
        }
        catch {
            print("Fetching transactions error: \(error)")
            return [Transaction]()
        }
    }
    //    POST Request /newRow route
    func sendNewTransaction (trans: Transaction) async -> [Transaction] {
        guard let url = URL(string: "http://212.152.40.222:50401/api/newRow") else { return [Transaction]()}
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
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(df)
        // Make the request
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let resData = try decoder.decode([Transaction].self, from: data)
            return resData
        }
        catch {
            print("Sending transaction error: \(error)")
            return [Transaction]()
        }
    }
    
    func fetchCurrency () async -> Rates {
        guard let url = URL(string: "https://economia.awesomeapi.com.br/last/USD-RUB,USD-KGS") else { return Rates(KGS: 90, RUB: 120) }
        
        // Setting HTTP-Request Headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let API_KEY = "eRYOrzPViD1ZMYvcXpYIdpLi2UtBVhoC"
        request.setValue(API_KEY, forHTTPHeaderField: "apikey")
        // Sending GET request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            //            print(String(data: data, encoding: .utf8))
            
            let curKGS : String = try JSONDecoder().decode(DTOcur.self, from: data).USDKGS.bid
            let curRUB : String = try JSONDecoder().decode(DTOcur.self, from: data).USDRUB.bid
            
            return Rates(KGS: Double(curKGS) ?? 20.0, RUB: Double(curRUB) ?? 20.0 )
        }
        catch {
            print("Fetching currnecies error: \(error)")
            return Rates(KGS: 100, RUB: 80)
        }
    }
    
    // POST-request to get charts' data
    func fetchChartsData (month: String, year: String) async -> APIChartsResponse {
        guard let url = URL(string: "http://212.152.40.222:50401/api/chartDataSwiftUI") else { return APIChartsResponse(chartDatalist: ComparationList(monthly: [ChartDatalist](), yearly: [ChartDatalist]()), chartData: ComparationChart(monthly: [ChartData](), yearly: [ChartData]()))}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DTScharts(month: month, year: year))
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let resData = try JSONDecoder().decode(APIChartsResponse.self, from: data)
            return resData
        }
        catch {
            print("Fetching charts data error: \(error)")
            return APIChartsResponse(chartDatalist: ComparationList(monthly: [ChartDatalist](), yearly: [ChartDatalist]()), chartData: ComparationChart(monthly: [ChartData](), yearly: [ChartData]()))
        }
    }
    //GET-request subcategory expenses
    func fetchCategoryExpenses (category: String, date: ChartsDate) async -> [ChartDatalist] {
    
        let urlString = "http://212.152.40.222:50401/api/category_expenses?category=\(category)&month=\(date.month)&year=\(date.year)"
        guard let url = URL(string: urlString.encodeUrl)
        else { return [ChartDatalist]() }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let resData = try JSONDecoder().decode([ChartDatalist].self, from: data)
            return resData
        }
        catch {
            print("Fetching transactions error: \(error)")
            return [ChartDatalist]()
        }
    }
    
}
