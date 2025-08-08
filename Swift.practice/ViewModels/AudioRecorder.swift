import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var audioLevels: [Float] = []
    @Published var recordingURL: URL?
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // オーディオセッションの初期設定
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // 録音と再生の両方に対応するカテゴリを設定
            // この設定を最初に行うことで、再生時に再設定する必要がなくなります。
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("❌ オーディオセッションの設定に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 録音の開始
    func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            recordingURL = audioFileName
            
            startMetering()
            print("🔊 録音を開始しました")
        } catch {
            print("❌ 録音の開始に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 録音の停止
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopMetering()
        
        if let url = recordingURL {
            print("✅ 録音ファイルが保存されました: \(url.path)")
        }
    }
    
    // 音量レベルの監視を開始
    private func startMetering() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.audioRecorder?.updateMeters()
            
            if let recorder = self.audioRecorder {
                let power = recorder.averagePower(forChannel: 0)
                let normalizedPower = self.normalizeSoundLevel(level: power)
                
                DispatchQueue.main.async {
                    self.audioLevels.append(normalizedPower)
                    if self.audioLevels.count > 50 {
                        self.audioLevels.removeFirst()
                    }
                }
            }
        }
    }
    
    // 音量レベルの監視を停止
    private func stopMetering() {
        timer?.invalidate()
        timer = nil
        audioLevels.removeAll()
    }
    
    // 音量レベルを正規化
    private func normalizeSoundLevel(level: Float) -> Float {
        let minDb: Float = -60
        let maxDb: Float = 0
        
        if level < minDb {
            return 0.0
        } else if level > maxDb {
            return 1.0
        } else {
            return (level - minDb) / (maxDb - minDb)
        }
    }
    
    // 録音の再生
    func playRecording(from url: URL) {
        do {
            // オーディオセッションは既に適切に設定されているため、再設定は不要
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            print("✅ 再生を開始しました: \(url.path)")
        } catch {
            print("❌ 再生の開始に失敗しました: \(error.localizedDescription)")
            // 失敗した場合も状態をリセット
            DispatchQueue.main.async {
                self.isPlaying = false
            }
        }
    }
    
    // 再生の停止
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
        // UI更新はメインスレッドで
        DispatchQueue.main.async {
            self.isPlaying = false
        }
        print("⏸️ 再生を停止しました")
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("✅ 録音が正常に完了しました")
        } else {
            print("❌ 録音が失敗しました")
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // UI更新はメインスレッドで
        DispatchQueue.main.async {
            self.isPlaying = false
        }
        print("✅ 再生が終了しました")
    }
}
