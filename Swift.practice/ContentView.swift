import SwiftUI

// マスコットの情報を保持する構造体
struct DisplayMascot: Identifiable {
    let id = UUID()
    let imageName: String
    let displayCount: Int
    let recordingURL: URL? // 音声録音機能を維持
    let transcriptionText: String // 文字起こし結果
    let recordingDate: Date // 録音日時
    let summary: String // AI要約
}



// MARK: - ContentView
struct ContentView: View {
    @State private var selectedTab: NavigationTab = .home
    @State private var showRecordingView = false
    @StateObject private var mascotData = MascotDataModel()
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label(NavigationTab.home.displayName, systemImage: NavigationTab.home.symbolName)
                    }
                    .tag(NavigationTab.home)
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
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingRecordButton(showRecordingView: $showRecordingView)
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showRecordingView) {
            RecordingView(isPresented: $showRecordingView)
                .environmentObject(mascotData)
                .environmentObject(audioRecorder)
                .environmentObject(speechRecognizer)
        }
    }
}

#Preview {
    ContentView()
}
