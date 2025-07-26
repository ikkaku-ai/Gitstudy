//
//  ContentView.swift
//  Swift.practice
//
//  Created by 藤井陽樹 on 2025/07/26.
//

import SwiftUI

struct ContentView: View {
    @State var isrecording = false
    var body: some View {
        ZStack{
            Color.yellow.edgesIgnoringSafeArea(.all)
            
            VStack{
                Spacer()
                
                Button{
                    isrecording = true
                }label:{
                    Text("録音")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                        .background(Capsule().fill(Color.gray))
                        .shadow(radius: 5)
                }
                .padding(.bottom, 50)
                .alert("録音を開始しますか？", isPresented: $isrecording) {
                    Button("いいえ"){
                        isrecording = false
                    }
                    Button("はい"){
                        print("録音を開始します！")
                        isrecording = false
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
