import SwiftUI
import SwiftUICalendar

struct HomeView: View {
    @EnvironmentObject var mascotData: MascotDataModel
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    @Binding var scrollToID: UUID?
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.95, blue: 1.0),
                        Color(red: 0.95, green: 0.98, blue: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 録音履歴セクション
                        if mascotData.mascotRecords.isEmpty {
                            // 空の状態の表示
                            VStack(spacing: 20) {
                                Image(systemName: "mic.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                Text("まだ録音がありません")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                Text("録音ボタンをタップして\n今日の気持ちを記録しましょう")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 400)
                            .padding(.top, 60)
                            
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                // 録音履歴ヘッダー
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("録音履歴")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Text("\(mascotData.mascotRecords.count)件の記録")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.left.arrow.right")
                                            .font(.system(size: 12))
                                        Text("スワイプ")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 16)
                                
                                // 録音カードの横スクロール
                                ScrollViewReader { proxy in
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(mascotData.mascotRecords.reversed()) { mascotRecord in
                                                RecordingCard(mascotRecord: mascotRecord)
                                                    .environmentObject(audioRecorder)
                                                    .environmentObject(mascotData)
                                                    .id(mascotRecord.id)
                                                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                    }
                                    .frame(height: 320)
                                    .onChange(of: scrollToID) { newID in
                                        if let id = newID {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                proxy.scrollTo(id, anchor: .center)
                                                self.scrollToID = nil
                                            }
                                        }
                                    }
                                }
                                
                                // セクション区切り線
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 20)
                                
                                // 感情グラフセクション
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("感情の推移")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                            
                                            Text("Gemini AIによる分析")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    // グラフコンテナ
                                    VStack {
                                        EmotionChartSwiftUIView(dataModel: mascotData)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                                    .padding(.horizontal, 20)
                                    .frame(height: 420)
                                }
                                .padding(.bottom, 100) // 録音ボタン用の余白
                            }
                        }
                    }
                }
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(scrollToID: .constant(nil))
            .environmentObject(MascotDataModel())
            .environmentObject(AudioRecorder())
            .environmentObject(SpeechRecognizer())
    }
}