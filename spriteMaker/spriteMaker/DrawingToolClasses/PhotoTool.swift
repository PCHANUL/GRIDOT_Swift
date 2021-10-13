//
//  PhotoTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/12.
//

import UIKit

class PhotoTool {
    var canvas: Canvas!
    var grid: Grid!
    var selectedPhoto: UIImage!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
    }
    
    func drawPhoto() {
        
    }
    
}

extension PhotoTool {
    func noneTouches(_ context: CGContext) {
        if (selectedPhoto != nil) {
            print("draw")
            guard let image = flipImageVertically(originalImage: selectedPhoto).cgImage else { return }
            
            let imageRatio = CGFloat(image.width) / CGFloat(image.height)
            let imageWidth = canvas.lengthOfOneSide * 0.8 * imageRatio
            let imageHeight = canvas.lengthOfOneSide * 0.8
            
            context.draw(
                image,
                in: CGRect(
                    x: (canvas.lengthOfOneSide / 2) - (imageWidth / 2),
                    y: (canvas.lengthOfOneSide / 2) - (imageHeight / 2),
                    width: imageWidth, height: imageHeight
                )
            )
        }
    }
    
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
    }
    
    func touchesMoved(_ context: CGContext) {
    }
    
    func touchesEnded(_ context: CGContext) {
    }
}
