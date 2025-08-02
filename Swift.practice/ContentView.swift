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
    let recordingURL: URL? // 音声録音機能を維持
    let transcriptionText: String // 文字起こし結果
    let displayMode: DisplayMode = .image // 表示モード
    
    enum DisplayMode {
        case drawn     // 図形描画（DrawnDogMascotView）
        case image     // 画像表示（1〜4の画像）
    }
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
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @State private var showTranscriptionResult = false
    
    var body: some View {
        // GeometryReaderを使用して、親ビューのサイズに基づいて内部の描画をスケーリング
        // これにより、MascotImageViewで指定するframeサイズに柔軟に対応できます
        GeometryReader { geometry in
            ZStack {
                // MARK: - 文字起こし状態表示（上部に重ねて表示）
                VStack {
                    HStack {
                        Spacer()
                        
                        if speechRecognizer.isTranscribing {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(0.8)
                                
                                Text("文字起こし中...")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(radius: 3)
                        } else if !speechRecognizer.transcriptionResult.isEmpty {
                            Button(action: {
                                showTranscriptionResult.toggle()
                            }) {
                                VStack {
                                    Image(systemName: "text.bubble")
                                        .foregroundColor(.green)
                                    Text("結果")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(radius: 3)
                        } else if let errorMessage = speechRecognizer.errorMessage, !errorMessage.isEmpty {
                            Button(action: {
                                showTranscriptionResult.toggle()
                            }) {
                                VStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.orange)
                                    Text("エラー")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(radius: 3)
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .zIndex(1)
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
        .sheet(isPresented: $showTranscriptionResult) {
            TranscriptionResultView(
                transcriptionText: speechRecognizer.transcriptionResult,
                errorMessage: speechRecognizer.errorMessage
            )
        }
    }
}

// MARK: - 文字起こし結果表示View
struct TranscriptionResultView: View {
    let transcriptionText: String
    let errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let error = errorMessage {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("エラー")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text(error)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    if !transcriptionText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("文字起こし結果")
                                .font(.headline)
                            
                            Text(transcriptionText)
                                .font(.body)
                                .lineSpacing(4)
                                .textSelection(.enabled)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    if transcriptionText.isEmpty && errorMessage == nil {
                        VStack(spacing: 16) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("文字起こし結果がありません")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("文字起こし")
            .navigationBarItems(
                trailing: Button("完了") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - 新しく追加するマスコットの行を表示するView
struct MascotRowView: View {
    let mascotsInRow: [DisplayMascot] // この行に表示するマスコットの配列
    let rowIndex: Int // 行のインデックス（パディング調整用）
    let audioRecorder: AudioRecorder
    let speechRecognizer: SpeechRecognizer

    var body: some View {
        HStack {
                // この行のマスコットを displayCount でソートし、奇数番目と偶数番目のマスコットを見つける
                let sortedMascots = mascotsInRow.sorted { $0.displayCount < $1.displayCount }
                let oddMascot = sortedMascots.first(where: { $0.displayCount % 2 == 1 })
                let evenMascot = sortedMascots.first(where: { $0.displayCount % 2 == 0 })

                // 横に1つずつ表示
                ForEach(sortedMascots, id: \.id) { mascot in
                    MascotImageView(mascot: mascot, speechRecognizer: speechRecognizer)
                        .environmentObject(audioRecorder)
                        .padding(.horizontal, 20)
                }
                }
        // 行間の隙間 (2行目以降に適用)
        .padding(.vertical, (rowIndex == 0) ? 0 : 10)
    }
}

// MARK: - 個々のマスコット画像を表示するヘルパーView
struct MascotImageView: View {
    let mascot: DisplayMascot
    let speechRecognizer: SpeechRecognizer
    @EnvironmentObject var audioRecorder: AudioRecorder
    @State private var isShowingPlayButton = false
    
    var body: some View {
        ZStack(alignment: .bottom) { // コンテンツを下揃えにする
            // 表示モードによって切り替え
            if mascot.displayMode == .image {
                // UIfix: 画像表示
                Image(mascot.imageName)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .shadow(radius: 10)
            } else {
                // main: 図形描画
                DrawnDogMascotView(speechRecognizer: speechRecognizer)
                    .frame(width: 250, height: 250)
                    .shadow(radius: 10)
            }
            
            // タップ処理
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if mascot.recordingURL != nil {
                        isShowingPlayButton.toggle()
                    }
                }
            
            // 再生ボタン
            if isShowingPlayButton, let recordingURL = mascot.recordingURL {
                Button(action: {
                    if audioRecorder.isPlaying {
                        audioRecorder.stopPlaying()
                    } else {
                        audioRecorder.playRecording(from: recordingURL)
                    }
                }) {
                    Image(systemName: audioRecorder.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 5)
                }
                .offset(y: -75) // DrawnDogMascotViewの中央付近に配置
            }
            
            // MARK: - 文字起こし結果の表示
            VStack(alignment: .leading, spacing: 4) {
                if !mascot.transcriptionText.isEmpty {
                    Text(mascot.transcriptionText)
                        .font(.caption)
                        .foregroundColor(.black)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("文字起こし中...")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: 250)
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            .shadow(radius: 2)
            .offset(y: -10)
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @State var isrecording = false
    @State private var count = 0
    @State private var showMascot: [DisplayMascot] = [] // 表示するマスコットのリスト
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var speechRecognizer = SpeechRecognizer()

    // 画像アセット名の配列
    private let mascotImageNames: [String] = ["1", "2", "3", "4"]
    
    var body: some View {
        ZStack {
            // UIfix の水色背景を採用
            Color(red: 0.8, green: 0.95, blue: 1.0).edgesIgnoringSafeArea(.all)

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
                        MascotRowView(mascotsInRow: mascotsInCurrentRow, rowIndex: rowIndex, audioRecorder: audioRecorder, speechRecognizer: speechRecognizer)
                    }
                }
                .frame(maxHeight: .infinity) // ScrollViewがVStackの残りのスペースを埋めるように
                .padding(.top, 20) // 上からの余白

                Spacer() // これにより、ボタンは画面下部に固定されます

                // 録音中の波形表示
                if audioRecorder.isRecording {
                    WaveformView(audioLevels: audioRecorder.audioLevels)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }

                Button {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                        count += 1
                        
                        // ランダムに画像を選択
                        let randomImageName = mascotImageNames.randomElement() ?? "1"
                        let newMascot = DisplayMascot(
                            imageName: randomImageName,
                            displayCount: count,
                            recordingURL: audioRecorder.recordingURL,
                            transcriptionText: ""
                        )
                        showMascot.append(newMascot)
                        
                        // 録音ファイルのURLを取得してログに出力
                        if let recordingURL = audioRecorder.recordingURL {
                            print("録音ファイルのURL: \(recordingURL)")
                            print("録音ファイルのパス: \(recordingURL.path)")
                            
                            // 文字起こし開始
                            Task {
                                let authorized = await speechRecognizer.requestAuthorization()
                                if authorized {
                                    await speechRecognizer.transcribeAudio(from: recordingURL)
                                    
                                    // 文字起こし完了後、マスコットの文字起こし結果を更新
                                    if let index = showMascot.lastIndex(where: { $0.recordingURL == recordingURL }) {
                                        let updatedMascot = DisplayMascot(
                                            imageName: showMascot[index].imageName,
                                            displayCount: showMascot[index].displayCount,
                                            recordingURL: showMascot[index].recordingURL,
                                            transcriptionText: speechRecognizer.transcriptionResult.isEmpty ? 
                                                "文字起こしできませんでした" : speechRecognizer.transcriptionResult
                                        )
                                        showMascot[index] = updatedMascot
                                    }
                                }
                            }
                        }
                    } else {
                        isrecording = true
                    }
                } label: {
                    Text(audioRecorder.isRecording ? "停止" : "録音")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                        .background(Capsule().fill(audioRecorder.isRecording ? Color.red : Color.gray))
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
                        audioRecorder.startRecording()
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