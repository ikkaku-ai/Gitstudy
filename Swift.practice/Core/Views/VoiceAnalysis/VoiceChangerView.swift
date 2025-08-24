import SwiftUI

struct VoiceChangerView: View {
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    @EnvironmentObject var voicePitchModel: VoicePitchModel
    @EnvironmentObject var mascotData: MascotDataModel
    
    // 録音された音声のURLを保持する状態変数
    @State private var latestRecordingURL: URL?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("声を変えてみよう！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 変声スライダー
                VStack {
                    Text("ピッチ: \(voicePitchModel.customPitch, specifier: "%.0f")")
                    Slider(value: $voicePitchModel.customPitch, in: -1200...1200, step: 10)
                }
                .padding()
                
                // 変声ボタン
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
            .navigationTitle("変声")
            .onAppear {
                // 修正: mascotData.mascotRecordsの最初の要素からURLを取得する
                self.latestRecordingURL = mascotData.mascotRecords.first?.recordingURL
            }
        }
    }
}

// プレビュー用
struct VoiceChangerView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceChangerView()
            .environmentObject(AudioPlayerManager())
            .environmentObject(VoicePitchModel())
            .environmentObject(MascotDataModel()) // MascotDataModelも注入
    }
}
