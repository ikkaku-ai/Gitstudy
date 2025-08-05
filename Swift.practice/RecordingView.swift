import SwiftUI
import AVFoundation
import Speech

struct RecordingView: View {
    @Binding var isPresented: Bool
    @State private var showRecordingAlert = false
    @State private var generatedImageName: String?
    @State private var generatedNumber: Int?

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
                    } else if let imageName = generatedImageName, let number = generatedNumber {
                        VStack(spacing: 20) {
                            Text("生成された数値: \(number)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .padding()
                        }
                        .transition(.scale)
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
                            generatedImageName = nil
                            generatedNumber = nil
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
            .navigationBarItems(trailing: Button("閉じる") {
                isPresented = false
            })
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
                    
                    // MARK: - ここが修正された部分
                    // 文字起こし結果に基づいて数値を生成
                    let number = generateNumber(from: transcriptionText)
                    let imageName = self.imageName(for: number) ?? "1"
                    
                    DispatchQueue.main.async {
                        self.generatedNumber = number
                        self.generatedImageName = imageName
                    }
                    
                    mascotData.addMascot(
                        imageName: imageName,
                        recordingURL: recordingURL
                    )
                    
                    mascotData.updateMascotTranscription(
                        for: recordingURL,
                        transcriptionText: transcriptionText
                    )
                }
            }
        }
    }
    
    // MARK: - ここが修正された部分
    // キーワードに基づいて1〜100の数値を生成する関数
    private func generateNumber(from text: String) -> Int {
        let lowercasedText = text.lowercased()
        
        if lowercasedText.contains("楽しい") || lowercasedText.contains("嬉しい") || lowercasedText.contains("幸せ") || lowercasedText.contains("最高") || lowercasedText.contains("笑った") || lowercasedText.contains("遊びたい") || lowercasedText.contains("楽しかった") || lowercasedText.contains("楽しかったな") || lowercasedText.contains("ありがとう") || lowercasedText.contains("うれしい") || lowercasedText.contains("時間を忘れる"){
            return Int.random(in: 76...100)
        } else if lowercasedText.contains("怒り") || lowercasedText.contains("ムカつく") || lowercasedText.contains("不満") || lowercasedText.contains("やめてほしい") || lowercasedText.contains("嫌い") || lowercasedText.contains("嫌いそう") || lowercasedText.contains("嫌いそうな") || lowercasedText.contains("いい加減にしてほしい") || lowercasedText.contains("好きにすれば") {
            return Int.random(in: 1...20)
        } else if lowercasedText.contains("悲しい") || lowercasedText.contains("辛い") || lowercasedText.contains("さみしい") || lowercasedText.contains("どうして") || lowercasedText.contains("無理") || lowercasedText.contains("何もしたくない") || lowercasedText.contains("寂しい") || lowercasedText.contains("辛い") || lowercasedText.contains("わからない") || lowercasedText.contains("ごめんなさい") || lowercasedText.contains("もういいんだ") || lowercasedText.contains("疲れた"){
            return Int.random(in: 21...50)
        } else {
            // キーワードが見つからない場合は、中間的な数値をランダムに生成
            return Int.random(in: 51...75)
        }
    }
    
    private func imageName(for number: Int) -> String? {
        switch number {
        case 1...20:
            return "3"
        case 21...50:
            return "2"
        case 51...75:
            return "1"
        case 76...100:
            return "4"
        default:
            return nil
        }
    }
}
