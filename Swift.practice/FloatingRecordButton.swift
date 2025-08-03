import SwiftUI

struct FloatingRecordButton: View {
    @Binding var showRecordingView: Bool
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {
            showRecordingView = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 65, height: 65)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isAnimating ? 1.1 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}