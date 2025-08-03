import SwiftUI

enum NavigationTab: String, CaseIterable {
    case home = "Home"
    case recording = "Recording"
    case tutorial = "Tutorial"
    
    var symbolName: String {
        switch self {
        case .home:
            return "house.fill"
        case .recording:
            return "mic.fill"
        case .tutorial:
            return "book.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .home:
            return "ホーム"
        case .recording:
            return "録音"
        case .tutorial:
            return "チュートリアル"
        }
    }
}