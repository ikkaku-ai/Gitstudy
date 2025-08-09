import Foundation
import AVFoundation

class AudioPlayerManager: ObservableObject {
    @Published var isPlaying: Bool = false
    
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    private var pitch = AVAudioUnitTimePitch()
    private var audioFile: AVAudioFile?
    
    init() {
        setupAudioSession()
        setupAudioEngine()
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            print("✅ AVAudioSessionが設定されました。")
        } catch {
            print("❌ AVAudioSessionの設定に失敗しました: \(error.localizedDescription)")
        }
    }

    private func setupAudioEngine() {
        engine.attach(player)
        engine.attach(pitch)
        
        let mainMixer = engine.mainMixerNode
        let format = mainMixer.outputFormat(forBus: 0)
        
        engine.connect(player, to: pitch, format: format)
        engine.connect(pitch, to: mainMixer, format: format)
        
        do {
            try engine.start()
        } catch {
            print("❌ Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    func loadAudio(url: URL) {
        do {
            self.audioFile = try AVAudioFile(forReading: url)
            
            player.stop()
            player.scheduleFile(self.audioFile!, at: nil) {
                DispatchQueue.main.async {
                    self.isPlaying = false
                }
            }
        } catch {
            print("❌ Failed to load audio file: \(error.localizedDescription)")
        }
    }

    func play() {
        guard let _ = audioFile else {
            print("⚠️ 音声ファイルがロードされていません。")
            return
        }
        
        if !isPlaying {
            player.play()
            isPlaying = true
        }
    }

    func stop() {
        if isPlaying {
            player.stop()
            isPlaying = false
        }
    }
    
    func setPitch(_ newPitch: Float) {
        pitch.pitch = newPitch
    }
}
