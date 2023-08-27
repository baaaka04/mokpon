import SwiftUI

struct Currencies: View {
    
    var fetchCurrencyRates : () async -> Void
    var usdrub : Double
    var usdkgs : Double
    
    var body: some View {
        HStack {
            Text("USD/RUB \(usdrub, specifier: "%.2f")  RUB/KGS \(usdkgs/usdrub, specifier: "%.2f")")
            Spacer()
        }
        .task {
            await fetchCurrencyRates()
        }
    }
}

struct Currencies_Previews: PreviewProvider {
    static var previews: some View {
        Currencies(fetchCurrencyRates: {() async -> Void in return}, usdrub: 75.23, usdkgs: 88.52)
    }
}
