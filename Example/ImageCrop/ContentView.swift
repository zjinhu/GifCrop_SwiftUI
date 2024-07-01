//
//  ContentView.swift
//  ImageCrop
//
//  Created by FunWidget on 2024/6/25.
//

import SwiftUI
import GifCrop_SwiftUI
import BrickKit
struct ContentView: View {

    @State var gifData: Data?
    @State var isSheet: Bool = false
    var body: some View {
        VScrollStack {

            
            Button {
                isSheet.toggle()
            } label: {
                Text("点击进入")
            }
            
            if let gifData{
                GIFImage(source: .static(data: gifData))
            }
 
        }
        .padding()
        .cropGif(isAction: $isSheet, 
                 gifData: GifTool.gifData(name: "3"),
                 cropRate: .init(width: 16, height: 9)){ gif in
            gifData = gif
        }
 
    }
 
}

#Preview {
    ContentView()
}
