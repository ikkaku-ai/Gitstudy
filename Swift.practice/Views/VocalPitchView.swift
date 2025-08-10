// MARK: - VocalPitchView.swift

import SwiftUI
import AVFoundation

struct VocalPitchView: View {
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    @EnvironmentObject var voicePitchModel: VoicePitchModel
    @EnvironmentObject var mascotData: MascotDataModel
    
    // 変声機能専用の録音URLを保持する状態変数
    @State private var latestRecordingURL: URL?

    var body: some View {
        NavigationView {
            ZStack {
                // ホームと同じグラデーションの背景色
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.95, blue: 1.0),
                        Color(red: 0.95, green: 0.98, blue: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("声を変えてみよう！")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(latestRecordingURL != nil ? "録音済みです" : "録音が見つかりません")
                        .foregroundColor(.gray)
                    
                    // 変声スライダー
                    VStack {
                        Text("ピッチ: \(voicePitchModel.customPitch, specifier: "%.0f")")
                        Slider(value: $voicePitchModel.customPitch, in: -1200...1200, step: 10)
                    }
                    .padding()
                    
                    // 変声して再生ボタン
                    Button("変声して再生") {
                        if let url = latestRecordingURL {
                            audioPlayerManager.setPitch(voicePitchModel.customPitch)
                            audioPlayerManager.loadAudio(url: url)
                            audioPlayerManager.play()
                        }
                    }
                    .padding()
                    .background(latestRecordingURL == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(latestRecordingURL == nil)
                    
                    // 停止ボタン
                    Button("停止") {
                        audioPlayerManager.stop()
                    }
                    .padding()
                    .background(audioPlayerManager.isPlaying ? Color.red : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(!audioPlayerManager.isPlaying)
                }
                .padding()
            }
            .navigationTitle("変声")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // mascotDataから最新の録音URLを取得
                self.latestRecordingURL = mascotData.mascotRecords.last?.recordingURL
            }
            .onDisappear {
                audioPlayerManager.stop()
            }
        }
    }
}

// プレビュー用
struct VocalPitchView_Previews: PreviewProvider {
    static var previews: some View {
        VocalPitchView()
            .environmentObject(AudioPlayerManager())
            .environmentObject(VoicePitchModel())
            .environmentObject(MascotDataModel())
    }
}
