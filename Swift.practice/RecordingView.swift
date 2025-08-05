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
                    
                    let number = generateNumber(from: transcriptionText)
                    let imageName = self.imageName(for: number) ?? "1"
                    
                    // デバッグ用ログ
                    print("生成された数値: \(number)")
                    print("選択された画像名: \(imageName)")
                    print("文字起こし結果: \(transcriptionText)")
                    
                    // MascotRecordオブジェクトを作成して追加
                    let mascotRecord = MascotRecord(
                        imageName: imageName,
                        displayCount: 1,
                        recordingURL: recordingURL,
                        transcriptionText: transcriptionText,
                        recordingDate: Date(),
                        summary: generateSummary(from: transcriptionText, number: number)
                    )
                    
                    // MascotDataModelにMascotRecordを追加するメソッドを呼び出し
                    mascotData.addMascotRecord(imageName: mascotRecord.imageName, recordingURL: mascotRecord.recordingURL, transcriptionText: mascotRecord.transcriptionText, summary: mascotRecord.summary)
                }
            }
        }
    }
    
    // 要約テキストを生成する関数
    private func generateSummary(from text: String, number: Int) -> String {
        switch number {
        case 1...20:
            return "怒りや不満の感情を表現しています"
        case 21...50:
            return "悲しみや辛さの感情を表現しています"
        case 51...75:
            return "普通の感情状態です"
        case 76...100:
            return "喜びや楽しさの感情を表現しています"
        default:
            return "感情を分析しました"
        }
    }
    
    private func generateNumber(from text: String) -> Int {
        let lowercasedText = text.lowercased()
        
        if lowercasedText.contains("楽しい") || lowercasedText.contains("嬉しい") || lowercasedText.contains("幸せ") || lowercasedText.contains("最高") || lowercasedText.contains("笑った") || lowercasedText.contains("遊びたい") || lowercasedText.contains("楽しかった") || lowercasedText.contains("楽しかったな") || lowercasedText.contains("ありがとう") || lowercasedText.contains("うれしい") || lowercasedText.contains("時間を忘れる"){
            return Int.random(in: 76...100)
        } else if lowercasedText.contains("怒り") || lowercasedText.contains("ムカつく") || lowercasedText.contains("不満") || lowercasedText.contains("やめてほしい") || lowercasedText.contains("嫌い") || lowercasedText.contains("嫌いそう") || lowercasedText.contains("嫌いそうな") || lowercasedText.contains("いい加減にしてほしい") || lowercasedText.contains("好きにすれば") {
            return Int.random(in: 1...20)
        } else if lowercasedText.contains("悲しい") || lowercasedText.contains("辛い") || lowercasedText.contains("さみしい") || lowercasedText.contains("どうして") || lowercasedText.contains("無理") || lowercasedText.contains("何もしたくない") || lowercasedText.contains("寂しい") || lowercasedText.contains("辛い") || lowercasedText.contains("わからない") || lowercasedText.contains("ごめんなさい") || lowercasedText.contains("もういいんだ") || lowercasedText.contains("疲れた"){
            return Int.random(in: 21...50)
        } else {
            return Int.random(in: 51...75)
        }
    }
    
    private func imageName(for number: Int) -> String? {
        switch number {
        case 1...20:
            return "3"  // 怒り・不満の画像
        case 21...50:
            return "2"  // 悲しみ・辛さの画像
        case 51...75:
            return "1"  // 普通の画像
        case 76...100:
            return "4"  // 喜び・楽しさの画像
        default:
            return "1"  // デフォルト画像
        }
    }
}
