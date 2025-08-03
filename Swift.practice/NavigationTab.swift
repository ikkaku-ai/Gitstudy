import SwiftUI

enum NavigationTab: String, CaseIterable {
    case home = "Home"
    case tutorial = "Tutorial"
    
    var symbolName: String {
        switch self {
        case .home:
            return "house.fill"
        case .tutorial:
            return "book.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .home:
            return "ホーム"
        case .tutorial:
            return "チュートリアル"
        }
    }
}