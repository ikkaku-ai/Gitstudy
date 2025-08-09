// MARK: - VocalPitchView.swift

import SwiftUI
import AVFoundation

struct VocalPitchView: View {
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    @EnvironmentObject var voicePitchModel: VoicePitchModel
    @EnvironmentObject var mascotData: MascotDataModel
    
    @State private var latestRecordingURL: URL?
    
    // ホームと同じ背景色を定義
    private let backgroundColor = Color(red: 247/255, green: 247/255, blue: 247/255)

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("声を変えてみよう！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack {
                    Text("ピッチ: \(voicePitchModel.customPitch, specifier: "%.0f")")
                    Slider(value: $voicePitchModel.customPitch, in: -1200...1200, step: 10)
                }
                .padding()
                
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
                self.latestRecordingURL = mascotData.mascotRecords.last?.recordingURL
            }
        }
    }
}
