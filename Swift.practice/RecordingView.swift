import SwiftUI

struct RecordingView: View {
    @State private var showRecordingAlert = false
    @EnvironmentObject var mascotData: MascotDataModel
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    private let mascotImageNames: [String] = ["1", "2", "3", "4"]
    
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
        
        let randomImageName = mascotImageNames.randomElement() ?? "1"
        mascotData.addMascot(
            imageName: randomImageName,
            recordingURL: audioRecorder.recordingURL
        )
        
        if let recordingURL = audioRecorder.recordingURL {
            print("録音ファイルのURL: \(recordingURL)")
            print("録音ファイルのパス: \(recordingURL.path)")
            
            Task {
                let authorized = await speechRecognizer.requestAuthorization()
                if authorized {
                    await speechRecognizer.transcribeAudio(from: recordingURL)
                    
                    let transcriptionText = speechRecognizer.transcriptionResult.isEmpty ?
                        "文字起こしできませんでした" : speechRecognizer.transcriptionResult
                    
                    mascotData.updateMascotTranscription(
                        for: recordingURL,
                        transcriptionText: transcriptionText
                    )
                }
            }
        }
    }
}