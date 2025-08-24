//VoicePitchModel.swift

import Foundation
import SwiftUI

// 変声の種類を定義
enum VoiceEffect: String, CaseIterable {
    case normal = "通常"
    case highPitch = "高い声"
    case lowPitch = "低い声"
    
    var pitch: Float {
        switch self {
        case .normal: return 0
        case .highPitch: return 500
        case .lowPitch: return -500
        }
    }
}

// ユーザーが設定したピッチを管理するモデル
class VoicePitchModel: ObservableObject {
    @Published var customPitch: Float {
        didSet {
            // ピッチが変更されたらUserDefaultsに保存
            UserDefaults.standard.set(customPitch, forKey: "savedCustomPitch")
        }
    }
    
    init() {
        // UserDefaultsから保存されたピッチを読み込む
        // 保存されていなければデフォルト値0.0を使用
        self.customPitch = UserDefaults.standard.float(forKey: "savedCustomPitch")
    }
}
