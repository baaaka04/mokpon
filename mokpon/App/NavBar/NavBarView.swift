import SwiftUI

struct NavBarView: View {
    
    @Binding var currentRoute: Route
    @State var color: Color = Tab.home.color

    let tabItems : [Tab] = [Tab.home, Tab.charts, Tab.settings]
    let size: CGSize
    
    var body: some View {
        HStack {
            
            ForEach(tabItems) { item in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentRoute = item.route
                        color = item.color
                    }
                } label: {
                    VStack (spacing: 0) {
                        Image(systemName: item.icon)
                            .imageScale(.large)
                        Text(item.title)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .foregroundColor(currentRoute == item.route ? item.color : .gray)
                .blendMode(currentRoute == item.route ? .overlay : .normal)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 14)
        .frame(height: size.height/10, alignment: .top)
        .background(Color.bg_main.opacity(0.6))
        .background(.ultraThinMaterial)
        .background(
            HStack{
                if currentRoute == .settings { Spacer() }
                Circle().fill(color).frame(width: size.width/5)
                if currentRoute == .home { Spacer() }
            }
                .padding(.horizontal, 30)
        )
        .overlay(
            HStack{
                if currentRoute == .settings { Spacer() }
                Rectangle()
                    .fill(color)
                    .frame(width: size.width/12, height: size.height/120)
                    .cornerRadius(3)
                    .frame(width: size.width/5.5)
                    .frame(maxHeight: .infinity, alignment: .top)
                if currentRoute == .home { Spacer() }
            }
                .padding(.horizontal, 30)
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            NavBarView(currentRoute: .constant(.home), size: geo.size)
        }
    }
}

