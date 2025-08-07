import SwiftUI

struct RecordingCard: View {
    let mascotRecord: MascotRecord
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var mascotData: MascotDataModel
    @State private var isPlaying = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // メインヘッダー：日付、画像、再生ボタン
            HStack(alignment: .center, spacing: 16) {
                
                // 日付を表示
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
                
                // 画像をそのまま表示
                Image(mascotRecord.imageName)
                    .resizable()
                    .frame(width: 90, height: 90)

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
                    // 文字起こし結果
                    Text(mascotRecord.transcriptionText.isEmpty ? "文字起こし中..." : mascotRecord.transcriptionText)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Geminiからの要約とアドバイス
                    VStack(alignment: .leading, spacing: 4) {
                        Text("要約：\(mascotRecord.summary)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // アドバイス
                        Text("アドバイス：\(mascotRecord.adviceText)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 40, height: 300)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onLongPressGesture {
            showDeleteConfirmation = true
        }
        .alert("この録音を消去しますか？", isPresented: $showDeleteConfirmation) {
            Button("消去", role: .destructive) {
                mascotData.removeMascotRecord(withId: mascotRecord.id)
            }
            Button("キャンセル", role: .cancel) {
                // 何もしない
            }
        } message: {
            Text("この操作は取り消せません。")
        }
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
