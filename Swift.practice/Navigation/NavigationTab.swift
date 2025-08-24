// NavigationTab.swift

import SwiftUI

enum NavigationTab: String, CaseIterable {
    case home = "Home"
    case tutorial = "Tutorial"
    case calendar = "Calendar"
    case voiceChanger = "VoiceChanger" // 新しいタブを追加
    
    var symbolName: String {
        switch self {
        case .home:
            return "house.fill"
        case .tutorial:
            return "book.fill"
        case .calendar:
            return "calendar"
        case .voiceChanger:
            return "waveform.circle.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .home:
            return "ホーム"
        case .tutorial:
            return "チュートリアル"
        case .calendar:
            return "カレンダー"
        case .voiceChanger:
            return "変声" // タブに表示する名前
        }
    }
}
