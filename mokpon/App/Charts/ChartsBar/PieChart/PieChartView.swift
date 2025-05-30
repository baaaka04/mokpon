import SwiftUI

struct PieChartView: View {

    private let values: [Double]
    private var colors: [Color]
    private let names: [String]

    init(chartData: [ChartData]) {
        self.values = chartData.map{ Double($0.sum) }
        self.colors = Color.palette
        self.names = chartData.map{ $0.category.name }
    }

    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []

        for (i, value) in values.enumerated() {
            let percent : Double = value * 100 / sum
            let degrees: Double = value * 360 / sum
            tempSlices.append(
                PieSliceData(
                    startAngle: Angle(degrees: endDeg),
                    endAngle: Angle(degrees: endDeg + degrees),
                    text: String(self.names[safe: i] ?? "n/a"),
                    color: self.colors[safe: i] ?? .black.opacity(0.5),
                    percent: percent
                )
            )
            endDeg += degrees
        }
        return tempSlices
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ForEach(0..<self.values.count, id: \.self){ i in
                    PieSliceView(pieSliceData: self.slices[i])
                }
                .frame(width: geometry.size.width, height: geometry.size.width)

                Circle()
                    .fill(Color.gray)
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)

                VStack {
                    Text("Total")
                        .font(.title)
                        .foregroundColor(Color.yellow)
                    Text("\(Int(values.reduce(0, +)))")
                        .font(.title)
                }
            }
            .background(.white.opacity(0))
        }
    }
}


struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(chartData: [])
    }
}
