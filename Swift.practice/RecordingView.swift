import SwiftUI
import AVFoundation
import Speech

struct RecordingView: View {
    @Binding var isPresented: Bool
    @State private var showRecordingAlert = false

    @EnvironmentObject var mascotData: MascotDataModel
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.8, green: 0.95, blue: 1.0).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    if audioRecorder.isRecording {
                        VStack(spacing: 20) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                                .scaleEffect(audioRecorder.isRecording ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: audioRecorder.isRecording)
                            
                            Text("録音中...")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                            
                            WaveformView(audioLevels: audioRecorder.audioLevels)
                                .frame(height: 100)
                                .padding(.horizontal, 40)
                        }
                        .padding(.bottom, 100)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "mic.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                            
                            Text("録音を開始してください")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if audioRecorder.isRecording {
                            stopRecordingAndProcess()
                        } else {
                            showRecordingAlert = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(audioRecorder.isRecording ? Color.red : Color.blue)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(radius: 10)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("録音")
            .navigationBarTitleDisplayMode(.large)
            .alert("録音を開始しますか？", isPresented: $showRecordingAlert) {
                Button("キャンセル", role: .cancel) {
                    showRecordingAlert = false
                }
                Button("録音開始") {
                    audioRecorder.startRecording()
                    showRecordingAlert = false
                }
            } message: {
                Text("録音をすると記録に残ります。")
            }
        }
    }
    
    private func stopRecordingAndProcess() {
        audioRecorder.stopRecording()
        
        if let recordingURL = audioRecorder.recordingURL {
            print("録音ファイルのURL: \(recordingURL)")
            print("録音ファイルのパス: \(recordingURL.path)")
            
            Task {
                let authorized = await speechRecognizer.requestAuthorization()
                if authorized {
                    await speechRecognizer.transcribeAudio(from: recordingURL)
                    
                    let transcriptionText = speechRecognizer.transcriptionResult.isEmpty ?
                    "文字起こしできませんでした" : speechRecognizer.transcriptionResult
                    
                    // 録音データ追加
                    DispatchQueue.main.async {
                        self.mascotData.addMascotRecord(
                            imageName: "1", // 初期画像
                            recordingURL: recordingURL,
                            transcriptionText: transcriptionText,
                            summary: "感情分析中...", // 初期要約
                            adviceText: "アドバイスを生成中..." // 初期アドバイス
                        )
                    }

                    // Geminiによる感情分析とデータ更新
                    await mascotData.updateMascotTranscription(for: recordingURL, transcriptionText: transcriptionText)
                }
                
                // 録音処理が完了したら画面を閉じる
                DispatchQueue.main.async {
                    self.isPresented = false
                }
            }
        } else {
            // 録音URLがない場合も画面を閉じる
            self.isPresented = false
        }
    }
}
