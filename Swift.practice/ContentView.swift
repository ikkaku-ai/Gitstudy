import SwiftUI

// MARK: - Color Extension for Custom Colors
// この部分は、あなたのプロジェクト内のどこかのファイルに一度だけ定義してください
extension Color {
    static let creamyWhite = Color(red: 0.98, green: 0.98, blue: 0.94)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - マスコットの情報を保持する構造体
struct DisplayMascot: Identifiable {
    let id = UUID()
    let imageName: String // 識別用
    let displayCount: Int // 何番目に表示されたか（位置決め用）
}

// MARK: - 画像で表示するキャラクタービュー
/// 画像をベースにマスコットキャラクターを描画するView
struct MascotImageView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .shadow(radius: 10) // 影を追加して立体感を出す
    }
}

// MARK: - マスコットの行を表示するView
struct MascotRowView: View {
    let mascotsInRow: [DisplayMascot]
    let rowIndex: Int

    var body: some View {
        HStack {
            let sortedMascots = mascotsInRow.sorted { $0.displayCount < $1.displayCount }
            
            if mascotsInRow.count == 2 {
                // 2つのマスコットがある場合は、小さい数字を左に、大きい数字を右に
                ImageWithCountView(mascot: sortedMascots[0])
                Spacer().frame(width: 20)
                ImageWithCountView(mascot: sortedMascots[1])
            } else if mascotsInRow.count == 1 {
                ImageWithCountView(mascot: sortedMascots[0])
            } else {
                EmptyView()
            }
        }
        .padding(.vertical, (rowIndex == 0) ? 0 : 10)
    }
}

// MARK: - 個々のマスコット画像とカウントを表示するヘルパーView
struct ImageWithCountView: View {
    let mascot: DisplayMascot

    var body: some View {
        ZStack(alignment: .bottom) { // alignmentを.bottomに変更
            // 画像で表示するキャラクタービューを使用
            MascotImageView(imageName: mascot.imageName)
                .frame(width: 125, height: 125)

            // 灰色の背景に「要約」とカウントを表示
            VStack(spacing: 0) {
                Text("要約 \(mascot.displayCount)") // 表示テキストを変更
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .padding(.vertical, 8) // 上下のパディングを調整
            .padding(.horizontal, 10)
            .frame(maxWidth: 100) // 背景の幅を画像より少し狭くする
            .offset(y: -10)
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @State var isrecording = false
    @State private var count = 0
    @State private var showMascot: [DisplayMascot] = []

    // 画像アセット名の配列
    private let mascotImageNames: [String] = ["1", "2", "3", "4"]
    
    var body: some View {
        ZStack {
            Color(red: 0.8, green: 0.95, blue: 1.0).edgesIgnoringSafeArea(.all)

            VStack {
                ScrollView {
                    let groupedMascots = Dictionary(grouping: showMascot) { mascot in
                        (showMascot.count - mascot.displayCount) / 2
                    }

                    ForEach(groupedMascots.keys.sorted(), id: \.self) { rowIndex in
                        let mascotsInCurrentRow = groupedMascots[rowIndex]!.sorted { $0.displayCount < $1.displayCount }
                        MascotRowView(mascotsInRow: mascotsInCurrentRow, rowIndex: rowIndex)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.top, 20)

                Spacer()

                Button {
                    isrecording = true
                } label: {
                    Text("録音")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                        .background(Capsule().fill(Color.gray))
                        .shadow(radius: 5)
                }
                .padding(.bottom, 50)
                .alert("録音を開始しますか？", isPresented: $isrecording) {
                    Button("いいえ", role: .cancel){
                        isrecording = false
                    }
                    Button("はい"){
                        print("録音を開始します！")
                        isrecording = false
                        
                        //1から4までの乱数を生成
                        let randomIndex = Int.random(in: 0..<mascotImageNames.count)
                        let randomImageName = mascotImageNames[randomIndex]
                        
                        //countを更新
                        count += 1
                        
                        //新しいマスコットをリストに追加
                        //乱数で決まった画像名とcountを渡す
                        showMascot.append(DisplayMascot(imageName: randomImageName, displayCount: count))
                    }
                }message: {
                    Text("録音をすると記録に残ります。")
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
