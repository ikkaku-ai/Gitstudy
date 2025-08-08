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
                
                EmotionChartSwiftUIView(dataModel: mascotData)
                    .tabItem {
                        Label(NavigationTab.chart.displayName, systemImage: NavigationTab.chart.symbolName)
                    }
                    .tag(NavigationTab.chart)
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
//import SwiftUI
//import GoogleGenerativeAI
//
//struct ContentView: View {
//    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
//
//    @State var Prompt = ""
//    @State var Respons = ""
//    @State var isLoading = false
//
//    var body: some View {
//        ZStack {
//            VStack {
//                Text("Hello I am Gemini")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                Text("何かお手伝いすることはありますか？")
//                    .fontWeight(.bold)
//
//                Spacer()
//
//                ScrollView {
//                    Text(Respons)
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                }
//
//                Spacer()
//
//                HStack {
//
//                    TextField("Aa", text: $Prompt)
//                        .textFieldStyle(.roundedBorder)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .padding()
//
//                    Button(action: {
//                        generateRespons()
//                    }){
//                        Image(systemName: "arrow.up")
//                            .frame(width: 40, height: 40)
//                            .background(Color.green)
//                            .foregroundColor(.white)
//                            .clipShape(Circle())
//                    }.padding()
//                }
//            }
//
//            if isLoading {
//                Color.black.opacity(0.3)
//                ProgressView()
//            }
//        }
//    }
//
//    func generateRespons() {
//        isLoading = true
//        Respons = ""
//
//        Task {
//            do {
//                let result = try await model.generateContent(Prompt)
//                isLoading = false
//                Respons = result.text ?? "No Respons found"
//                Prompt = ""
//            } catch {
//                Respons = "Sometimes went wrong \n \(error.localizedDescription)"
//                isLoading = false
//                Prompt = ""
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
