import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioLevels: [Float] = []
    @Published var recordingURL: URL?
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("オーディオセッションの設定に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = documentsPath.appendingPathComponent("\(Date().timeIntervalSince1970).m4a")
        
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
        } catch {
            print("録音の開始に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopMetering()
        
        if let url = recordingURL {
            print("録音ファイルが保存されました: \(url.path)")
        }
    }
    
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
    
    private func stopMetering() {
        timer?.invalidate()
        timer = nil
        audioLevels.removeAll()
    }
    
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
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("録音が正常に完了しました")
        } else {
            print("録音が失敗しました")
        }
    }
}