import SwiftUI
import DGCharts

struct EmotionChartView: UIViewControllerRepresentable {
    let emotionData: [EmotionData]
    
    func makeUIViewController(context: Context) -> LineChartViewController {
        let viewController = LineChartViewController()
        viewController.emotionData = emotionData
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: LineChartViewController, context: Context) {
        uiViewController.emotionData = emotionData
        uiViewController.updateChart()
    }
}

class LineChartViewController: UIViewController {
    private let chartView = LineChartView()
    var emotionData: [EmotionData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        chartView.frame = view.bounds
    }
    
    private func setupChart() {
        view.addSubview(chartView)
        
        chartView.backgroundColor = .systemBackground
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.animate(xAxisDuration: 0.5)
        
        let leftAxis = chartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor.systemGray5
        leftAxis.labelTextColor = UIColor.label
        
        chartView.xAxis.labelTextColor = UIColor.label
        chartView.xAxis.valueFormatter = DateValueFormatter()
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelRotationAngle = -45
        
        chartView.legend.enabled = true
        chartView.legend.textColor = UIColor.label
        chartView.legend.form = .circle
        
        chartView.pinchZoomEnabled = true
        chartView.doubleTapToZoomEnabled = true
        chartView.scaleXEnabled = true
        chartView.scaleYEnabled = false
        
        updateChart()
    }
    
    func updateChart() {
        guard !emotionData.isEmpty else {
            chartView.data = nil
            return
        }
        
        let entries = emotionData.enumerated().map { index, data in
            ChartDataEntry(x: Double(index), y: Double(data.score))
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: "感情スコア")
        dataSet.colors = [UIColor.systemBlue]
        dataSet.circleColors = emotionData.map { colorForScore($0.score) }
        dataSet.circleRadius = 6
        dataSet.lineWidth = 2
        dataSet.valueTextColor = UIColor.label
        dataSet.valueFont = .systemFont(ofSize: 10)
        dataSet.drawFilledEnabled = true
        
        let gradientColors = [UIColor.systemBlue.withAlphaComponent(0.3).cgColor,
                              UIColor.systemBlue.withAlphaComponent(0.0).cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: gradientColors as CFArray,
                                  locations: nil)!
        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
        
        dataSet.mode = .cubicBezier
        dataSet.cubicIntensity = 0.2
        
        let data = LineChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(formatter: NumberFormatter()))
        
        chartView.data = data
        chartView.notifyDataSetChanged()
    }
    
    private func colorForScore(_ score: Int) -> UIColor {
        switch score {
        case 76...100:
            return .systemGreen
        case 51...75:
            return .systemBlue
        case 21...50:
            return .systemOrange
        case 1...20:
            return .systemRed
        default:
            return .systemGray
        }
    }
}

class DateValueFormatter: NSObject, AxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "MM/dd"
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let calendar = Calendar.current
        let today = Date()
        let daysAgo = Int(value)
        
        if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
            return dateFormatter.string(from: date)
        }
        return ""
    }
}

struct EmotionChartSwiftUIView: View {
    @ObservedObject var dataModel: MascotDataModel
    @State private var selectedPeriod: ChartPeriod = .week
    
    enum ChartPeriod: String, CaseIterable {
        case week = "1週間"
        case month = "1ヶ月"
        case threeMonths = "3ヶ月"
        case all = "全期間"
        
        var days: Int? {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .all: return nil
            }
        }
    }
    
    var filteredData: [EmotionData] {
        let allData = dataModel.mascotRecords.toEmotionData()
        
        guard let days = selectedPeriod.days else {
            return allData
        }
        
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return allData.filter { $0.date >= startDate }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("感情推移グラフ")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("期間", selection: $selectedPeriod) {
                    ForEach(ChartPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(.blue)
            }
            .padding(.horizontal)
            
            if filteredData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("データがありません")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("録音を開始して感情を記録しましょう")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                EmotionChartView(emotionData: filteredData)
                    .frame(height: 300)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("凡例")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        ForEach([
                            (color: Color.green, label: "喜び (76-100)"),
                            (color: Color.blue, label: "普通 (51-75)"),
                            (color: Color.orange, label: "悲しみ (21-50)"),
                            (color: Color.red, label: "怒り (1-20)")
                        ], id: \.label) { item in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 8, height: 8)
                                Text(item.label)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                if let latestData = filteredData.last {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("最新の感情")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(latestData.emotion)")
                                .font(.headline)
                            Text("スコア: \(latestData.score)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("平均スコア")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            let average = filteredData.map { $0.score }.reduce(0, +) / filteredData.count
                            Text("\(average)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(colorForScore(average))
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
    
    private func colorForScore(_ score: Int) -> Color {
        switch score {
        case 76...100: return .green
        case 51...75: return .blue
        case 21...50: return .orange
        case 1...20: return .red
        default: return .gray
        }
    }
}