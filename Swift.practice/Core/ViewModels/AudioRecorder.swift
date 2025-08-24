// MARK: - AudioRecorder.swift

import Foundation
import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    
    @Published var isRecording = false
    @Published var audioLevels: [Float] = []
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession?
    private var levelTimer: Timer?
    
    var lastRecordingURL: URL?

    override init() {
        super.init()
        setupSession()
    }
    
    func setupSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try recordingSession?.setActive(true)
        } catch {
            print("❌ Failed to set up recording session: \(error.localizedDescription)")
        }
    }

    func startRecording() {
        recordingSession?.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.performStartRecording()
                } else {
                    print("❌ Recording permission denied.")
                }
            }
        }
    }
    
    private func performStartRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            audioLevels = [] // 録音開始時に波形データをリセット
            
            levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateAudioLevels()
            }
        } catch {
            print("❌ Failed to set up audio recorder: \(error.localizedDescription)")
            stopRecording()
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        levelTimer?.invalidate()
        isRecording = false
        
        if let url = audioRecorder?.url {
            lastRecordingURL = url
            print("✅ Recording stopped. File saved at: \(url.path)")
        } else {
            print("❌ Recording stopped, but URL is nil.")
        }
    }
    
    private func updateAudioLevels() {
        audioRecorder?.updateMeters()
        
        if let level = audioRecorder?.averagePower(forChannel: 0) {
            let normalizedLevel = min(1.0, max(0.0, (level + 50) / 50))
            audioLevels.append(normalizedLevel)
            
            if audioLevels.count > 40 { // 波形の長さを調整
                audioLevels.removeFirst()
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("❌ Audio recorder failed to finish successfully.")
        }
    }
}
