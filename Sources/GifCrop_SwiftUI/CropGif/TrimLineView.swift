//
//  SwiftUIView.swift
//  
//
//  Created by FunWidget on 2024/7/2.
//

import SwiftUI
import BrickKit

struct TrimLineView: View {
    let inputImages: [UIImage]
    @Binding var counter: Int
    @Binding var isActive: Bool
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0){
            ForEach(0..<inputImages.count, id: \.self) { index in
                ZStack(alignment: .leading){
                    Image(uiImage: inputImages[index])
                        .resizable()
                        .scaledToFill()
                        .width((Screen.width-36)/CGFloat(inputImages.count))
                        .clipped()
                    
                    if counter == index, isActive{
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.white)
                            .matchedGeometryEffect(id: "MatchedGeometryEffest", in: namespace)
                            .frame(width: 2, height: 40)
                    }
                }
            }
        }
    }
}
 
