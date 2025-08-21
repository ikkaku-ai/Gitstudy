// MARK: - MascotDataModel.swift

import SwiftUI
import Foundation
import GoogleGenerativeAI
import SwiftUICalendar

// MARK: - MascotRecordの定義
struct MascotRecord: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var imageName: String
    var displayCount: Int
    // 修正: recordingURLを削除し、ファイル名のみを保存
    var recordingFilename: String?
    var transcriptionText: String
    var recordingDate: Date
    // var summary: String // この行を削除
    var adviceText: String = "" // コメントとして使用
    
    // 修正: ファイル名からURLを動的に生成するコンピューテッドプロパティ
    var recordingURL: URL? {
        guard let filename = recordingFilename else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(filename)
    }
}

// Gemini APIからのレスポンスをデコードするための構造体
struct GeminiResponse: Codable {
    let score: Int
    let emotion: String
    // let summary: String // この行を削除
    let advice: String
}

// MARK: - MascotDataModelの定義
class MascotDataModel: ObservableObject {
    @Published var mascotRecords: [MascotRecord] = [] {
        didSet {
            saveMascotRecords() // データが変更されるたびに自動保存
        }
    }
    @Published var count: Int = 0
    @Published var latestRecordID: UUID?
    
    private let userDefaultsKey = "savedMascotRecords"
    
    // TODO: ここに取得したGemini APIキーを設定してください。
    // https://aistudio.google.com/ でAPIキーを取得できます。
    private let geminiModel = GenerativeModel(name: "gemini-1.5-flash", apiKey: "AIzaSyBtbhB3CTDGah81KbeA_22ToYytq_zGr5I")
    
    // APIエラー時のフォールバックコメントリストを復活させ、感情別に分類
    private let fallbackComments: [Int: [String]] = [
        // 怒りや不満 (1-20)
        1: ["それは大変だったね。", "嫌な思いをしたね。"],
        // 悲しみや辛さ (21-50)
        2: ["そっか、そうなんだね。", "うん、わかる気がするよ。", "無理しないでね。"],
        // 普通 (51-75)
        3: ["なるほど、そういうことか。", "うん、聞けてよかったよ。"],
        // 喜びや楽しさ (76...100)
        4: ["お話してくれてありがとう！", "聞かせてくれて嬉しいな。", "よかったね！"]
    ]
    
    init() {
        loadMascotRecords() // 起動時に保存されたデータを読み込む
    }
    
    // MARK: - UserDefaultsを使ったデータの永続化
    func saveMascotRecords() {
        if let encodedData = try? JSONEncoder().encode(mascotRecords) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
            print("💾 Mascot RecordsをUserDefaultsに保存しました。")
        }
    }
    
    func loadMascotRecords() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decodedRecords = try? JSONDecoder().decode([MascotRecord].self, from: savedData) {
                DispatchQueue.main.async {
                    self.mascotRecords = decodedRecords
                    self.count = decodedRecords.count
                    print("📂 Mascot RecordsをUserDefaultsから読み込みました。")
                }
            }
        }
    }

    func addMascotRecord(imageName: String, recordingURL: URL?, transcriptionText: String = "", adviceText: String = "") {
        let newRecord = MascotRecord(
            imageName: imageName,
            displayCount: mascotRecords.count + 1,
            // 修正: URLからファイル名のみを抽出して保存
            recordingFilename: recordingURL?.lastPathComponent,
            transcriptionText: transcriptionText,
            recordingDate: Date(),
            // summary: summary, // この行を削除
            adviceText: adviceText
        )
        mascotRecords.append(newRecord)
    }
    
    func removeMascotRecord(withId id: UUID) {
        DispatchQueue.main.async {
            if let index = self.mascotRecords.firstIndex(where: { $0.id == id }) {
                self.mascotRecords.remove(at: index)
            }
        }
    }

    func updateMascotTranscription(for recordingURL: URL, transcriptionText: String) async {
        // Geminiで感情分析
        let geminiResult = await analyzeWithGemini(from: transcriptionText)
        let imageName = self.imageName(for: geminiResult.score) ?? "1"
        
        DispatchQueue.main.async {
            // 修正: ファイル名で一致するレコードを検索
            if let index = self.mascotRecords.firstIndex(where: { $0.recordingFilename == recordingURL.lastPathComponent }) {
                let existingRecord = self.mascotRecords[index]
                let updatedRecord = MascotRecord(
                    imageName: imageName,
                    displayCount: existingRecord.displayCount,
                    recordingFilename: existingRecord.recordingFilename,
                    transcriptionText: transcriptionText,
                    recordingDate: existingRecord.recordingDate,
                    // summary: geminiResult.summary, // この行を削除
                    adviceText: geminiResult.advice
                )
                self.mascotRecords[index] = updatedRecord
                print("✅ Geminiで分析が完了しました:")
                print("   スコア: \(geminiResult.score)")
                print("   感情: \(geminiResult.emotion)")
                // print("   要約: \(geminiResult.summary)") // この行を削除
                print("   アドバイス: \(geminiResult.advice)")
                
                self.latestRecordID = updatedRecord.id
            }
        }
    }

    func findOldestRecordID(for yearMonthDay: YearMonthDay) -> UUID? {
        let calendar = Calendar.current
        
        guard let startDate = calendar.date(from: DateComponents(year: yearMonthDay.year, month: yearMonthDay.month, day: yearMonthDay.day)),
              let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
            return nil
        }
        
        let oldestRecord = mascotRecords
            .filter { $0.recordingDate >= startDate && $0.recordingDate < endDate }
            .sorted { $0.recordingDate < $1.recordingDate }
            .first
        
        return oldestRecord?.id
    }
    
    private func generateNumber(from text: String) -> Int {
        let lowercasedText = text.lowercased()
        
        if lowercasedText.contains("楽しい") || lowercasedText.contains("嬉しい") || lowercasedText.contains("幸せ") || lowercasedText.contains("最高") || lowercasedText.contains("笑った") || lowercasedText.contains("遊びたい") || lowercasedText.contains("楽しかった") || lowercasedText.contains("楽しかったな") || lowercasedText.contains("ありがとう") || lowercasedText.contains("うれしい") || lowercasedText.contains("時間を忘れる") {
            return Int.random(in: 85...100)
        } else if lowercasedText.contains("怒り") || lowercasedText.contains("ムカつく") || lowercasedText.contains("不満") || lowercasedText.contains("やめてほしい") || lowercasedText.contains("嫌い") || lowercasedText.contains("嫌いそう") || lowercasedText.contains("嫌いそうな") || lowercasedText.contains("いい加減にしてほしい") || lowercasedText.contains("好きにすれば") || lowercasedText.contains("大変"){
            return Int.random(in: 1...15)
        } else if lowercasedText.contains("悲しい") || lowercasedText.contains("辛い") || lowercasedText.contains("さみしい") || lowercasedText.contains("どうして") || lowercasedText.contains("無理") || lowercasedText.contains("何もしたくない") || lowercasedText.contains("寂しい") || lowercasedText.contains("辛い") || lowercasedText.contains("わからない") || lowercasedText.contains("ごめんなさい") || lowercasedText.contains("もういいんだ") || lowercasedText.contains("疲れた") {
            return Int.random(in: 21...35)
        } else {
            return Int.random(in: 51...75)
        }
    }

    private func getFallbackComment(for number: Int) -> String {
        let key: Int
        switch number {
        case 1...20: key = 1
        case 21...50: key = 2
        case 51...75: key = 3
        case 76...100: key = 4
        default: key = 3
        }
        return fallbackComments[key]?.randomElement() ?? "うん、わかるよ。"
    }

    private func analyzeWithGemini(from text: String) async -> (score: Int, emotion: String, advice: String) {
        let prompt = """
        以下はある人の音声日記の文字起こしです。
        
        「\(text)」
        
        この内容を分析し、以下の3つの情報をそれぞれ出力してください。
        
        出力は必ず **以下のJSON形式** で行ってください。
        
        - "score": 1〜100の整数で、その日記の感情のポジティブ度合い（高いほどポジティブ）
        - "emotion": 一言で表す感情ラベル（例：「嬉しい」「悲しい」「不安」「怒り」「やる気」「疲れた」など）
        - "advice": 日記の内容をふまえたアドバイスや励ましの言葉（1文で簡潔に）
        
        【出力形式】
        {
          "score": 87,
          "emotion": "嬉しい",
          "advice": "その素敵な時間を大切にしてください。心が元気なときは、周囲にも良い影響を与えられますよ！"
        }
        """
        
        do {
            print("▶️ Geminiへの感情分析リクエストを開始します。")
            
            let response = try await geminiModel.generateContent(prompt)

            guard let responseText = response.text else {
                print("❌ Geminiからのレスポンスにテキストが含まれていませんでした。")
                return getFallbackResult(from: text)
            }
            
            print("✅ Geminiからの生のレスポンス:\n\(responseText)")
            
            // JSON部分だけを抽出（```jsonや余計な文字を除去）
            let cleanedText = responseText
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let data = cleanedText.data(using: .utf8) else {
                print("❌ Geminiからのレスポンスをデータに変換できませんでした。")
                return getFallbackResult(from: text)
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(GeminiResponse.self, from: data)
            return (score: result.score, emotion: result.emotion, advice: result.advice)
            
        } catch {
            print("❌ Gemini API分析エラーが発生しました。")
            print("エラーの詳細: \(error)")
            return getFallbackResult(from: text)
        }
    }
    
    private func getFallbackResult(from text: String) -> (score: Int, emotion: String, advice: String) {
        let score = generateNumber(from: text)
        let emotion = getFallbackComment(for: score) // summaryを削除し、代わりにadviceを使用
        let advice = getFallbackComment(for: score)
        return (score: score, emotion: emotion, advice: advice)
    }

    private func imageName(for number: Int) -> String? {
        switch number {
        case 1...20:
            return "2"
        case 21...50:
            return "3"
        case 51...75:
            return "1"
        case 76...100:
            return "4"
        default:
            return "1"
        }
    }
}
