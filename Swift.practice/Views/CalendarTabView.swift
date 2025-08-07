import SwiftUI
import SwiftUICalendar // ライブラリのインポート

struct CalendarTabView: View {
    @ObservedObject var controller: CalendarController = CalendarController()
    @State var focusDate: YearMonthDay? = YearMonthDay.current
    
    // 日本語の曜日配列
    let japaneseWeekdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        NavigationView {
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
                            Text(japaneseWeekdays[i]) // ここを日本語の曜日配列に変更
                                .font(.headline)
                                .frame(width: reader.size.width / 7)
                        }
                    }
                    
                    // カレンダー本体
                    CalendarView(controller) { date in
                        GeometryReader { geometry in
                            VStack {
                                if date.isToday {
                                    Text("\(date.day)")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Color.yellow)
                                        .clipShape(Circle())
                                } else {
                                    Text("\(date.day)")
                                        .foregroundColor(getColor(date))
                                        .font(.system(size: 15, weight: .light, design: .default))
                                }
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                            .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                            .border(.green.opacity(0.8), width: (focusDate == date ? 1 : 0))
                            .cornerRadius(2)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                focusDate = (date != focusDate ? date : nil)
                            }
                            // ここを修正: グリッド線を追加
                            .border(Color.gray, width: 0.5)
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
}
