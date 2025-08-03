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
    @State private var selectedTab: NavigationTab = .home
    @StateObject private var mascotData = MascotDataModel()
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(NavigationTab.home.displayName, systemImage: NavigationTab.home.symbolName)
                }
                .tag(NavigationTab.home)
                .environmentObject(mascotData)
                .environmentObject(audioRecorder)
                .environmentObject(speechRecognizer)
            
            RecordingView()
                .tabItem {
                    Label(NavigationTab.recording.displayName, systemImage: NavigationTab.recording.symbolName)
                }
                .tag(NavigationTab.recording)
                .environmentObject(mascotData)
                .environmentObject(audioRecorder)
                .environmentObject(speechRecognizer)
            
            TutorialView()
                .tabItem {
                    Label(NavigationTab.tutorial.displayName, systemImage: NavigationTab.tutorial.symbolName)
                }
                .tag(NavigationTab.tutorial)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
