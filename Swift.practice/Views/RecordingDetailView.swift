import SwiftUI

struct RecordingDetailView: View {
    let recording: RecordingEntry
    @ObservedObject var audioRecorder: AudioRecorder
    @Environment(\.presentationMode) var presentationMode
    @State private var isExpanded = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー情報
                    headerSection
                    
                    // 音声再生コントロール
                    audioControlSection
                    
                    // 文字起こし結果
                    transcriptionSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("録音詳細")
            .navigationBarItems(
                trailing: Button("完了") {
                    audioRecorder.stopPlaying()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("録音日時")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(recording.dateString)
                .font(.title2)
                .fontWeight(.semibold)
            
            if recording.duration > 0 {
                Text("再生時間: \(formatDuration(recording.duration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var audioControlSection: some View {
        VStack(spacing: 16) {
            // 再生ボタン
            Button(action: {
                if audioRecorder.isPlaying {
                    audioRecorder.stopPlaying()
                } else {
                    audioRecorder.playRecording(from: recording.fileURL)
                }
            }) {
                HStack {
                    Image(systemName: audioRecorder.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 24))
                    Text(audioRecorder.isPlaying ? "停止" : "再生")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(audioRecorder.isPlaying ? Color.red : Color.blue)
                .cornerRadius(25)
            }
            
            // 波形またはファイル情報
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundColor(.blue)
                    Text(recording.fileName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                if FileManager.default.fileExists(atPath: recording.fileURL.path) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("ファイルが存在します")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("ファイルが見つかりません")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private var transcriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("文字起こし結果")
                    .font(.headline)
                Spacer()
                Button(action: {
                    isExpanded.toggle()
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }
            
            if isExpanded || recording.transcription.count <= 200 {
                Text(recording.transcription.isEmpty ? "文字起こし結果がありません" : recording.transcription)
                    .font(.body)
                    .lineSpacing(4)
                    .textSelection(.enabled)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(recording.transcription.prefix(200)) + "...")
                        .font(.body)
                        .lineSpacing(4)
                    
                    Button("続きを読む") {
                        isExpanded = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct RecordingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingDetailView(
            recording: RecordingEntry(
                fileName: "sample.m4a",
                transcription: "これはサンプルの文字起こし結果です。実際の録音内容がここに表示されます。長い文章の場合は折りたたみ表示になります。",
                duration: 120
            ),
            audioRecorder: AudioRecorder()
        )
    }
}