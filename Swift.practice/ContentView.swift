//
//  ContentView.swift
//  Swift.practice
//
//  Created by 藤井陽樹 on 2025/07/26.
//

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

// マスコットの情報を保持する構造体
struct DisplayMascot: Identifiable {
    let id = UUID()
    let imageName: String
    let displayCount: Int
}

// MARK: - カスタムシェイプの定義

/// ハートの形をPathで描画するカスタムシェイプ
struct Heart: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.height / 4),
                      control1: CGPoint(x: rect.midX, y: rect.height * 3 / 4),
                      control2: CGPoint(x: rect.minX, y: rect.midY))
        path.addArc(center: CGPoint(x: rect.width / 4, y: rect.height / 4),
                    radius: (rect.width / 4),
                    startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addArc(center: CGPoint(x: rect.width * 3 / 4, y: rect.height / 4),
                    radius: (rect.width / 4),
                    startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX, y: rect.midY),
                      control2: CGPoint(x: rect.midX, y: rect.height * 3 / 4))
        return path
    }
}

/// キラキラの形をPathで描画するカスタムシェイプ（簡略化）
struct Sparkle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// MARK: - 図形で描画された犬のマスコットキャラクター本体
/// 複数の図形を組み合わせて犬のマスコットを描画するView
struct DrawnDogMascotView: View {
    var body: some View {
        // GeometryReaderを使用して、親ビューのサイズに基づいて内部の描画をスケーリング
        // これにより、MascotImageViewで指定するframeサイズに柔軟に対応できます
        GeometryReader { geometry in
            ZStack {
                // 犬の背後にある大きなピンクのハート
                Heart()
                    .fill(Color(red: 1.0, green: 0.8, blue: 0.9)) // 薄いピンク
                    .frame(width: 180, height: 180)
                    .offset(y: 20)

                // 犬の体（薄茶色）
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.85, green: 0.7, blue: 0.5)) // 薄茶色
                    .frame(width: 100, height: 120)
                    .offset(y: 30)

                // 犬の頭（薄茶色）
                Circle()
                    .fill(Color(red: 0.85, green: 0.7, blue: 0.5)) // 薄茶色
                    .frame(width: 100, height: 100)
                    .offset(y: -30)

                // 犬の耳（濃い茶色）
                Capsule()
                    .fill(Color(red: 0.5, green: 0.35, blue: 0.2)) // 濃い茶色
                    .frame(width: 40, height: 70)
                    .rotationEffect(.degrees(-30))
                    .offset(x: -40, y: -80)
                Capsule()
                    .fill(Color(red: 0.5, green: 0.35, blue: 0.2)) // 濃い茶色
                    .frame(width: 40, height: 70)
                    .rotationEffect(.degrees(30))
                    .offset(x: 40, y: -80)

                // 犬の鼻先（薄茶色）
                Capsule()
                    .fill(Color(red: 0.85, green: 0.7, blue: 0.5))
                    .frame(width: 50, height: 30)
                    .offset(y: -15)

                // 犬の鼻（ピンク）
                Circle()
                    .fill(Color(red: 1.0, green: 0.6, blue: 0.7)) // ピンク
                    .frame(width: 15, height: 15)
                    .offset(y: -25)

                // 犬の目（黒）
                Circle()
                    .fill(Color.black)
                    .frame(width: 8, height: 8)
                    .offset(x: -20, y: -40)
                Circle()
                    .fill(Color.black)
                    .frame(width: 8, height: 8)
                    .offset(x: 20, y: -40)
                
                // MARK: - 犬の口（左右に二つの弧）
                // 左側の弧
                Path { path in
                    path.move(to: CGPoint(x: -8, y: -10)) // 開始点
                    path.addQuadCurve(to: CGPoint(x: -2, y: -10), control: CGPoint(x: -5, y: -12)) // 制御点 (少し下に凸)
                    }
                    .stroke(Color.black, lineWidth: 1)

                    // 右側の弧
                Path { path in
                    path.move(to: CGPoint(x: 2, y: -10)) // 開始点
                    path.addQuadCurve(to: CGPoint(x: 8, y: -10), control: CGPoint(x: 5, y: -12)) // 制御点 (少し下に凸)
                    }
                    .stroke(Color.black, lineWidth: 1)

                // 犬の首輪（赤）
                Capsule()
                    .fill(Color.red)
                    .frame(width: 80, height: 20)
                    .offset(y: 0)

                // 犬の胸のハートと心電図ライン（ピンク）
                Heart()
                    .fill(Color(red: 1.0, green: 0.6, blue: 0.7)) // ピンク
                    .frame(width: 40, height: 40)
                    .offset(y: 10)

                // ハート上の心電図ライン（簡略化されたパス）
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 5, y: 0))
                    path.addLine(to: CGPoint(x: 10, y: -10))
                    path.addLine(to: CGPoint(x: 15, y: 5))
                    path.addLine(to: CGPoint(x: 20, y: 0))
                }
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 20, height: 10)
                .offset(y: 10) // 胸のハートの上に位置調整

                // キラキラ
                Sparkle()
                    .fill(Color.pink.opacity(0.6))
                    .frame(width: 20, height: 20)
                    .offset(x: -100, y: -100)
                Sparkle()
                    .fill(Color.pink.opacity(0.6))
                    .frame(width: 15, height: 15)
                    .offset(x: 100, y: -100)
                Sparkle()
                    .fill(Color.pink.opacity(0.6))
                    .frame(width: 10, height: 10)
                    .offset(x: -80, y: 50)
                Sparkle()
                    .fill(Color.pink.opacity(0.6))
                    .frame(width: 12, height: 12)
                    .offset(x: 80, y: 50)
                // MARK: - 話してる風吹き出し
                ZStack {
                    // 吹き出しの本体（角丸長方形）
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: 100, height: 40) // 吹き出しのサイズ

                    // 吹き出しのしっぽ（三角形）
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 10, y: 0))
                        path.addLine(to: CGPoint(x: 5, y: 10)) // 下に伸びるしっぽ
                        path.closeSubpath()
                    }
                    .fill(Color.white)
                    .offset(y: 20) // 吹き出し本体の下に配置

                    // 吹き出し内のテキスト
                    Text("前回の要約をここに")
                        .font(.caption2)
                        .foregroundColor(.black)
                }
                .offset(y: 120) // 犬の体の下に配置
            }
            // ZStack全体をGeometryReaderのサイズに合わせてスケーリング
            .scaleEffect(min(geometry.size.width, geometry.size.height) / 250.0)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // 中央に配置
        }
    }
}

// MARK: - 新しく追加するマスコットの行を表示するView
struct MascotRowView: View {
    let mascotsInRow: [DisplayMascot] // この行に表示するマスコットの配列
    let rowIndex: Int // 行のインデックス（パディング調整用）

    var body: some View {
        HStack {
                // この行のマスコットを displayCount でソートし、奇数番目と偶数番目のマスコットを見つける
                let sortedMascots = mascotsInRow.sorted { $0.displayCount < $1.displayCount }
                let oddMascot = sortedMascots.first(where: { $0.displayCount % 2 == 1 })
                let evenMascot = sortedMascots.first(where: { $0.displayCount % 2 == 0 })

                if oddMascot != nil && evenMascot != nil {
                    // 奇数と偶数の両方のマスコットが存在する場合（完全なペア）
                    MascotImageView(mascot: oddMascot!) // 奇数は左
                    Spacer().frame(width: 20) // 画像間の隙間
                    MascotImageView(mascot: evenMascot!) // 偶数は右
                } else if let singleMascot = oddMascot ?? evenMascot {
                    // マスコットが1つだけの場合（奇数または偶数）は中央に配置
                    Spacer()
                    
                    MascotImageView(mascot: singleMascot)
                    Spacer()
                    } else {
                        // このケースは通常発生しないはず
                        EmptyView()
                    }
                }
        // 行間の隙間 (2行目以降に適用)
        .padding(.vertical, (rowIndex == 0) ? 0 : 10)
    }
}

// MARK: - 個々のマスコット画像を表示するヘルパーView
struct MascotImageView: View {
    let mascot: DisplayMascot
    
    var body: some View {
        ZStack(alignment: .bottom) { // コンテンツを下揃えにする
            // MARK: - ここでDrawnDogMascotViewを使用
            DrawnDogMascotView()
                .frame(width: 150, height: 150) // マスコットの表示サイズを調整
                .shadow(radius: 10) // 影
            // MARK: - ここにカウントの数字を表示
            //ここにAI要約を書くようにする
            Text("\(mascot.displayCount)") // displayCountを表示
                .font(.caption) // 小さめのフォント
                .fontWeight(.bold)
                .foregroundColor(.red) // 赤色で表示
                .padding(.horizontal, 8) // 背景の横パディング
                .padding(.vertical, 4)// 背景の縦パディング
                .background(Capsule().fill(Color.black.opacity(0.6)))
                .offset(y: -30) // Y軸を負の値にして上に移動 (この値はプレビューで調整してください)
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @State var isrecording = false
    @State private var count = 0
    @State private var showMascot: [DisplayMascot] = [] // 表示するマスコットのリスト

    var body: some View {
        ZStack {
            Color.yellow.edgesIgnoringSafeArea(.all)

            VStack {
                ScrollView {
                    // マスコットを2つずつ行にグループ化
                    let groupedMascots = Dictionary(grouping: showMascot) { mascot in
                        // (全体の数　- 現在のマスコットの表示順) / 2
                        // この計算により、displayCountが大きい順（つまり新しい順）マスコットほど、
                        // rowIndexの値が小さくなります。
                        (showMascot.count - mascot.displayCount) / 2
                    }

                    // 行インデックスでソートすることで、新しい行から古い行へと表示される
                    //ForEachループは、rowIndexの小さい順（0, 1, 2・・・）に処理をします。
                    //そのため、rowIndex = 0の行（最新のマスコットを含む行）が最初に描画され、
                    //ScrollViewの一番上に表示されます。
                    ForEach(groupedMascots.keys.sorted(), id: \.self) { rowIndex in
                        // 各行のマスコットを displayCount でソートして MascotRowView に渡す
                        // これにより、MascotRowView 内での leftMascot/rightMascot の判定が正しく行われる
                        let mascotsInCurrentRow = groupedMascots[rowIndex]!.sorted { $0.displayCount < $1.displayCount }
                        MascotRowView(mascotsInRow: mascotsInCurrentRow, rowIndex: rowIndex)
                    }
                }
                .frame(maxHeight: .infinity) // ScrollViewがVStackの残りのスペースを埋めるように
                .padding(.top, 20) // 上からの余白

                Spacer() // これにより、ボタンは画面下部に固定されます

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
                .padding(.bottom, 40)
                .alert("録音を開始しますか？", isPresented: $isrecording) {
                    Button("いいえ", role: .cancel){
                        isrecording = false
                    }
                    Button("はい"){
                        print("録音を開始します！")
                        isrecording = false
                        count += 1 // 録音回数をインクリメント

                        // 新しいマスコットをリストに追加
                        // "heartdog" は Assets.xcassets に入っている画像名に置き換えてください
                        showMascot.append(DisplayMascot(imageName: "drownDog", displayCount: count))
                    }
                }message: {
                    Text("録音をすると記録に残ります。")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
