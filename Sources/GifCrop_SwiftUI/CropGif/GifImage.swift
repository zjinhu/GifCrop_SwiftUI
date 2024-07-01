//
//  GifImage.swift
//  ImageCrop
//
//  Created by FunWidget on 2024/6/28.
//

import SwiftUI

public struct GifImage: UIViewRepresentable {
    private let data: Data?
    private let name: String?
    private let repetitions: Int?
    private let onComplete: (() -> Void)?
    
    public init(
        data: Data,
        repetitions: Int? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.data = data
        self.name = nil
        self.repetitions = repetitions
        self.onComplete = onComplete
    }
    
    public init(
        name: String,
        repetitions: Int? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.data = nil
        self.name = name
        self.repetitions = repetitions
        self.onComplete = onComplete
    }
    
    public func makeUIView(context: Context) -> UIGIFImage {
        if let data = data {
            return UIGIFImage(data: data, repetitions: repetitions, onComplete: onComplete)
        } else {
            return UIGIFImage(name: name ?? "", repetitions: repetitions, onComplete: onComplete)
        }
    }
    
    public func updateUIView(_ uiView: UIGIFImage, context: Context) {
        if let data = data {
            uiView.updateGIF(data: data, repetitions: repetitions, onComplete: onComplete)
        } else {
            uiView.updateGIF(name: name ?? "", repetitions: repetitions, onComplete: onComplete)
        }
    }
}

public class UIGIFImage: UIView {
    private let imageView = UIImageView()
    private var repetitions: Int? = nil
    private var onComplete: (() -> Void)? = nil
    private var data: Data?
    private var name: String?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(
        name: String,
        repetitions: Int? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.init()
        self.name = name
        initView()
    }
    
    convenience init(
        data: Data,
        repetitions: Int? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.init()
        self.data = data
        initView()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        self.addSubview(imageView)
    }
    
    func updateGIF(
        data: Data,
        repetitions: Int? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.repetitions = repetitions
        self.onComplete = onComplete
        updateWithImage {
            GifTool.gifImage(data: data)
        }
    }
    
    func updateGIF(
        name: String,
        repetitions: Int? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.repetitions = repetitions
        self.onComplete = onComplete
        updateWithImage {
            GifTool.gifImage(name: name)
        }
    }
    
    private func updateWithImage(_ getImage: @escaping () -> AnimationImages?) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let animationImages = getImage() {
                DispatchQueue.main.async {
                    CATransaction.begin()
                    CATransaction.setCompletionBlock {
                        self.onComplete?()
                    }
                    self.imageView.animationImages = animationImages.frames
                    self.imageView.animationDuration = animationImages.duration
                    self.imageView.animationRepeatCount = self.repetitions ?? Int.max
                    self.imageView.startAnimating()
                    CATransaction.commit()
                }
            } else {
                self.imageView.image = nil
            }
        }
    }
    
    private func initView(
        repetitions: Int? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        imageView.contentMode = .scaleAspectFill
        self.repetitions = repetitions
        self.onComplete = onComplete
    }
}

