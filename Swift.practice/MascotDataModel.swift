import SwiftUI

class MascotDataModel: ObservableObject {
    @Published var mascots: [DisplayMascot] = []
    @Published var count: Int = 0
    
    func addMascot(imageName: String, recordingURL: URL?, transcriptionText: String = "") {
        count += 1
        let newMascot = DisplayMascot(
            imageName: imageName,
            displayCount: count,
            recordingURL: recordingURL,
            transcriptionText: transcriptionText
        )
        mascots.append(newMascot)
    }
    
    func updateMascotTranscription(for recordingURL: URL, transcriptionText: String) {
        if let index = mascots.lastIndex(where: { $0.recordingURL == recordingURL }) {
            let updatedMascot = DisplayMascot(
                imageName: mascots[index].imageName,
                displayCount: mascots[index].displayCount,
                recordingURL: mascots[index].recordingURL,
                transcriptionText: transcriptionText
            )
            mascots[index] = updatedMascot
        }
    }
}