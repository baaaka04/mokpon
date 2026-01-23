import SwiftUI

struct ChartSkeletonView: View {

    @State private var shimmerOpacity: Double = 0.4

    var body: some View {
        VStack {
            Image(systemName: "chart.pie.fill")
                .resizable()
                .frame(maxWidth: 150, maxHeight: 150)
                .foregroundStyle(.gray)
                .overlay(
                    animatedGradient
                        .mask(
                            Image(systemName: "chart.pie.fill")
                                .resizable()
                                .frame(maxWidth: 150, maxHeight: 150)
                        )
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        shimmerOpacity = 1.0
                    }
                }
        }
    }

    var animatedGradient: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(shimmerOpacity),
                Color.clear
            ]),
            center: .center,
            startRadius: 10,
            endRadius: 100
        )
    }
}


#Preview {
    ChartSkeletonView()
}
