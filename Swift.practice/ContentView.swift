// ContentView.swift

import SwiftUI
import SwiftUICalendar // SwiftUICalendarをインポート

// MARK: - ContentView
struct ContentView: View {
    @State private var selectedTab: NavigationTab = .home
    @State private var showRecordingView = false
    @StateObject private var mascotData = MascotDataModel()
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var resultNumber: Int? // 1〜100の数値が格納される
    
    // 修正: カレンダーから選択された日付を保持する状態変数
    @State private var selectedDateForScroll: YearMonthDay?
    // 修正: HomeViewにスクロールさせるためのカードIDを保持する状態変数
    @State private var scrollToID: UUID?
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // HomeViewにscrollToIDのバインディングを渡す
                HomeView(scrollToID: $scrollToID)
                    .tabItem {
                        Label(NavigationTab.home.displayName, systemImage: NavigationTab.home.symbolName)
                    }
                    .tag(NavigationTab.home)
                    .environmentObject(mascotData)
                    .environmentObject(audioRecorder)
                    .environmentObject(speechRecognizer)
                
                // CalendarTabViewにselectedDateForScrollのバインディングを渡す
                CalendarTabView(selectedDate: $selectedDateForScroll)
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
            // 修正: MascotDataModelの最新カードIDが更新されたらスクロールをトリガー
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
        // 修正: selectedDateForScrollが変更されたら実行
        .onChange(of: selectedDateForScroll) { newDate in
            if let date = newDate {
                // タブをホームに切り替える
                selectedTab = .home
                
                // 選択された日付の最も古いレコードIDを取得し、scrollToIDに設定
                self.scrollToID = mascotData.findOldestRecordID(for: date)
                
                // 処理後、状態をリセット
                self.selectedDateForScroll = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
