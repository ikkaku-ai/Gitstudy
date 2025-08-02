import SwiftUI

struct RecordingListView: View {
    @StateObject private var dataManager = RecordingDataManager()
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var showingRecordingSheet = false
    @State private var selectedRecording: RecordingEntry?
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.recordings.isEmpty {
                    emptyStateView
                } else {
                    recordingsList
                }
            }
            .navigationTitle("録音日記")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingRecordingSheet = true
                    }) {
                        Image(systemName: "mic.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingRecordingSheet) {
                RecordingView(
                    audioRecorder: audioRecorder,
                    speechRecognizer: speechRecognizer,
                    dataManager: dataManager
                )
            }
            .sheet(item: $selectedRecording) { recording in
                RecordingDetailView(recording: recording, audioRecorder: audioRecorder)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("録音がありません")
                .font(.title2)
                .foregroundColor(.gray)
            Text("右上のボタンをタップして\n最初の録音を始めましょう")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var recordingsList: some View {
        List {
            ForEach(dataManager.recordings) { recording in
                RecordingRowView(recording: recording)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedRecording = recording
                    }
            }
            .onDelete(perform: dataManager.deleteRecording)
        }
        .listStyle(PlainListStyle())
    }
}

struct RecordingRowView: View {
    let recording: RecordingEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recording.dateString)
                    .font(.headline)
                Spacer()
                Image(systemName: "waveform")
                    .foregroundColor(.blue)
            }
            
            Text(recording.transcriptionPreview)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }
}

struct RecordingView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @ObservedObject var dataManager: RecordingDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 波形表示
                if audioRecorder.isRecording {
                    WaveformView(audioLevels: audioRecorder.audioLevels)
                        .frame(height: 100)
                        .padding(.horizontal)
                }
                
                // 録音時間表示
                Text(formatDuration(recordingDuration))
                    .font(.system(size: 48, weight: .thin, design: .monospaced))
                    .foregroundColor(audioRecorder.isRecording ? .red : .primary)
                
                // 録音ボタン
                Button(action: {
                    if audioRecorder.isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(audioRecorder.isRecording ? Color.red : Color.blue)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                
                // 文字起こし状態表示
                if speechRecognizer.isTranscribing {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("文字起こし中...")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("録音")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func startRecording() {
        audioRecorder.startRecording()
        recordingDuration = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingDuration += 0.1
        }
    }
    
    private func stopRecording() {
        timer?.invalidate()
        timer = nil
        audioRecorder.stopRecording()
        
        // 文字起こしを開始
        if let recordingURL = audioRecorder.recordingURL {
            Task {
                let authorized = await speechRecognizer.requestAuthorization()
                if authorized {
                    await speechRecognizer.transcribeAudio(from: recordingURL)
                    
                    // 録音データを保存
                    let fileName = recordingURL.lastPathComponent
                    let entry = RecordingEntry(
                        fileName: fileName,
                        transcription: speechRecognizer.transcriptionResult.isEmpty ? "文字起こしできませんでした" : speechRecognizer.transcriptionResult,
                        duration: recordingDuration
                    )
                    dataManager.saveRecording(entry)
                    
                    presentationMode.wrappedValue.dismiss()
                } else {
                    // 権限がない場合でも保存
                    let fileName = recordingURL.lastPathComponent
                    let entry = RecordingEntry(
                        fileName: fileName,
                        transcription: "音声認識の権限がありません",
                        duration: recordingDuration
                    )
                    dataManager.saveRecording(entry)
                    
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
    }
}