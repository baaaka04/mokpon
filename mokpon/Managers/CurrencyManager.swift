import Foundation

final class CurrencyManager {
    
    var rates : Rates? = nil
        
    init () {
        print("\(Date()): INIT CurrencyManager")
        Task {
            self.rates = await fetchCurrencyRates()
        }
    }
    deinit {print("\(Date()): DEINIT CurrencyManager")}
    
    func fetchCurrencyRates () async -> Rates? {
        guard let url = URL(string: "https://data.fx.kg/api/v1/central") else { return nil }

        // Setting HTTP-Request Headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let token = "d7NngAgtkHJw3qSJrWNP3ShAMgsToReKqOsEGYcueb6dafae"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // Sending GET request
        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            let RUBKGS : String = try JSONDecoder().decode(DTOcur.self, from: data).rub
            let USDKGS : String = try JSONDecoder().decode(DTOcur.self, from: data).usd
            let EURKGS : String = try JSONDecoder().decode(DTOcur.self, from: data).eur

            return Rates(
                RUBKGS: Double(RUBKGS) ?? 0,
                USDKGS: Double(USDKGS) ?? 0,
                EURKGS: Double(EURKGS) ?? 0
            )
        }
        catch {
            print("Fetching currnecies error: \(error)")
            return nil
        }
    }
    
    func convertCurrency (value: Int, from: String?, to: String?) -> Int? {
        
        guard let rates, let from, let to else {return nil}
        let rateInd : [String : Double] = [
            "USDRUB" : rates.USDKGS / rates.RUBKGS,
            "USDKGS" : rates.USDKGS,
            "RUBUSD" : rates.RUBKGS / rates.USDKGS,
            "RUBKGS" : rates.RUBKGS,
            "KGSUSD" : 1 / rates.USDKGS,
            "KGSRUB" : 1 / rates.RUBKGS,
            "RUBRUB" : 1,
            "USDUSD" : 1,
            "KGSKGS" : 1
        ]
        
        return Int( Double(value) * (rateInd[from+to] ?? 0) )
    }
    
    
}
