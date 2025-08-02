import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechURLRecognitionRequest?
    
    @Published var transcriptionResult: String = ""
    @Published var isTranscribing: Bool = false
    @Published var errorMessage: String?
    
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized:
                    continuation.resume(returning: true)
                case .denied, .restricted, .notDetermined:
                    continuation.resume(returning: false)
                @unknown default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func transcribeAudio(from url: URL) async {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "音声認識が利用できません"
            return
        }
        
        isTranscribing = true
        transcriptionResult = ""
        errorMessage = nil
        
        recognitionRequest = SFSpeechURLRecognitionRequest(url: url)
        
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "認識リクエストの作成に失敗しました"
            isTranscribing = false
            return
        }
        
        recognitionRequest.shouldReportPartialResults = false
        
        speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "文字起こしに失敗しました: \(error.localizedDescription)"
                } else if let result = result {
                    if result.isFinal {
                        self.transcriptionResult = result.bestTranscription.formattedString
                    }
                }
                self.isTranscribing = false
            }
        }
        
        isTranscribing = false
    }
}