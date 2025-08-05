import SwiftUI
import Foundation

// MARK: - MascotRecordの定義
// MascotDataModelで使用されるMascotRecord構造体
struct MascotRecord: Identifiable, Equatable {
    var id: UUID = UUID()
    var imageName: String
    var displayCount: Int
    var recordingURL: URL?
    var transcriptionText: String
    var recordingDate: Date
    var summary: String
}

// MARK: - MascotDataModelの定義
// ObservableObjectに準拠したクラス
class MascotDataModel: ObservableObject {
    @Published var mascotRecords: [MascotRecord] = []
    @Published var count: Int = 0

    // MascotRecordを追加するメソッド
    func addMascotRecord(imageName: String, recordingURL: URL?, transcriptionText: String = "", summary: String = "") {
        count += 1
        let newRecord = MascotRecord(
            imageName: imageName,
            displayCount: count,
            recordingURL: recordingURL,
            transcriptionText: transcriptionText,
            recordingDate: Date(),
            summary: summary
        )
        mascotRecords.append(newRecord)
    }

    // 文字起こし結果を更新するメソッド
    func updateMascotTranscription(for recordingURL: URL, transcriptionText: String) {
        DispatchQueue.main.async {
            if let index = self.mascotRecords.firstIndex(where: { $0.recordingURL == recordingURL }) {
                let existingRecord = self.mascotRecords[index]
                let updatedRecord = MascotRecord(
                    imageName: existingRecord.imageName,
                    displayCount: existingRecord.displayCount,
                    recordingURL: existingRecord.recordingURL,
                    transcriptionText: transcriptionText,
                    recordingDate: existingRecord.recordingDate,
                    summary: self.generateSummary(from: transcriptionText, number: self.generateNumber(from: transcriptionText))
                )
                self.mascotRecords[index] = updatedRecord
            }
        }
    }

    // 感情分析に基づく要約を生成する関数
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
    
    // 文字起こしから数値を生成する関数
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
}
