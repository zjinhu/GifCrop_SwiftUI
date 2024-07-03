//
//  View+.swift
//  ImageCrop
//
//  Created by FunWidget on 2024/7/1.
//

import SwiftUI

extension View {
    ///不支持竖屏大比例（显示超过范围）
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
