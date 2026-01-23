import SwiftUI

enum Route {
    case home
    case charts
    case settings
}

struct Tab : Identifiable{
    let id: Int
    let title: String
    let icon: String
    let route: Route
    let color: Color
}

extension Tab {
    static let home = Tab(id: 0, title: "Home", icon: "house.fill", route: .home, color: .yellow)
    static let charts = Tab(id: 1, title: "Chart", icon: "chart.pie.fill", route: .charts, color: Color( #colorLiteral(red: 0.4211916924, green: 0.9798443913, blue: 0.03175599501, alpha: 1)))
    static let settings = Tab(id: 2, title: "Settings", icon: "gearshape.fill", route: .settings, color: .orange)
}
