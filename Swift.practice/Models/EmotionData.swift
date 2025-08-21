import Foundation

struct EmotionData: Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
    let emotion: String
    
    init(date: Date, score: Int, emotion: String = "") {
        self.date = date
        self.score = score
        self.emotion = emotion
    }
    
    init(from record: MascotRecord) {
        self.date = record.recordingDate
        
        if let geminiResult = Self.extractScoreFromRecord(record) {
            self.score = geminiResult.score
            self.emotion = geminiResult.emotion
        } else {
            self.score = 50
            self.emotion = "不明"
        }
    }
    
    private static func extractScoreFromRecord(_ record: MascotRecord) -> (score: Int, emotion: String)? {
        let imageName = record.imageName
        
        let baseScore: Int
        let emotion: String
        switch imageName {
        case "4":
            baseScore = Int.random(in: 76...100)
            emotion = "喜び"
        case "1":
            baseScore = Int.random(in: 51...75)
            emotion = "普通"
        case "3":
            baseScore = Int.random(in: 21...50)
            emotion = "悲しみ"
        case "2":
            baseScore = Int.random(in: 1...20)
            emotion = "怒り"
        default:
            baseScore = 50
            emotion = "不明"
        }
        
        return (score: baseScore, emotion: emotion)
    }
}

extension Array where Element == MascotRecord {
    func toEmotionData() -> [EmotionData] {
        return self.map { EmotionData(from: $0) }
            .sorted { $0.date < $1.date }
    }
}
