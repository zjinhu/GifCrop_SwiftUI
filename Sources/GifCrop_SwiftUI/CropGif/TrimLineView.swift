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
        GeometryReader{ geometry in
            HStack(spacing: 0){
                ForEach(0..<inputImages.count, id: \.self) { index in
                    ZStack(alignment: .leading){
                        Image(uiImage: inputImages[index])
                            .resizable()
                            .scaledToFill()
                            .width(geometry.size.width/CGFloat(inputImages.count))
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
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color(hex: "222222"), lineWidth: 5)
            )
            .overlay(alignment: .leading){
                HalfCapsule() 
                    .width(16)
                    .foregroundColor(Color(hex: "222222"))
            }
            .overlay(alignment: .trailing){
                HalfCapsule()
                    .rotation(Angle(degrees: 180))
                    .width(16)
                    .foregroundColor(Color(hex: "222222"))
            }
        }
    }
}
 
#Preview {
    TrimLineView(inputImages :
                    [
                        UIImage(named: "1")!,
                        UIImage(named: "2")!,
                        UIImage(named: "3")!,
                        UIImage(named: "4")!,
                        UIImage(named: "5")!,
                        UIImage(named: "6")!,
                        UIImage(named: "7")!,
                        UIImage(named: "8")!,
                        UIImage(named: "9")!,
                        UIImage(named: "10")!,
                        UIImage(named: "11")!,
                        UIImage(named: "12")!,
                        UIImage(named: "13")!,
                        UIImage(named: "14")!,
                        UIImage(named: "15")!,
                        UIImage(named: "16")!,
                        UIImage(named: "17")!,
                        UIImage(named: "18")!,
                        UIImage(named: "19")!,
                        UIImage(named: "20")!,
                    ],
                 counter: .constant(5),
                 isActive: .constant(true)
    )
    .height(50)
    .padding()
}
