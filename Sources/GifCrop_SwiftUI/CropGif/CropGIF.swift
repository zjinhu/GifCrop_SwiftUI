//
//  SwiftUIView.swift
//  
//
//  Created by FunWidget on 2024/7/1.
//

import SwiftUI
import BrickKit

class CropGifModel: ObservableObject{
    @Published var isPresented: Bool = false
    @Published var isLoading: Bool = false
    @Published var images: AnimationImages?
}

struct CropGifModifier: ViewModifier {
    
    @StateObject var model = CropGifModel()
    @Binding var isAction: Bool
    let gifData: Data?
    let callback: (_ gif: Data?) -> Void
    let cropRate: CGSize
    
    init(isAction: Binding<Bool>,
         gifData: Data?,
         cropRate: CGSize = .init(width: 1, height: 1),
         callback:@escaping (_ gif: Data?) -> Void) {
        _isAction = isAction
        self.cropRate = cropRate
        self.gifData = gifData
        self.callback = callback
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isAction){ newValue in
                
                Task{
                    if let gifData{
                        await MainActor.run {
                            model.isLoading = true
                        }
                        model.images = await GifTool.gifImage(data: gifData)
                        await MainActor.run {
                            model.isPresented.toggle()
                        }
                    }
                }
            }
            .overlay{
                if model.isLoading{
                    ZStack{
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .tintColor(.black)
                            .padding(25)
                            .background(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .fullScreenCover(isPresented: $model.isPresented){
                if let info = model.images{
                    CropImageView(cropRate: cropRate,
                                  inputImages : info.frames,
                                  imageDuration: info.duration/Double(info.frames.count)){ crops in
                        if !crops.isEmpty{
                            callback(GifTool.createGIF(with: crops, frameDelay: info.duration/Double(info.frames.count)))
                        }
                        model.isPresented.toggle()
                        model.isLoading = false
                    }
                }
            }
    }
}
