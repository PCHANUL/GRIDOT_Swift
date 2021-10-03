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

    let flippedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return flippedImage
}

func flipImageHorizontal(originalImage: UIImage) -> UIImage {
    let tempImageView: UIImageView = UIImageView(image: originalImage)
    UIGraphicsBeginImageContext(tempImageView.frame.size)
    let context: CGContext = UIGraphicsGetCurrentContext()!
    let flipHorizontal: CGAffineTransform = CGAffineTransform(
        a: -1, b: 0, c: 0, d: -1,
        tx: tempImageView.frame.size.width,
        ty: tempImageView.frame.size.height
    )
    
    context.concatenate(flipHorizontal)
    tempImageView.tintColor = UIColor.black
    tempImageView.layer.render(in: context)

    let flippedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return flippedImage
}
