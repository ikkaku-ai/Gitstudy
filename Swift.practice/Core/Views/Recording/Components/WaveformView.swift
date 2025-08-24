import SwiftUI

struct WaveformView: View {
    let audioLevels: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 2) {
                ForEach(audioLevels.indices, id: \.self) { index in
                    BarView(value: audioLevels[index], height: geometry.size.height)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 100)
        .background(Color.black.opacity(0.1))
        .cornerRadius(10)
    }
}

struct BarView: View {
    let value: Float
    let height: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .bottom,
                endPoint: .top
            ))
            .frame(width: 4, height: CGFloat(value) * height * 0.8)
            .animation(.easeInOut(duration: 0.05), value: value)
    }
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView(audioLevels: [0.1, 0.3, 0.5, 0.7, 0.4, 0.2, 0.6, 0.8, 0.3, 0.1])
            .padding()
    }
}