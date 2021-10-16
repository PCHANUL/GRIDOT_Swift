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
    var selectedPhoto: CGImage!
    var selectedAnchor: String

    var centerAnchorRadius: CGFloat
    var centerPos: CGPoint
    var anchorPos: [String: CGPoint]
    var anchorNames: [String] = ["C", "TR", "TL", "BR", "BL"]
    var initAnchorRect: CGRect
    
    var photoRect: CGRect!
    var initPhotoRect: CGRect!
    var editedPhotoRect: CGRect
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        
        selectedAnchor = ""
        centerAnchorRadius = canvas.lengthOfOneSide * 0.07
        centerPos = CGPoint(x: canvas.lengthOfOneSide / 2, y: canvas.lengthOfOneSide / 2)
        anchorPos = [
            "C": CGPoint(x: canvas.lengthOfOneSide / 2, y: canvas.lengthOfOneSide / 2),
            "TL": CGPoint(x: centerPos.x - ((centerAnchorRadius / 2) + 25), y: centerPos.y - ((centerAnchorRadius / 2) + 25)),
            "TR": CGPoint(x: centerPos.x + ((centerAnchorRadius / 2) + 25), y: centerPos.y - ((centerAnchorRadius / 2) + 25)),
            "BL": CGPoint(x: centerPos.x - ((centerAnchorRadius / 2) + 25), y: centerPos.y + ((centerAnchorRadius / 2) + 25)),
            "BR": CGPoint(x: centerPos.x + ((centerAnchorRadius / 2) + 25), y: centerPos.y + ((centerAnchorRadius / 2) + 25))
        ]
        
        initAnchorRect = CGRect(
            x: anchorPos["TR"]!.x,
            y: anchorPos["TR"]!.y,
            width: anchorPos["TL"]!.x - anchorPos["TR"]!.x,
            height: anchorPos["BR"]!.y - anchorPos["TR"]!.y
        )
        
        editedPhotoRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    func initContext(_ context: CGContext) {
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 0)
        context.setFillColor(CGColor.init(gray: 1, alpha: 1))
        context.setStrokeColor(CGColor.init(gray: 1, alpha: 1))
        context.setLineWidth(1)
    }
    
    func setContext(_ context: CGContext) {
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 3)
        context.setFillColor(CGColor.init(gray: 1, alpha: 0.9))
        context.setStrokeColor(CGColor.init(gray: 1, alpha: 0.9))
        context.setLineWidth(2)
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
            
            if (photoRect == nil) {
                let imageRatio = CGFloat(selectedPhoto.width) / CGFloat(selectedPhoto.height)
                let imageWidth = canvas.lengthOfOneSide * 0.8 * imageRatio
                let imageHeight = canvas.lengthOfOneSide * 0.8
                
                photoRect = CGRect(
                    x: (canvas.lengthOfOneSide / 2) - (imageWidth / 2),
                    y: (canvas.lengthOfOneSide / 2) - (imageHeight / 2),
                    width: imageWidth, height: imageHeight
                )
                initPhotoRect = photoRect
            } else {
                photoRect = CGRect(
                    x: initPhotoRect.minX + editedPhotoRect.minX,
                    y: initPhotoRect.minY + editedPhotoRect.minY,
                    width: initPhotoRect.width + editedPhotoRect.width,
                    height: initPhotoRect.height + editedPhotoRect.height
                )
            }
            
            context.draw(selectedPhoto, in: photoRect)
        }
    }
    
    func getTouchedAnchor(_ touchPos: CGPoint) -> String {
        var radius: CGFloat = 10
        
        for name in anchorNames {
            guard let anchorPosition = anchorPos[name] else { return "" }
            if (name == "C") { radius = centerAnchorRadius }
            
            if (anchorPosition.x - radius <= touchPos.x
                && anchorPosition.x + radius >= touchPos.x
                && anchorPosition.y - radius <= touchPos.y
                && anchorPosition.y + radius >= touchPos.y)
            { return name }
        }
        
        if (touchPos.y > anchorPos["TL"]!.y - 15 && touchPos.y < anchorPos["TL"]!.y + 7
            && touchPos.x > anchorPos["TL"]!.x + radius && touchPos.x < anchorPos["TR"]!.x - radius)
        { return "T" }
        
        if (touchPos.y > anchorPos["BL"]!.y - 7 && touchPos.y < anchorPos["BL"]!.y + 15
            && touchPos.x > anchorPos["BL"]!.x + radius && touchPos.x < anchorPos["BR"]!.x - radius)
        { return "B" }
        
        if (touchPos.x > anchorPos["TL"]!.x - 15 && touchPos.x < anchorPos["TL"]!.x + 7
            && touchPos.y > anchorPos["TL"]!.y + radius && touchPos.y < anchorPos["BL"]!.y - radius)
        { return "L" }
        
        if (touchPos.x > anchorPos["TR"]!.x - 7 && touchPos.x < anchorPos["TR"]!.x + 15
            && touchPos.y > anchorPos["TR"]!.y + radius && touchPos.y < anchorPos["BR"]!.y - radius)
        { return "R" }
        
        return ""
    }
    
    func initSelctedAnchorPos(anchor: String) {
        switch anchor {
        case "C":
            anchorPos["C"]!.x = initAnchorRect.midX
            anchorPos["C"]!.y = initAnchorRect.midY
        case "T":
            anchorPos["TL"]!.y = initAnchorRect.minY
            anchorPos["TR"]!.y = initAnchorRect.minY
        case "B":
            anchorPos["BL"]!.y = initAnchorRect.maxY
            anchorPos["BR"]!.y = initAnchorRect.maxY
        case "L":
            anchorPos["TL"]!.x = initAnchorRect.minX
            anchorPos["BL"]!.x = initAnchorRect.minX
        case "R":
            anchorPos["TR"]!.x = initAnchorRect.maxX
            anchorPos["BR"]!.x = initAnchorRect.maxX
        case "TL", "TR", "BL", "BR":
            initSelctedAnchorPos(anchor: String(anchor.first!))
            initSelctedAnchorPos(anchor: String(anchor.last!))
        default:
            return
        }
    }
    
    func changeSelectedAnchorPos(anchor: String, point: CGPoint) {
        switch anchor {
        case "C":
            anchorPos["C"]!.x = point.x
            anchorPos["C"]!.y = point.y
        case "T":
            anchorPos["TL"]!.y = point.y
            anchorPos["TR"]!.y = point.y
        case "B":
            anchorPos["BL"]!.y = point.y
            anchorPos["BR"]!.y = point.y
        case "L":
            anchorPos["TL"]!.x = point.x
            anchorPos["BL"]!.x = point.x
        case "R":
            anchorPos["TR"]!.x = point.x
            anchorPos["BR"]!.x = point.x
        case "TL", "TR", "BL", "BR":
            var newPoint = CGPoint(x: point.x, y: point.x)
            if (["TR", "BL"].contains(anchor)) {
                newPoint.y = initAnchorRect.minY - (point.x - initAnchorRect.maxX)
            }
            changeSelectedAnchorPos(anchor: String(anchor.first!), point: newPoint)
            changeSelectedAnchorPos(anchor: String(anchor.last!), point: newPoint)
        default:
            return
        }
    }
    
    func changePhotoRect() {
        if (photoRect != nil) {
            switch selectedAnchor {
            case "C":
                editedPhotoRect = CGRect(
                    x: anchorPos["C"]!.x - initAnchorRect.midX,
                    y: anchorPos["C"]!.y - initAnchorRect.midY,
                    width: 0, height: 0
                )
            default:
                return
            }
        }
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
        selectedAnchor = getTouchedAnchor(touchPos)
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        drawAnchors(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        changeSelectedAnchorPos(anchor: selectedAnchor, point: canvas.moveTouchPosition)
        drawAnchors(context)
        changePhotoRect()
    }
    
    func touchesEnded(_ context: CGContext) {
        initSelctedAnchorPos(anchor: selectedAnchor)
        selectedAnchor = ""
        
        photoRect = CGRect(
            x: initPhotoRect.minX + editedPhotoRect.minX,
            y: initPhotoRect.minY + editedPhotoRect.minY,
            width: initPhotoRect.width + editedPhotoRect.width,
            height: initPhotoRect.height + editedPhotoRect.height
        )
        initPhotoRect = photoRect
        editedPhotoRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        drawAnchors(context)
    }
}
