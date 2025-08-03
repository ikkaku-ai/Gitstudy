import SwiftUI

struct RecordingCard: View {
    let mascot: DisplayMascot
    @EnvironmentObject var audioRecorder: AudioRecorder
    @State private var isPlaying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(mascot.imageName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(mascot.recordingDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(mascot.recordingDate))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button(action: {
                    if let url = mascot.recordingURL {
                        if audioRecorder.isPlaying {
                            audioRecorder.stopPlaying()
                        } else {
                            audioRecorder.playRecording(from: url)
                        }
                    }
                }) {
                    Image(systemName: audioRecorder.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("要約")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(mascot.summary.isEmpty ? "要約を生成中..." : mascot.summary)
                    .font(.subheadline)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            if !mascot.transcriptionText.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("文字起こし")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(mascot.transcriptionText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .frame(width: 280, height: 200)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}