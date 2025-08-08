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
    var summary: String
    var adviceText: String = "" // コメントとして使用
    
    // 修正: ファイル名からURLを動的に生成するコンピューテッドプロパティ
    var recordingURL: URL? {
        guard let filename = recordingFilename else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(filename)
    }
}

// Gemini APIからのレスポンスをデコードするための構造体
struct GeminiCommentResponse: Codable {
    let comment: String
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

    func addMascotRecord(imageName: String, recordingURL: URL?, transcriptionText: String = "", summary: String = "", adviceText: String = "") {
        let newRecord = MascotRecord(
            imageName: imageName,
            displayCount: mascotRecords.count + 1,
            // 修正: URLからファイル名のみを抽出して保存
            recordingFilename: recordingURL?.lastPathComponent,
            transcriptionText: transcriptionText,
            recordingDate: Date(),
            summary: summary,
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
        let number = generateNumber(from: transcriptionText)
        let summary = generateSummary(from: transcriptionText, number: number)
        let imageName = self.imageName(for: number) ?? "1"
        
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
                    summary: summary,
                    adviceText: "コメントを生成中..."
                )
                self.mascotRecords[index] = updatedRecord
            }
        }
        
        let comment = await generateCommentWithGemini(from: transcriptionText, emotionSummary: summary, emotionNumber: number)
        
        DispatchQueue.main.async {
            // 修正: ファイル名で一致するレコードを検索
            if let index = self.mascotRecords.firstIndex(where: { $0.recordingFilename == recordingURL.lastPathComponent }) {
                let existingRecord = self.mascotRecords[index]
                let updatedRecord = MascotRecord(
                    imageName: existingRecord.imageName,
                    displayCount: existingRecord.displayCount,
                    recordingFilename: existingRecord.recordingFilename,
                    transcriptionText: existingRecord.transcriptionText,
                    recordingDate: existingRecord.recordingDate,
                    summary: existingRecord.summary,
                    adviceText: comment
                )
                self.mascotRecords[index] = updatedRecord
                print("✅ コメントがGeminiで更新されました: \(comment)")
                
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
    
    private func generateSummary(from text: String, number: Int) -> String {
        switch number {
        case 1...20:
            return "怒りや不満"
        case 21...50:
            return "悲しみや辛さ"
        case 51...75:
            return "普通"
        case 76...100:
            return "喜びや楽しさ"
        default:
            return "感情不明"
        }
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

    private func generateCommentWithGemini(from text: String, emotionSummary: String, emotionNumber: Int) async -> String {
        let prompt = """
        ユーザーから「\(text)」という音声入力がありました。この入力は「\(emotionSummary)」という感情と判断されました。
        この感情とテキストの内容に基づき、親しみやすい対話形式で、一言の感想や共感を示すセリフを50文字以内で作成してください。
        ただし、「うんうん、そうだね」という表現は使わないでください。

        例1（喜び）: ユーザー「今日、テストで満点取れたんだ！」 → 返答「すごい！努力が報われたね、よかった！」
        例2（悲しみ）: ユーザー「最近元気が出ないんだ...」 → 返答「そっか、辛かったね。無理しないでね。」
        例3（不満）: ユーザー「また上司に怒られちゃった」 → 返答「それはひどいね...何かあったら聞くよ。」

        JSON形式で'{ "comment": "すごい！努力が報われたね、よかった！" }'のように返してください。
        """
        
        do {
            print("▶️ Geminiへのコメント生成リクエストを開始します。")
            print("プロンプト内容:\n\(prompt)")
            
            let response = try await geminiModel.generateContent(prompt)

            guard let responseText = response.text else {
                print("❌ Geminiからのレスポンスにテキストが含まれていませんでした。")
                return getFallbackComment(for: emotionNumber)
            }
            
            print("✅ Geminiからの生のレスポンス:\n\(responseText)")

            guard let data = responseText.data(using: .utf8) else {
                print("❌ Geminiからのレスポンスをデータに変換できませんでした。")
                return getFallbackComment(for: emotionNumber)
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(GeminiCommentResponse.self, from: data)
            return result.comment
            
        } catch {
            print("❌ Gemini APIコメント生成エラーが発生しました。")
            print("エラーの詳細: \(error)")
            return getFallbackComment(for: emotionNumber)
        }
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
