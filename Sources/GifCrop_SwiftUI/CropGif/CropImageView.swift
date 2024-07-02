//
//  CropView.swift
//  ImageCrop
//
//  Created by FunWidget on 2024/6/25.
//

import SwiftUI
import BrickKit
import Combine
import UIKit
struct CropImageView: View {
    @Environment(\.dismiss) var dismiss

    @State private var isActive = true
    @State private var counter: Int = 0
    @State private var currentIndex: Int = 0
    //正在缩放比例
    @State var zoomingAmount: CGFloat = 0
    //缩放比例
    @State var zoomAmount: CGFloat = 0.0
    //正在移动中的偏移位置
    @State var currentOffsetPosition: CGSize = .zero
    //记录上一次移动的位置
    @State var preOffsetPosition: CGSize = .zero
    //裁剪框距离屏幕的边距
    let cropPadding: CGFloat = 20
    
    @State private var rangeImages: [UIImage] = []
    //裁剪框宽度
    let cropWidth: CGFloat
    //裁剪框高度
    let cropHeight: CGFloat
    //裁剪宽高比
    let cropWHRate: Float
    //裁剪完成之后的回调
    let callback: (_ cropImages: [UIImage?]) -> Void
    let imageDuration: TimeInterval
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @State private var range: ClosedRange<Int>
    //当前图片
    let inputImages: [UIImage]
    @State private var currentImage: UIImage?
    
    init(cropRate: CGSize = .init(width: 1, height: 1),
         inputImages: [UIImage],
         imageDuration: TimeInterval = 0,
         callback: @escaping (_ cropImages: [UIImage?]) -> Void) {
        
        self.inputImages = inputImages
        self.callback = callback
        self.imageDuration = imageDuration
        
        if inputImages.isEmpty {
            print("Error: inputImages is empty.")
        }
        cropWHRate = Float(cropRate.width / cropRate.height)
        rangeImages = inputImages
        currentImage = inputImages.first
        timer = Timer.publish(every: imageDuration, on: .main, in: .common).autoconnect()
        range = 0...(inputImages.count > 0 ? inputImages.count - 1 : 0)
        //裁剪框支持的最大宽度
        let maxCropWidth = Screen.width - cropPadding * 2
        //裁剪框支持的最大高度
        let maxCropHidth = Screen.height - cropPadding * 2
        //支持的裁剪框最大宽高比
        let maxCropRate = Float(maxCropWidth / maxCropHidth)
        if maxCropRate > cropWHRate{
            //有足够的宽度容纳当前比例,则裁剪框高度取最大高度
            cropHeight = maxCropHidth
            cropWidth = maxCropHidth * CGFloat(cropWHRate)
        }else{
            //有足够的高度容纳当前比例,则裁剪框宽度取最大宽度
            cropWidth = maxCropWidth
            cropHeight = maxCropWidth / CGFloat(cropWHRate)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
            
            if let image = currentImage{
                Image(uiImage: image)
                    .resizable()
                    .scaleEffect(zoomAmount + zoomingAmount)
                    .scaledToFill()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: currentOffsetPosition.width, y: currentOffsetPosition.height)
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .clipped()
            }
            
            /* ---------------------------------------遮罩层---------------------------------------*/
            VStack{
                Spacer()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .opacity(0.8)
                Spacer()
                    .frame(width: cropWidth, height: cropHeight)
                Spacer()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .opacity(0.8)
            }
            HStack{
                Spacer()
                    .frame(width: cropPadding, height: cropHeight)
                    .background(.black)
                    .opacity(0.8)
                
                Spacer()
                
                Spacer()
                    .frame(width: cropPadding, height: cropHeight)
                    .background(.black)
                    .opacity(0.8)
            }
            /* ---------------------------------------遮罩层---------------------------------------*/
            //白色边框
            Spacer()
                .frame(width: cropWidth, height: cropHeight)
                .overlay(// 设置边框样式
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(.white, lineWidth: 1)
                )
        }
        .onReceive(timer) { _ in
            if isActive {
                counter = (counter + 1) % rangeImages.count
                currentImage = rangeImages[counter]
                currentIndex = counter + range.lowerBound
            }
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                timer = Timer.publish(every: imageDuration, on: .main, in: .common).autoconnect()
            } else {
                timer.upstream.connect().cancel()
            }
        }
        .gesture(
            MagnificationGesture()
                .onChanged { amount in
                    zoomingAmount = amount - 1
                }
                .onEnded { amount in
                    zoomAmount += zoomingAmount
                    if zoomAmount > 4.0 {
                        withAnimation {
                            zoomAmount = 4.0
                        }
                    }
                    zoomingAmount = 0
                    withAnimation {
                        fixCropImage()
                    }
                }
                .simultaneously(with: DragGesture()
                    .onChanged { value in
                        //加上newPosition的目的是让图片从上次的位置开始移动
                        currentOffsetPosition = CGSize(width: value.translation.width + preOffsetPosition.width,
                                                       height: value.translation.height + preOffsetPosition.height)
                    }
                    .onEnded { value in
                        //加上newPosition的目的是让图片从上次的位置开始移动
                        currentOffsetPosition = CGSize(width: value.translation.width + preOffsetPosition.width,
                                                       height: value.translation.height + preOffsetPosition.height)
                        preOffsetPosition = currentOffsetPosition
                        withAnimation {
                            fixCropImage()
                        }
                    }
                )
        )
        .overlay(alignment: .bottom){
            VStack{
                Button{
                    isActive.toggle()
                } label: {
                    if isActive{
                        Image(systemName: "pause.fill")
                    }else{
                        Image(systemName: "play.fill")
                    }
                }
                .foregroundColor(.white)
                .padding(15)
                .background(Color(hex: "222222"))
                .cornerRadius(8)
                
                RangeSlider(range: $range,
                            in: 0...inputImages.count-1,
                            step: 1,
                            distance: 2...inputImages.count-1)
                .cornerRadius(8)
                .frame(height: 50)
                .rangeSliderStyle(
                    HorizontalRangeSliderStyle(
                        track:
                            HorizontalRangeTrack(
                                view: Color.clear.border(Color.white, width: 5),
                                mask: RoundedRectangle(cornerRadius: 0)
                            )
                            .background(
                                TrimLineView(inputImages: inputImages,
                                             counter: $currentIndex,
                                             isActive: $isActive)
                            ),
                        lowerThumb: HalfCapsule()
                            .foregroundColor(.white)
                            .overlay(
                                Image(systemName: "chevron.compact.left")
                                    .foregroundColor(.black)
                            )
                            .shadow(radius: 3),
                        upperThumb: HalfCapsule()
                            .rotation(Angle(degrees: 180))
                            .foregroundColor(.white)
                            .overlay(
                                Image(systemName: "chevron.compact.right")
                                    .foregroundColor(.black)
                            )
                            .shadow(radius: 3),
                        lowerThumbSize: CGSize(width: 16, height: 50),
                        upperThumbSize: CGSize(width: 16, height: 50)
                    )
                )
                .padding(.horizontal, 16)
                .onChange(of: range) { newValue in
                    print("\(range)")
                    isActive = false
                    rangeImages = Array(inputImages[range])
                }
                
                HStack {
                    Button{
                        callback([])
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    
                    Spacer()
                    
                    Button{
                        onCropImage()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .padding(.bottom, 20)
        }
        .ignoresSafeArea()
        .onAppear(perform: fixCropImage)
        
    }
}

extension CropImageView {
    
    func fixCropImage() {
        guard let currentImage = currentImage else { return }
        //当前图片的尺寸
        let inputImageWidth = currentImage.size.width
        let inputImageHeight = currentImage.size.height
        // 当前图片的宽高比
        let inputImageWHRate: CGFloat = inputImageWidth / inputImageHeight
        //当前屏幕的宽高比
        let screenWHRate: CGFloat = Screen.width / Screen.height
        //没有缩放状态下的显示宽与高
        var displayW1: CGFloat
        var displayH1: CGFloat
        if inputImageWHRate > screenWHRate {
            //图片的宽高比大于屏幕的宽高比,则没有放大缩小的状态下,显示的宽度为屏幕宽度
            displayW1 = Screen.width
            displayH1 = displayW1 / inputImageWHRate
        } else {
            //图片的宽高比小于屏幕的宽高比,则没有放大缩小的状态下,显示的高度为屏幕的高度
            displayH1 = Screen.height
            displayW1 = displayH1 * inputImageWHRate
        }
        //允许最小的缩小比例
        let minZoomAmount: CGFloat
        if CGFloat(cropWHRate) > inputImageWHRate{
            //裁剪框宽高比大于图片宽高比,说明裁剪框有足够的宽度容纳图片的宽度,用宽度来计算最小缩放比例
            minZoomAmount = cropWidth / displayW1
        }else{
            minZoomAmount = cropHeight / displayH1
        }
        if zoomAmount < minZoomAmount{
            //手动缩小比例不能小于最小缩小比例
            zoomAmount = minZoomAmount
        }
        //拖动到边界计算
        let offsetMinHeight = (displayH1 * zoomAmount - cropHeight)/2
        if currentOffsetPosition.height < -offsetMinHeight{
            currentOffsetPosition = CGSize(width: currentOffsetPosition.width, height: -offsetMinHeight)
        }else if currentOffsetPosition.height > offsetMinHeight{
            currentOffsetPosition = CGSize(width: currentOffsetPosition.width, height: offsetMinHeight)
        }
        
        let offsetMinWidth = (displayW1 * zoomAmount - cropWidth)/2
        if currentOffsetPosition.width < -offsetMinWidth{
            currentOffsetPosition = CGSize(width: -offsetMinWidth, height: currentOffsetPosition.height)
        }else if currentOffsetPosition.width > offsetMinWidth{
            currentOffsetPosition = CGSize(width: offsetMinWidth, height: currentOffsetPosition.height)
        }
        preOffsetPosition = currentOffsetPosition
    }
    
    func onCropImage() {
        guard let currentImage = currentImage else { return }
        //当前图片的尺寸
        let inputImageWidth = currentImage.size.width
        let inputImageHeight = currentImage.size.height
        // 当前图片的宽高比
        let inputImageWHRate: CGFloat = inputImageWidth / inputImageHeight
        //当前屏幕的宽高比
        let screenWHRate: CGFloat = Screen.width / Screen.height
        //与实际尺寸相比,放大比例
        var displayZoomRate:CGFloat
        if inputImageWHRate > screenWHRate{
            //输入图片的宽高比大于屏幕的宽高比时
            displayZoomRate = inputImageWidth / (Screen.width * zoomAmount)
        }else{
            displayZoomRate = inputImageHeight / (Screen.height * zoomAmount)
        }
        //计算实际偏移像素
        let offsetWidthPX = cropWidth * displayZoomRate / 2 + currentOffsetPosition.width * displayZoomRate
        let x = (inputImageWidth/2) - offsetWidthPX//计算记过舍去小数
        //计算实际偏移像素
        let offsetHeightPX = cropHeight * displayZoomRate / 2 + currentOffsetPosition.height * displayZoomRate
        let y = (inputImageHeight/2) - offsetHeightPX//计算记过舍去小数
        
        let width = cropWidth * displayZoomRate
        let height = cropHeight * displayZoomRate
        
        var cropImages = [UIImage?]()
        for image in rangeImages{
            let cropImage = crop(from: image,
                                 croppedTo: CGRect(x: CGFloat(Int(x)),
                                                   y: CGFloat(Int(y)),
                                                   width: CGFloat(Int(width)),
                                                   height: CGFloat(Int(height))))
            cropImages.append(cropImage)
        }
        
        callback(cropImages)
    }
    
    private func crop(from image: UIImage, croppedTo rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        let drawRect = CGRect(x: -rect.origin.x,
                              y: -rect.origin.y,
                              width: image.size.width,
                              height: image.size.height)
        context?.clip(to: CGRect(x: 0,
                                 y: 0,
                                 width: rect.size.width,
                                 height: rect.size.height))
        image.draw(in: drawRect)
        let subImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return subImage
    }
}

//#Preview {
//    CropImageView(cropRate: .init(width: 1, height: 1),
//                  inputImages : [UIImage(named: "1")!,
//                                 UIImage(named: "2")!,
//                                 UIImage(named: "3")!,
//                                 UIImage(named: "4")!,
//                                 UIImage(named: "5")!,
//                                 UIImage(named: "6")!,
//                                 UIImage(named: "7")!,
//                                 UIImage(named: "8")!,
//                                 UIImage(named: "9")!,
//                                 UIImage(named: "10")!,
//                                 UIImage(named: "11")!,
//                                 UIImage(named: "12")!,
//                                 UIImage(named: "13")!,
//                                 UIImage(named: "14")!,
//                                 UIImage(named: "15")!,
//                                 UIImage(named: "16")!,
//                                 UIImage(named: "17")!],
//                  imageDuration: 0.1) { cropImages in
//        
//    }
//}
