//
//  View+.swift
//  ImageCrop
//
//  Created by FunWidget on 2024/7/1.
//

import SwiftUI

extension View {
    public func cropGif(isAction: Binding<Bool>,
                        gifData: Data?,
                        cropRate: CGSize = .init(width: 1, height: 1),
                        callback: @escaping (_ gif: Data?) -> Void) -> some View {
        self.modifier(CropGifModifier(isAction: isAction, 
                                      gifData: gifData,
                                      cropRate: cropRate,
                                      callback: callback))
    }
}
