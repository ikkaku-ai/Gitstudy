import SwiftUI

struct HomeView: View {
    @EnvironmentObject var mascotData: MascotDataModel
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.8, green: 0.95, blue: 1.0).edgesIgnoringSafeArea(.all)
                
                VStack {
                    if mascotData.mascots.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("録音タブから音声を録音してみましょう")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            let groupedMascots = Dictionary(grouping: mascotData.mascots) { mascot in
                                (mascotData.mascots.count - mascot.displayCount) / 2
                            }
                            
                            ForEach(groupedMascots.keys.sorted(), id: \.self) { rowIndex in
                                let mascotsInCurrentRow = groupedMascots[rowIndex]!.sorted { $0.displayCount < $1.displayCount }
                                MascotRowView(mascotsInRow: mascotsInCurrentRow, rowIndex: rowIndex, audioRecorder: audioRecorder, speechRecognizer: speechRecognizer)
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}