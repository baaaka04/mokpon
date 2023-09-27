import Foundation

final class CurrencyManager {
    
    var rates : Rates? = nil
        
    init (completion: @escaping () -> Void) {
        Task {
            self.rates = await fetchCurrencyRates()
            completion() //a completion handler to access methods of the class after 'async' init
        }
        print("\(Date()): INIT CurrencyManager")
    }
    deinit {print("\(Date()): DEINIT CurrencyManager")}
    
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
    
    func convertCurrency (value: Int, from: String?, to: String?) -> Int? {
        
        guard let rates, let from, let to else {return nil}
        let rateInd : [String : Double] = [
            "USDRUB" : rates.RUB,
            "USDKGS" : rates.KGS,
            "RUBUSD" : 1 / rates.RUB,
            "RUBKGS" : rates.KGS / rates.RUB,
            "KGSUSD" : 1 / rates.KGS,
            "KGSRUB" : rates.RUB / rates.KGS,
            "RUBRUB" : 1,
            "USDUSD" : 1,
            "KGSKGS" : 1
        ]
        
        return Int( Double(value) * (rateInd[from+to] ?? 0) )
    }
    
    
}
