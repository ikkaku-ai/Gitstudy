import Foundation
import SwiftUI
import AVFoundation

@MainActor
class RecordingViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private var audioRecorder: AudioRecorder?
    private var speechRecognizer: SpeechRecognizer?
    private var mascotData: MascotDataModel?
    
    init() {
        // 空の初期化
    }
    
    func setup(audioRecorder: AudioRecorder, 
               speechRecognizer: SpeechRecognizer, 
               mascotData: MascotDataModel) {
        self.audioRecorder = audioRecorder
        self.speechRecognizer = speechRecognizer
        self.mascotData = mascotData
    }
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    var audioLevels: [Float] {
        audioRecorder?.audioLevels ?? []
    }
    
    var transcriptionResult: String {
        speechRecognizer?.transcriptionResult ?? ""
    }
    
    var canComplete: Bool {
        !(speechRecognizer?.transcriptionResult.isEmpty ?? true) && !isProcessing
    }
    
    func startRecording() {
        guard let audioRecorder = audioRecorder,
              let speechRecognizer = speechRecognizer else {
            errorMessage = "録音の初期化に失敗しました"
            showError = true
            return
        }
        audioRecorder.startRecording()
        speechRecognizer.startRecognition()
    }
    
    func stopRecordingAndProcess() async -> Bool {
        guard let audioRecorder = audioRecorder,
              let speechRecognizer = speechRecognizer,
              let mascotData = mascotData else {
            errorMessage = "録音処理の初期化に失敗しました"
            showError = true
            return false
        }
        
        audioRecorder.stopRecording()
        speechRecognizer.cancelRecognition()
        
        guard let url = audioRecorder.lastRecordingURL else {
            errorMessage = "録音URLの取得に失敗しました"
            showError = true
            return false
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        await speechRecognizer.transcribeAudio(from: url)
        
        let transcriptionText = speechRecognizer.transcriptionResult
        
        if !transcriptionText.isEmpty {
            print("📝 文字起こし完了: \(transcriptionText)")
            print("📦 現在のレコード数（追加前）: \(mascotData.mascotRecords.count)")
            
            mascotData.addMascotRecord(
                imageName: "1",
                recordingURL: url,
                transcriptionText: transcriptionText,
                adviceText: "アドバイスを生成中..."
            )
            
            print("✅ レコード追加完了")
            print("📦 現在のレコード数（追加後）: \(mascotData.mascotRecords.count)")
            
            await mascotData.updateMascotTranscription(
                for: url, 
                transcriptionText: transcriptionText
            )
            return true
        } else {
            errorMessage = "文字起こしに失敗しました"
            showError = true
            return false
        }
    }
    
    func cancelRecording() {
        if audioRecorder?.isRecording ?? false {
            audioRecorder?.stopRecording()
            speechRecognizer?.cancelRecognition()
        }
    }
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
}