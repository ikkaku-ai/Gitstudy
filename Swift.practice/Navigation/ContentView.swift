import SwiftUI
import SwiftUICalendar

struct ContentView: View {
    @State private var selectedTab: NavigationTab = .home
    @State private var showRecordingView = false
    @StateObject private var mascotData = MascotDataModel.shared
    @StateObject private var audioRecorder = AudioRecorder.shared
    @StateObject private var speechRecognizer = SpeechRecognizer.shared
    @StateObject private var voicePitchModel = VoicePitchModel()
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    
    @State private var selectedDateForScroll: YearMonthDay?
    @State private var scrollToID: UUID?
    
    // MARK: チュートリアル表示を管理する状態変数
    @State private var showTutorial = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(scrollToID: $scrollToID)
                    .tabItem {
                        Label(NavigationTab.home.displayName, systemImage: NavigationTab.home.symbolName)
                    }
                    .tag(NavigationTab.home)
                    .environmentObject(mascotData)
                    .environmentObject(audioRecorder)
                    .environmentObject(speechRecognizer)
                    .environmentObject(voicePitchModel)
                    .environmentObject(audioPlayerManager)
                
                CalendarTabView(selectedDate: $selectedDateForScroll)
                    .tabItem {
                        Label(NavigationTab.calendar.displayName, systemImage: NavigationTab.calendar.symbolName)
                    }
                    .tag(NavigationTab.calendar)
                    .environmentObject(mascotData)

                VocalPitchView()
                    .tabItem {
                        Label(NavigationTab.voiceChanger.displayName, systemImage: NavigationTab.voiceChanger.symbolName)
                    }
                    .tag(NavigationTab.voiceChanger)
                    .environmentObject(voicePitchModel)
                    .environmentObject(audioPlayerManager)
                    .environmentObject(mascotData)
                    .environmentObject(audioRecorder)
            }
            .accentColor(.blue)
            .onChange(of: mascotData.latestRecordID) { newID in
                if let newID = newID {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.selectedTab = .home
                        self.scrollToID = newID
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingRecordButton(showRecordingView: $showRecordingView)
                        .padding(.trailing, 20)
                        .padding(.bottom,60)
                }
            }
        }
        .sheet(isPresented: $showRecordingView) {
            RecordingView(isPresented: $showRecordingView)
                .environmentObject(mascotData)
                .environmentObject(audioRecorder)
                .environmentObject(speechRecognizer)
                .environmentObject(voicePitchModel)
                .environmentObject(audioPlayerManager)
        }
        .onChange(of: selectedDateForScroll) { newDate in
            if let date = newDate {
                selectedTab = .home
                self.scrollToID = mascotData.findOldestRecordID(for: date)
                self.selectedDateForScroll = nil
            }
        }
        // MARK: アプリ起動時にチュートリアルを表示するロジック
        .onAppear {
            let hasShownTutorial = UserDefaults.standard.bool(forKey: "hasShownTutorial")
            if mascotData.mascotRecords.isEmpty && !hasShownTutorial {
                showTutorial = true
                UserDefaults.standard.set(true, forKey: "hasShownTutorial")
            }
        }
        // MARK: ポップアップとしてチュートリアルビューを表示
        .sheet(isPresented: $showTutorial) {
            TutorialView(isPresented: $showTutorial)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
