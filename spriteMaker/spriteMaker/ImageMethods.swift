//
//  ImageMethods.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/24.
//

import UIKit

// UIImage 뒤집기
func flipImageVertically(originalImage: UIImage) -> UIImage {
    let tempImageView: UIImageView = UIImageView(image: originalImage)
    UIGraphicsBeginImageContext(tempImageView.frame.size)
    let context: CGContext = UIGraphicsGetCurrentContext()!
    let flipVertical: CGAffineTransform = CGAffineTransform(
        a: 1, b: 0, c: 0, d: -1,
        tx: 0,
        ty: tempImageView.frame.size.height
    )

    context.concatenate(flipVertical)
    tempImageView.tintColor = UIColor.white
    tempImageView.layer.render(in: context)

    guard let flippedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
        return UIImage(named: "empty")!
    }
    UIGraphicsEndImageContext()

    return flippedImage
}

func flipImageHorizontal(originalImage: UIImage) -> UIImage {
    let tempImageView: UIImageView = UIImageView(image: originalImage)
    UIGraphicsBeginImageContext(tempImageView.frame.size)
    let context: CGContext = UIGraphicsGetCurrentContext()!
    let flipHorizontal: CGAffineTransform = CGAffineTransform(
        a: -1, b: 0, c: 0, d: 1,
        tx: tempImageView.frame.size.width,
        ty: 0
    )
    
    context.concatenate(flipHorizontal)
    tempImageView.tintColor = UIColor.black
    tempImageView.layer.render(in: context)

    let flippedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return flippedImage
}



extension UIImage {
    
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in self.draw(in: CGRect(origin: .zero, size: size)) }
        print("화면 배율: \(UIScreen.main.scale)")
        // 배수
        print("origin: \(self), resize: \(renderImage)")
        return renderImage
    }

    
    func downSample2(size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
        let data = self.pngData()! as CFData
        let imageSource = CGImageSourceCreateWithData(data, imageSourceOption)!
        let maxPixel = max(size.width, size.height) * scale
        let downSampleOptions = [ kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceShouldCacheImmediately: true, kCGImageSourceCreateThumbnailWithTransform: true, kCGImageSourceThumbnailMaxPixelSize: maxPixel ] as CFDictionary
        let downSampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downSampleOptions)!
        let newImage = UIImage(cgImage: downSampledImage)
//        printDataSize(newImage)
        return newImage
    }
    
    func imageByApplyingClippingBezierPath(_ path: UIBezierPath) -> UIImage {
        // Mask image using path
        let maskedImage = imageByApplyingMaskingBezierPath(path)
        
        // Crop image to frame of path
        let croppedImage = UIImage(cgImage: maskedImage.cgImage!.cropping(to: path.bounds)!)
        return croppedImage
    }
    
    func imageByApplyingMaskingBezierPath(_ path: UIBezierPath) -> UIImage {
        let size = CGSize(width: 200, height: 200)
        // Define graphic context (canvas) to paint on
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        // Set the clipping mask
        path.addClip()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // Restore previous drawing context
        context.restoreGState()
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
}
