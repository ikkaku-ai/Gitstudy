// MARK: - RecordingView.swift

import SwiftUI
import AVFoundation
import Speech

struct RecordingView: View {
    @Binding var isPresented: Bool
    
    @EnvironmentObject var mascotData: MascotDataModel
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    @State private var isProcessing = false

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
                    } else if isProcessing {
                        ProgressView("文字起こし中...")
                            .padding()
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
                            startRecording()
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        if audioRecorder.isRecording {
                            audioRecorder.stopRecording()
                            speechRecognizer.cancelRecognition()
                        }
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        isPresented = false
                    }
                    .disabled(speechRecognizer.transcriptionResult.isEmpty || isProcessing)
                }
            }
        }
    }
    
    private func startRecording() {
        // 修正: speechRecognizer.reset() を削除
        audioRecorder.startRecording()
        speechRecognizer.startRecognition()
    }
    
    private func stopRecordingAndProcess() {
        audioRecorder.stopRecording()
        speechRecognizer.cancelRecognition()
        
        guard let url = audioRecorder.lastRecordingURL else {
            print("❌ Recording URL is missing.")
            return
        }
        
        isProcessing = true
        
        Task {
            await speechRecognizer.transcribeAudio(from: url)
            
            let transcriptionText = speechRecognizer.transcriptionResult
            
            if !transcriptionText.isEmpty {
                DispatchQueue.main.async {
                    self.mascotData.addMascotRecord(
                        imageName: "1",
                        recordingURL: url,
                        transcriptionText: transcriptionText,
                        // summary: "感情分析中...", // この行を削除
                        adviceText: "アドバイスを生成中..."
                    )
                }
                await self.mascotData.updateMascotTranscription(for: url, transcriptionText: transcriptionText)
            } else {
                print("⚠️ Transcription failed or was empty.")
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.isPresented = false
            }
        }
    }
}
