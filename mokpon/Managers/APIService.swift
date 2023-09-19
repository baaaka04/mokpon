import Foundation

final class APIService {
    
    static let shared = APIService()
        
    init () {}
    
    func fetchCurrencyRates () async -> Rates? {
        guard let url = URL(string: "https://economia.awesomeapi.com.br/last/USD-RUB,USD-KGS") else { return nil }
        
        // Setting HTTP-Request Headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let API_KEY = "eRYOrzPViD1ZMYvcXpYIdpLi2UtBVhoC"
        request.setValue(API_KEY, forHTTPHeaderField: "apikey")
        // Sending GET request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let curKGS : String = try JSONDecoder().decode(DTOcur.self, from: data).USDKGS.bid
            let curRUB : String = try JSONDecoder().decode(DTOcur.self, from: data).USDRUB.bid
            
            return Rates(KGS: Double(curKGS) ?? 0, RUB: Double(curRUB) ?? 0 )
        }
        catch {
            print("Fetching currnecies error: \(error)")
            return nil
        }
    }
    
    
}
