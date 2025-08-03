import SwiftUI

class MascotDataModel: ObservableObject {
    @Published var mascots: [DisplayMascot] = []
    @Published var count: Int = 0
    
    func addMascot(imageName: String, recordingURL: URL?, transcriptionText: String = "", summary: String = "") {
        count += 1
        let newMascot = DisplayMascot(
            imageName: imageName,
            displayCount: count,
            recordingURL: recordingURL,
            transcriptionText: transcriptionText,
            recordingDate: Date(),
            summary: summary
        )
        mascots.append(newMascot)
    }
    
    func updateMascotTranscription(for recordingURL: URL, transcriptionText: String) {
        if let index = mascots.lastIndex(where: { $0.recordingURL == recordingURL }) {
            let updatedMascot = DisplayMascot(
                imageName: mascots[index].imageName,
                displayCount: mascots[index].displayCount,
                recordingURL: mascots[index].recordingURL,
                transcriptionText: transcriptionText,
                recordingDate: mascots[index].recordingDate,
                summary: generateSummary(from: transcriptionText)
            )
            mascots[index] = updatedMascot
        }
    }
    
    private func generateSummary(from text: String) -> String {
        // 簡単な要約生成ロジック
        let sentences = text.components(separatedBy: ["。", ".", "！", "!", "？", "?"])
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if sentences.isEmpty {
            return text
        }
        
        // 最初の2文を要約として使用
        let summaryCount = min(2, sentences.count)
        let summary = sentences.prefix(summaryCount).joined(separator: "。")
        
        // 文字数制限
        if summary.count > 100 {
            let truncated = String(summary.prefix(97)) + "..."
            return truncated
        }
        
        return summary + (summaryCount > 0 ? "。" : "")
    }
}