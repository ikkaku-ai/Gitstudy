// ContentView.swift

import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @State private var selectedTab: NavigationTab = .home
    @State private var showRecordingView = false
    @StateObject private var mascotData = MascotDataModel()
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var resultNumber: Int? // 1〜100の数値が格納される
    
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
                
                // カレンダーのタブをチュートリアルの前に移動
                CalendarTabView()
                    .tabItem {
                        Label(NavigationTab.calendar.displayName, systemImage: NavigationTab.calendar.symbolName)
                    }
                    .tag(NavigationTab.calendar)
                    .environmentObject(mascotData)
                
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
