import SwiftUI

struct FloatingRecordButton: View {
    @Binding var showRecordingView: Bool
    // @State private var isAnimating = false // この行を削除
    
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
        // .scaleEffect(isAnimating ? 1.1 : 1.0) // この行を削除
        // .onAppear { // このブロック全体を削除
        //     withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
        //         isAnimating = true
        //     }
        // }
    }
}
