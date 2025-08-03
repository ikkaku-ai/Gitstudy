import SwiftUI

// マスコットの情報を保持する構造体
struct DisplayMascot: Identifiable {
    let id = UUID()
    let imageName: String
    let displayCount: Int
    let recordingURL: URL? // 音声録音機能を維持
    let transcriptionText: String // 文字起こし結果
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
                // UIfix: 画像表示
                Image(mascot.imageName)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .shadow(radius: 10)
            
            // タップ処理 -> 一回タップしたら再生ボタンが出る、最初から表示させておきたい
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
            
            // MARK: - 文字起こし結果の表示 -> UIの調整、横幅が飛び出してしまう
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
                //ここをLazyVGridに修正してもらう。動的データなので、ForEachを使っている
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
