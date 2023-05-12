import Foundation

class APIService {
    
    static let shared = APIService()
    
    func fetchHotkeys() async -> [[String]] {
        let urlString = "http://212.152.40.222:50401/api/getFrequentTransactions"
        guard let url = URL(string: urlString) else { return [[]] }
        
        // Sending GET request
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let resData = try JSONDecoder().decode([[String]].self, from: data)
            return resData
        }
        catch {
            print("error")
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
            print("error")
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
            print(error)
            return [Transaction]()
        }
    }
    
    func fetchCurrency () async -> Rates {
        let urlString = "https://economia.awesomeapi.com.br/last/USD-RUB,USD-KGS"
        guard let url = URL(string: urlString) else { return Rates(KGS: 0, RUB: 0) }
        
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
            
            return Rates(KGS: Double(curKGS) ?? 0, RUB: Double(curRUB) ?? 0 )
        }
        catch {
            print("error: \(error)")
            return Rates(KGS: 0, RUB: 0)
        }
    }
    
    // POST-request to get charts' data
    func fetchChartsData (month: String, year: String) async -> APIChartsResponse {
        guard let url = URL(string: "http://212.152.40.222:50401/api/chartDataSwiftUI") else { return APIChartsResponse(barChartDatalist: ComparationList(monthly: [BarChartDatalist](), yearly: [BarChartDatalist]()), barChartData: ComparationChart(monthly: [BarChartData](), yearly: [BarChartData]()))}
        
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
            print(error)
            return APIChartsResponse(barChartDatalist: ComparationList(monthly: [BarChartDatalist](), yearly: [BarChartDatalist]()), barChartData: ComparationChart(monthly: [BarChartData](), yearly: [BarChartData]()))
        }
    }
    
    
}
