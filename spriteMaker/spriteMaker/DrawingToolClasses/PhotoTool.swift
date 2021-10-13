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
    
    var moveAnchorPos: CGPoint
    var resizeAnchorPosUR: CGPoint
    var resizeAnchorPosUL: CGPoint
    var resizeAnchorPosDR: CGPoint
    var resizeAnchorPosDL: CGPoint
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        
        let center = CGPoint(x: canvas.lengthOfOneSide / 2, y: canvas.lengthOfOneSide / 2)
        let anchorCenterRadius = canvas.lengthOfOneSide * 0.07
        
        moveAnchorPos = center
        resizeAnchorPosUR = CGPoint(x: center.x - ((anchorCenterRadius / 2) + 20), y: center.y - ((anchorCenterRadius / 2) + 20))
        resizeAnchorPosUL = CGPoint(x: center.x + ((anchorCenterRadius / 2) + 20), y: center.y - ((anchorCenterRadius / 2) + 20))
        resizeAnchorPosDR = CGPoint(x: center.x - ((anchorCenterRadius / 2) + 20), y: center.y + ((anchorCenterRadius / 2) + 20))
        resizeAnchorPosDL = CGPoint(x: center.x + ((anchorCenterRadius / 2) + 20), y: center.y + ((anchorCenterRadius / 2) + 20))
    }
    
    func drawAnchors(_ context: CGContext) {
        let anchorCenterRadius = canvas.lengthOfOneSide * 0.07
        
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 10)
        context.setFillColor(CGColor.init(gray: 0.5, alpha: 0.7))
        context.addArc(center: moveAnchorPos, radius: anchorCenterRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.fillPath()
        
        context.addRect(
            CGRect(
                x: resizeAnchorPosUR.x,
                y: resizeAnchorPosUR.y,
                width: resizeAnchorPosUL.x - resizeAnchorPosUR.x,
                height: resizeAnchorPosDR.y - resizeAnchorPosUR.y
            )
        )
        context.setLineWidth(2)
        context.setStrokeColor(CGColor.init(gray: 0.5, alpha: 0.7))
        context.strokePath()
        
        context.addArc(center: resizeAnchorPosUR, radius: 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.fillPath()
        context.addArc(center: resizeAnchorPosUL, radius: 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.fillPath()
        context.addArc(center: resizeAnchorPosDR, radius: 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.fillPath()
        context.addArc(center: resizeAnchorPosDL, radius: 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.fillPath()
    }
    
}

extension PhotoTool {
    func alwaysUnderGirdLine(_ context: CGContext) {
        if (selectedPhoto != nil) {
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
    
    func noneTouches(_ context: CGContext) {
        drawAnchors(context)
    }
    
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        drawAnchors(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        drawAnchors(context)
    }
    
    func touchesEnded(_ context: CGContext) {
    }
}
