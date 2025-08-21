// MARK: - RecordingCard.swift

import SwiftUI
import AVFoundation

struct RecordingCard: View {
    let mascotRecord: MascotRecord
    @EnvironmentObject var mascotData: MascotDataModel
    @EnvironmentObject var audioPlayerManager: AudioPlayerManager
    @EnvironmentObject var voicePitchModel: VoicePitchModel
    
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            
            // トップセクション：年月日と再生ボタン
            HStack(alignment: .top) {
                // 左上に小さく年月日を表示
                VStack(alignment: .leading) {
                    Text(formatDate(mascotRecord.recordingDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatTime(mascotRecord.recordingDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 右上に再生ボタン
                Button(action: {
                    if let url = mascotRecord.recordingURL {
                        if audioPlayerManager.isPlaying {
                            audioPlayerManager.stop()
                        } else {
                            audioPlayerManager.loadAudio(url: url)
                            audioPlayerManager.setPitch(voicePitchModel.customPitch)
                            audioPlayerManager.play()
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: audioPlayerManager.isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding([.leading, .trailing, .top])
            
            // 録音の文字起こし
            ScrollView(.vertical, showsIndicators: false) {
                Text(mascotRecord.transcriptionText.isEmpty ? "文字起こし中..." : mascotRecord.transcriptionText)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 65)
            
            Divider()
                .padding(.horizontal)
            
            // 喜怒哀楽の画像
            Image(mascotRecord.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding(.top)

            // アドバイス (スクロール可能に修正)
            ScrollView(.vertical, showsIndicators: false) {
                Text("💬 \(mascotRecord.adviceText)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(height: 40) // 高さ調整
            
            Spacer()
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 40, height: 350)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onDisappear {
            audioPlayerManager.stop()
        }
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
