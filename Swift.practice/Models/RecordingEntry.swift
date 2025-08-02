import Foundation

struct RecordingEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let fileName: String
    let transcription: String
    let duration: TimeInterval
    
    init(id: UUID = UUID(), date: Date = Date(), fileName: String, transcription: String, duration: TimeInterval = 0) {
        self.id = id
        self.date = date
        self.fileName = fileName
        self.transcription = transcription
        self.duration = duration
    }
    
    var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(fileName)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    var transcriptionPreview: String {
        let maxLength = 50
        if transcription.count <= maxLength {
            return transcription
        }
        return String(transcription.prefix(maxLength)) + "..."
    }
}