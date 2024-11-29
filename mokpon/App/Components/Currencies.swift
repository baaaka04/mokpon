import SwiftUI

struct Currencies: View {
    
    var fetchCurrencyRates : @MainActor() -> Void
    var RUBKGS : Double?
    var USDKGS : Double?
    var EURKGS : Double?

    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            if let RUBKGS, let USDKGS, let EURKGS {
                let usdrub = "USD/RUB \(String(format: "%.2f", USDKGS / RUBKGS))  "
                let rubkgs = "RUB/KGS \(String(format: "%.2f", RUBKGS))  "
                let eurrub = "EUR/RUB \(String(format: "%.2f", EURKGS / RUBKGS))"
                Text(usdrub + rubkgs + eurrub)
            } else {
                ProgressView("Loading currencies...")
            }
        }
        .frame(height: 30)
        .task {
            fetchCurrencyRates()
        }
    }
}

struct Currencies_Previews: PreviewProvider {
    static var previews: some View {
        Currencies(fetchCurrencyRates: {}, RUBKGS: 75.23, USDKGS: 88.52)
    }
}
