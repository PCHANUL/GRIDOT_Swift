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
    var selectedAnchor: String!

    var centerAnchorRadius: CGFloat
    var centerPos: CGPoint
    var anchorPos: [String: CGPoint]
    var anchorNames: [String] = ["C", "TR", "TL", "BR", "BL"]
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        
        centerAnchorRadius = canvas.lengthOfOneSide * 0.07
        centerPos = CGPoint(x: canvas.lengthOfOneSide / 2, y: canvas.lengthOfOneSide / 2)
        anchorPos = [
            "C": CGPoint(x: canvas.lengthOfOneSide / 2, y: canvas.lengthOfOneSide / 2),
            "TR": CGPoint(x: centerPos.x - ((centerAnchorRadius / 2) + 25), y: centerPos.y - ((centerAnchorRadius / 2) + 25)),
            "TL": CGPoint(x: centerPos.x + ((centerAnchorRadius / 2) + 25), y: centerPos.y - ((centerAnchorRadius / 2) + 25)),
            "BR": CGPoint(x: centerPos.x - ((centerAnchorRadius / 2) + 25), y: centerPos.y + ((centerAnchorRadius / 2) + 25)),
            "BL": CGPoint(x: centerPos.x + ((centerAnchorRadius / 2) + 25), y: centerPos.y + ((centerAnchorRadius / 2) + 25))
        ]
    }
    
    func setContext(_ context: CGContext) {
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 3)
        context.setFillColor(CGColor.init(gray: 1, alpha: 0.9))
        context.setStrokeColor(CGColor.init(gray: 1, alpha: 0.9))
        context.setLineWidth(2)
    }
    
    func initContext(_ context: CGContext) {
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 0)
        context.setFillColor(CGColor.init(gray: 1, alpha: 1))
        context.setStrokeColor(CGColor.init(gray: 1, alpha: 1))
        context.setLineWidth(1)
    }
    
    func drawAnchors(_ context: CGContext) {
        setContext(context)
        
        // square
        context.addRect(CGRect(
            x: anchorPos["TR"]!.x,
            y: anchorPos["TR"]!.y,
            width: anchorPos["TL"]!.x - anchorPos["TR"]!.x,
            height: anchorPos["BR"]!.y - anchorPos["TR"]!.y
        ))
        context.strokePath()
        
        // anchor
        for name in anchorNames {
            context.addArc(
                center: anchorPos[name]!,
                radius: name == "C" ? centerAnchorRadius : 7,
                startAngle: 0, endAngle: .pi * 2, clockwise: true
            )
            context.fillPath()
        }
        
        initContext(context)
    }
    
    func drawPhoto(_ context: CGContext) {
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
    
    func getTouchedAnchor(_ touchPos: CGPoint) {
        for name in anchorNames {
            guard let anchorPosition = anchorPos[name] else { return }
            let radius = name == "C" ? centerAnchorRadius : 7
            
            if (anchorPosition.x - radius <= touchPos.x
                && anchorPosition.x + radius >= touchPos.x
                && anchorPosition.y - radius <= touchPos.y
                && anchorPosition.y + radius >= touchPos.y)
            {
                selectedAnchor = name
            }
        }
    }
    
    func changeSelectedAnchorPos() {
        guard let selectedAnchorPos = anchorPos[selectedAnchor] else { return }
        let movedX = canvas.moveTouchPosition.x - selectedAnchorPos.x
        let movedY = canvas.moveTouchPosition.y - selectedAnchorPos.y
        
        anchorPos[selectedAnchor]!.x += movedX > movedY ? movedX : movedY
        anchorPos[selectedAnchor]!.y += movedX > movedY ? movedX : movedY
    }
}

extension PhotoTool {
    func alwaysUnderGirdLine(_ context: CGContext) {
        drawPhoto(context)
    }
    
    func noneTouches(_ context: CGContext) {
        drawAnchors(context)
    }
    
    func touchesBegan(_ touchPos: CGPoint) {
        getTouchedAnchor(touchPos)
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        drawAnchors(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        changeSelectedAnchorPos()
        drawAnchors(context)
    }
    
    func touchesEnded(_ context: CGContext) {
    }
}
