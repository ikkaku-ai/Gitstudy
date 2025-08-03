import SwiftUI

struct HomeView: View {
    @EnvironmentObject var mascotData: MascotDataModel
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.8, green: 0.95, blue: 1.0).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    if mascotData.mascots.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("録音ボタンから音声を録音してみましょう")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        // 録音カードの横スクロール
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("録音履歴")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.left.arrow.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text("スワイプ")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 16) {
                                    ForEach(mascotData.mascots.reversed()) { mascot in
                                        RecordingCard(mascot: mascot)
                                            .environmentObject(audioRecorder)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            }
                            .frame(height: 320)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}