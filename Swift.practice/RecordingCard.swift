import SwiftUI

struct RecordingCard: View {
    let mascotRecord: MascotRecord
    @EnvironmentObject var audioRecorder: AudioRecorder
    @State private var isPlaying = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // メインヘッダー：日付、画像、再生ボタン
            HStack(alignment: .center, spacing: 16) {
                
                // 日付を表示 (VStack)
                VStack(alignment: .leading, spacing: 6) {
                    Text(formatDate(mascotRecord.recordingDate))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(formatTime(mascotRecord.recordingDate))
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 画像をそのまま表示 (Image)
                Image(mascotRecord.imageName)
                    .resizable()
                    .frame(width: 80, height: 80)

                Spacer()

                // 再生ボタン
                Button(action: {
                    if let url = mascotRecord.recordingURL {
                        if audioRecorder.isPlaying {
                            audioRecorder.stopPlaying()
                        } else {
                            audioRecorder.playRecording(from: url)
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 70, height: 70)

                        Image(systemName: audioRecorder.isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ScrollView(.vertical, showsIndicators: false) {
                    Text(mascotRecord.transcriptionText.isEmpty ? "文字起こし中..." : mascotRecord.transcriptionText)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 40, height: 300)
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
