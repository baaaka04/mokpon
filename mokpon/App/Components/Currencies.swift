import SwiftUI

struct Currencies: View {
    
    var fetchCurrencyRates : @MainActor() -> Void
    var RUBKGS : Double?
    var USDKGS : Double?
    
    var body: some View {
        HStack {
            if let RUBKGS, let USDKGS {
                Text("USD/RUB \(USDKGS / RUBKGS, specifier: "%.2f")  RUB/KGS \(RUBKGS, specifier: "%.2f")")
                Spacer()
            } else {
                ProgressView("Loading currencies...")
            }
        }
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
