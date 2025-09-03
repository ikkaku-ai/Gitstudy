// MARK: - RecordingView.swift

import SwiftUI
import AVFoundation
import Speech

struct RecordingView: View {
    @Binding var isPresented: Bool
    
    @EnvironmentObject var mascotData: MascotDataModel
    @EnvironmentObject var audioRecorder: AudioRecorder
    @EnvironmentObject var speechRecognizer: SpeechRecognizer
    
    @StateObject private var viewModel = RecordingViewModel()
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.8, green: 0.95, blue: 1.0).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    if viewModel.isRecording {
                        VStack(spacing: 20) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                                .scaleEffect(viewModel.isRecording ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.isRecording)
                            
                            Text("録音中...")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                            
                            WaveformView(audioLevels: viewModel.audioLevels)
                                .frame(height: 100)
                                .padding(.horizontal, 40)
                        }
                        .padding(.bottom, 100)
                    } else if viewModel.isProcessing {
                        ProgressView("文字起こし中...")
                            .padding()
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "mic.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                            
                            Text("録音を開始してください")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.isRecording {
                            Task {
                                let success = await viewModel.stopRecordingAndProcess()
                                if success {
                                    isPresented = false
                                }
                            }
                        } else {
                            viewModel.startRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(viewModel.isRecording ? Color.red : Color.blue)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(radius: 10)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("録音")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        viewModel.cancelRecording()
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        isPresented = false
                    }
                    .disabled(!viewModel.canComplete)
                }
            }
        }
        .alert("エラー", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "不明なエラーが発生しました")
        }
        .onAppear {
            viewModel.setup(audioRecorder: audioRecorder, 
                           speechRecognizer: speechRecognizer, 
                           mascotData: mascotData)
        }
    }
}
