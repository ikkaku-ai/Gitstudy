import Foundation
import Speech
import AVFoundation

@MainActor
class SpeechRecognizer: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var transcriptionResult: String = ""
    @Published var isTranscribing: Bool = false
    @Published var errorMessage: String?
    
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                continuation.resume(returning: authStatus == .authorized)
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
        
        do {
            let result = try await performSpeechRecognition(url: url)
            transcriptionResult = result
        } catch {
            let nsError = error as NSError
            if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1101 {
                errorMessage = "Simulatorでは音声認識が利用できません。実機でお試しください。"
            } else {
                errorMessage = "文字起こしに失敗しました: \(error.localizedDescription)"
            }
        }
        
        isTranscribing = false
    }
    
    private func performSpeechRecognition(url: URL) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let request = SFSpeechURLRecognitionRequest(url: url)
            request.shouldReportPartialResults = false
            
            recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
            
            // タスクが開始されない場合のタイムアウト処理
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                if self.recognitionTask?.state == .starting {
                    self.recognitionTask?.cancel()
                    let timeoutError = NSError(domain: "SpeechRecognizerTimeout", code: -1, userInfo: [NSLocalizedDescriptionKey: "音声認識がタイムアウトしました"])
                    continuation.resume(throwing: timeoutError)
                }
            }
        }
    }
    
    func cancelRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        isTranscribing = false
    }
}