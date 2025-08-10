import SwiftUI
import SwiftUICalendar // ライブラリのインポート

struct CalendarTabView: View {
    @ObservedObject var controller: CalendarController = CalendarController()
    @State var focusDate: YearMonthDay? = YearMonthDay.current
    @Binding var selectedDate: YearMonthDay? // ContentViewに選択された日付を渡すためのバインディング
    
    // 環境オブジェクトからmascotDataを取得
    @EnvironmentObject var mascotData: MascotDataModel
    
    // 日本語の曜日配列
    let japaneseWeekdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    // 感情ごとの色を定義
    private let emotionColors: [String: Color] = [
        "怒り": .red,
        "悲しみ": .blue,
        "普通": .yellow,
        "喜び": .green
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色のグラデーション
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.95, blue: 1.0),
                        Color(red: 0.95, green: 0.98, blue: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                GeometryReader { reader in
                    VStack(alignment: .center, spacing: 0) {
                        // スクロールボタンのセクション
                        HStack(spacing: 0) {
                            Button("一年前へ") {
                                controller.scrollTo(YearMonth(year: controller.yearMonth.year - 1, month: controller.yearMonth.month), isAnimate: true)
                            }
                            .font(.caption)
                            
                            Spacer()
                            
                            Button("半年前へ") {
                                controller.scrollTo(controller.yearMonth.addMonth(value: -6), isAnimate: true)
                            }
                            .font(.caption)
                            
                            Spacer()
                            
                            Button("今日へ") {
                                controller.scrollTo(YearMonth.current, isAnimate: true)
                            }
                            .font(.caption)
                            
                            Spacer()
                            
                            Button("半年後へ") {
                                controller.scrollTo(controller.yearMonth.addMonth(value: 6), isAnimate: true)
                            }
                            .font(.caption)
                            
                            Spacer()
                            
                            Button("一年後へ") {
                                controller.scrollTo(YearMonth(year: controller.yearMonth.year + 1, month: controller.yearMonth.month), isAnimate: true)
                            }
                            .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        
                        // 現在の年月を表示
                        Text("\(controller.yearMonth.year)年 \(controller.yearMonth.month)月")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                        
                        // 曜日のヘッダーを日本語に変更
                        HStack(alignment: .center, spacing: 0) {
                            ForEach(0..<7, id: \.self) { i in
                                Text(japaneseWeekdays[i])
                                    .font(.headline)
                                    .frame(width: reader.size.width / 7)
                            }
                        }
                        
                        // カレンダー本体
                        CalendarView(controller) { date in
                            GeometryReader { geometry in
                                VStack(spacing: 2) {
                                    // 日付の表示
                                    if date.isToday {
                                        Text("\(date.day)")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 20, height: 20)
                                            .background(Color.blue)
                                            .clipShape(Circle())
                                    } else {
                                        Text("\(date.day)")
                                            .foregroundColor(getColor(date))
                                            .font(.system(size: 15, weight: .light, design: .default))
                                    }
                                    
                                    Spacer(minLength: 4)
                                    
                                    let records = mascotData.mascotRecords
                                        .filter { isSameDay(date: $0.recordingDate, as: date) }
                                        .sorted { $0.recordingDate < $1.recordingDate }
                                    
                                    if !records.isEmpty {
                                        HStack {
                                            Spacer()
                                            HStack(spacing: 2) {
                                                ForEach(records.prefix(4), id: \.id) { record in
                                                    Circle()
                                                        .fill(getColorForSummary(record.summary))
                                                        .frame(width: 5, height: 5)
                                                }
                                            }
                                            Spacer()
                                        }
                                        
                                        if records.count > 4 {
                                            VStack(alignment: .trailing, spacing: 2) {
                                                ForEach(0..<((records.count - 4) + 3) / 4, id: \.self) { row in
                                                    HStack(spacing: 2) {
                                                        ForEach(0..<4, id: \.self) { col in
                                                            let index = 4 + row * 4 + col
                                                            if index < records.count {
                                                                Circle()
                                                                    .fill(getColorForSummary(records[index].summary))
                                                                    .frame(width: 5, height: 5)
                                                            } else {
                                                                Circle()
                                                                    .fill(Color.clear)
                                                                    .frame(width: 5, height: 5)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                                .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                .border(.green.opacity(0.8), width: (focusDate == date ? 1 : 0))
                                .cornerRadius(2)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selectedDate = date
                                    focusDate = (date != focusDate ? date : nil)
                                }
                                .border(Color.gray, width: 0.5)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 曜日によって色を返すヘルパーメソッド
    private func getColor(_ date: YearMonthDay) -> Color {
        if date.dayOfWeek == .sun {
            return Color.red
        } else if date.dayOfWeek == .sat {
            return Color.blue
        } else {
            return Color.black
        }
    }
    
    // 感情の要約に基づいて色を返すヘルパーメソッド
    private func getColorForSummary(_ summary: String) -> Color {
        if summary.contains("喜び") || summary.contains("楽しさ") {
            return .green
        } else if summary.contains("怒り") || summary.contains("不満") {
            return .red
        } else if summary.contains("悲しみ") || summary.contains("辛さ") {
            return .blue
        } else {
            return .yellow
        }
    }
    
    // DateとYearMonthDayが同じ日かどうかを判定するヘルパーメソッド
    private func isSameDay(date: Date, as yearMonthDay: YearMonthDay) -> Bool {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        return dateComponents.year == yearMonthDay.year &&
                dateComponents.month == yearMonthDay.month &&
                dateComponents.day == yearMonthDay.day
    }
}
