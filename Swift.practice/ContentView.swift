// MARK: - ContentView.swift

import SwiftUI
import SwiftUICalendar

struct ContentView: View {
    @State private var selectedTab: NavigationTab = .home
    @State private var showRecordingView = false
    @StateObject private var mascotData = MascotDataModel()
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var voicePitchModel = VoicePitchModel()
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    
    @State private var selectedDateForScroll: YearMonthDay?
    @State private var scrollToID: UUID?
    
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
                    .environmentObject(audioRecorder) // ここが重要
                
                TutorialView()
                    .tabItem {
                        Label(NavigationTab.tutorial.displayName, systemImage: NavigationTab.tutorial.symbolName)
                    }
                    .tag(NavigationTab.tutorial)
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
    }
}
