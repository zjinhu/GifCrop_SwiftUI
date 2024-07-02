//
//  CropGifTool.swift
//  ImageCrop
//
//  Created by FunWidget on 2024/6/28.
//

import UIKit
import ImageIO
import MobileCoreServices
public struct AnimationImages {
    let frames: [UIImage]
    let duration: Double
}

public struct GifTool {
 
    public static func gifImage(data: Data) async -> AnimationImages? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let animationImages = gifImage(data: data)
                continuation.resume(returning: animationImages)
            }
        }
    }
    
    public static func gifImage(data: Data) -> AnimationImages? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil)
        else {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        let delays = (0..<count).map {
            // store in ms and truncate to compute GCD more easily
            Int(delayForImage(at: $0, source: source) * 1000)
        }
        let duration = delays.reduce(0, +)
        let gcd = delays.reduce(0, gcd)
        
        var frames = [UIImage]()
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let frame = UIImage(cgImage: cgImage)
                let frameCount = delays[i] / gcd
                
                for _ in 0..<frameCount {
                    frames.append(frame)
                }
            } else {
                return nil
            }
        }
        
        return AnimationImages(frames: frames, duration: Double(duration) / 1000.0)
    }
    
    public static func gifImage(name: String) -> AnimationImages? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        return gifImage(data: data)
    }
    
    public static func gifData(name: String) -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        return data
    }
    
    static func createGIF(with images: [UIImage?],
                   frameDelay: TimeInterval,
                   loopCount: Int = 0) -> Data? {
        guard !images.isEmpty else { return nil }
        
        let fileProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]
        ]
        
        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: frameDelay
            ]
        ]
        
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, kUTTypeGIF, images.count, nil) else { return nil }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        for image in images {
            if let cgImage = image?.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return data as Data
    }
    
}

private func gcd(_ a: Int, _ b: Int) -> Int {
    let absB = abs(b)
    let r = abs(a) % absB
    if r != 0 {
        return gcd(absB, r)
    } else {
        return absB
    }
}

private func delayForImage(at index: Int, source: CGImageSource) -> Double {
    let defaultDelay = 1.0
    
    let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
    let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
    defer {
        gifPropertiesPointer.deallocate()
    }
    let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
    if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
        return defaultDelay
    }
    let gifProperties = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
    var delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                          Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                                     to: AnyObject.self)
    if delayWrapper.doubleValue == 0 {
        delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                          Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                                     to: AnyObject.self)
    }
    
    if let delay = delayWrapper as? Double,
       delay > 0 {
        return delay
    } else {
        return defaultDelay
    }
}

