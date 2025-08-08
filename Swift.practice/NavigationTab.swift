// NavigationTab.swift

import SwiftUI

enum NavigationTab: String, CaseIterable {
    case home = "Home"
    case tutorial = "Tutorial"
    case calendar = "Calendar" // 新しいタブを追加
    
    var symbolName: String {
        switch self {
        case .home:
            return "house.fill"
        case .tutorial:
            return "book.fill"
        case .calendar:
            return "calendar" // カレンダーのアイコン
        }
    }
    
    var displayName: String {
        switch self {
        case .home:
            return "ホーム"
        case .tutorial:
            return "チュートリアル"
        case .calendar:
            return "カレンダー" // タブに表示する名前
        }
    }
}
