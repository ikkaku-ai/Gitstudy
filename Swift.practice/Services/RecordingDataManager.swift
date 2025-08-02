import Foundation
import Combine

class RecordingDataManager: ObservableObject {
    @Published var recordings: [RecordingEntry] = []
    
    private let jsonFileName = "recordings.json"
    private var jsonFileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(jsonFileName)
    }
    
    init() {
        loadRecordings()
    }
    
    func saveRecording(_ entry: RecordingEntry) {
        recordings.insert(entry, at: 0) // 新しい録音を先頭に追加
        saveToJSON()
    }
    
    func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings[index]
            // 音声ファイルを削除
            try? FileManager.default.removeItem(at: recording.fileURL)
        }
        recordings.remove(atOffsets: offsets)
        saveToJSON()
    }
    
    func deleteRecording(_ entry: RecordingEntry) {
        // 音声ファイルを削除
        try? FileManager.default.removeItem(at: entry.fileURL)
        recordings.removeAll { $0.id == entry.id }
        saveToJSON()
    }
    
    private func saveToJSON() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(recordings)
            try data.write(to: jsonFileURL)
            print("録音データをJSONに保存しました: \(jsonFileURL.path)")
        } catch {
            print("JSONの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func loadRecordings() {
        guard FileManager.default.fileExists(atPath: jsonFileURL.path) else {
            print("JSONファイルが存在しません")
            return
        }
        
        do {
            let data = try Data(contentsOf: jsonFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            recordings = try decoder.decode([RecordingEntry].self, from: data)
            print("録音データを読み込みました: \(recordings.count)件")
        } catch {
            print("JSONの読み込みに失敗しました: \(error.localizedDescription)")
        }
    }
}