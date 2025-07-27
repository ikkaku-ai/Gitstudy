//
//  ContentView.swift
//  Swift.practice
//
//  Created by 藤井陽樹 on 2025/07/26.
//

import SwiftUI

// マスコットの情報を保持する構造体
struct DisplayMascot: Identifiable {
    let id = UUID()
    let imageName: String
    let displayCount: Int
}

// MARK: - 新しく追加するマスコットの行を表示するView
struct MascotRowView: View {
    let mascotsInRow: [DisplayMascot] // この行に表示するマスコットの配列
    let rowIndex: Int // 行のインデックス（パディング調整用）

    var body: some View {
        HStack {
                    // この行のマスコットを displayCount でソートし、奇数番目と偶数番目のマスコットを見つける
                    // (displayCount が小さい方が古いマスコット)
                    let sortedMascots = mascotsInRow.sorted { $0.displayCount < $1.displayCount }
                    let oddMascot = sortedMascots.first(where: { $0.displayCount % 2 == 1 })
                    let evenMascot = sortedMascots.first(where: { $0.displayCount % 2 == 0 })

                    if oddMascot != nil && evenMascot != nil {
                        // 奇数と偶数の両方のマスコットが存在する場合（完全なペア）
                        MascotImageView(mascot: oddMascot!) // 奇数は左
                        Spacer().frame(width: 20) // 画像間の隙間
                        MascotImageView(mascot: evenMascot!) // 偶数は右
                    } else if let singleMascot = oddMascot ?? evenMascot {
                        // マスコットが1つだけの場合（奇数または偶数）は中央に配置
                        Spacer()
                        MascotImageView(mascot: singleMascot)
                        Spacer()
                    } else {
                        // このケースは通常発生しないはず
                        EmptyView()
                    }
                }
        // 行間の隙間 (2行目以降に適用)
        .padding(.vertical, (rowIndex == 0) ? 0 : 10)
    }
}

// MARK: - 個々のマスコット画像を表示するヘルパーView
struct MascotImageView: View {
    let mascot: DisplayMascot
    
    var body: some View {
        ZStack {
            Image(mascot.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .shadow(radius: 10)
            
            // MARK: - ここにカウントの数字を表示
            //ここにAI要約を書くようにする
            Text("\(mascot.displayCount)") // displayCountを表示
                .font(.caption) // 小さめのフォント
                .fontWeight(.bold)
                .foregroundColor(.red) // 赤色で表示
                .padding(.horizontal, 8) // 背景の横パディング
                .padding(.vertical, 4)// 背景の縦パディング
                .offset(y: 50) // 画像の下に少しずらす
            
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @State var isrecording = false
    @State private var count = 0
    @State private var showMascot: [DisplayMascot] = [] // 表示するマスコットのリスト

    var body: some View {
        ZStack {
            Color.yellow.edgesIgnoringSafeArea(.all)

            VStack {
                ScrollView {
                    // マスコットを2つずつ行にグループ化
                    let groupedMascots = Dictionary(grouping: showMascot) { mascot in
                        // (全体の数　- 現在のマスコットの表示順) / 2
                        // この計算により、displayCountが大きい順（つまり新しい順）マスコットほど、
                        // rowIndexの値が小さくなります。
                        (showMascot.count - mascot.displayCount) / 2
                    }

                    // 行インデックスでソートすることで、新しい行から古い行へと表示される
                    //ForEachループは、rowIndexの小さい順（0, 1, 2・・・）に処理をします。
                    //そのため、rowIndex = 0の行（最新のマスコットを含む行）が最初に描画され、
                    //ScrollViewの一番上に表示されます。
                    ForEach(groupedMascots.keys.sorted(), id: \.self) { rowIndex in
                        // 各行のマスコットを displayCount でソートして MascotRowView に渡す
                        // これにより、MascotRowView 内での leftMascot/rightMascot の判定が正しく行われる
                        let mascotsInCurrentRow = groupedMascots[rowIndex]!.sorted { $0.displayCount < $1.displayCount }
                        MascotRowView(mascotsInRow: mascotsInCurrentRow, rowIndex: rowIndex)
                    }
                }
                .frame(maxHeight: .infinity) // ScrollViewがVStackの残りのスペースを埋めるように
                .padding(.top, 20) // 上からの余白

                Spacer() // これにより、ボタンは画面下部に固定されます

                Button {
                    isrecording = true
                } label: {
                    Text("録音")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                        .background(Capsule().fill(Color.gray))
                        .shadow(radius: 5)
                }
                .padding(.bottom, 40)
                .alert("録音を開始しますか？", isPresented: $isrecording) {
                    Button("いいえ", role: .cancel){
                        isrecording = false
                    }
                    Button("はい"){
                        print("録音を開始します！")
                        isrecording = false
                        count += 1 // 録音回数をインクリメント

                        // 新しいマスコットをリストに追加
                        // "heartdog" は Assets.xcassets に入っている画像名に置き換えてください
                        showMascot.append(DisplayMascot(imageName: "heartdog", displayCount: count))
                    }
                }message: {
                    Text("録音をすると記録に残ります。")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
