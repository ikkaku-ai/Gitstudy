import SwiftUI

struct TutorialView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.8, green: 0.95, blue: 1.0).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        TutorialSection(
                            icon: "mic.circle.fill",
                            title: "音声録音",
                            description: "録音タブで録音ボタンをタップして、音声を録音できます。録音中は波形が表示されます。"
                        )
                        
                        TutorialSection(
                            icon: "text.bubble.fill",
                            title: "文字起こし",
                            description: "録音が完了すると、自動的に音声が文字に変換されます。変換された文字はマスコットの下に表示されます。"
                        )
                        
                        TutorialSection(
                            icon: "play.circle.fill",
                            title: "音声再生",
                            description: "ホームタブで表示された再生ボタンをタップすると、録音した音声を再生できます。"
                        )
                        
                        TutorialSection(
                            icon: "square.grid.2x2.fill",
                            title: "検索",
                            description: "カレンダーの日付を押すと、その日の一番古いカードに飛ぶ。"
                        )
                        
                        // 修正: 変声機能のチュートリアルを追加
                        TutorialSection(
                            icon: "waveform.circle.fill",
                            title: "変声機能",
                            description: "変声タブで録音した音声を、スライダーを使ってピッチ（音の高さ）を変えて再生できます。日々の記録には影響しません。"
                        )
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("チュートリアル")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct TutorialSection: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 10)
    }
}
