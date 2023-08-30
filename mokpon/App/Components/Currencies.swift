import SwiftUI

struct Currencies: View {
    
    var fetchCurrencyRates : @MainActor() -> Void
    var usdrub : Double?
    var usdkgs : Double?
    
    var body: some View {
        HStack {
            if let usdrub, let usdkgs {
                Text("USD/RUB \(usdrub, specifier: "%.2f")  RUB/KGS \(usdkgs/usdrub, specifier: "%.2f")")
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
        Currencies(fetchCurrencyRates: {}, usdrub: 75.23, usdkgs: 88.52)
    }
}
