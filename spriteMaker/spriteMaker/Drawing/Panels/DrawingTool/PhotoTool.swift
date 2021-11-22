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
    
    var isPreview: Bool
    var previewArr: [UIColor]

    var isAnchorHidden: Bool
    var centerAnchorRadius: CGFloat
    var centerPos: CGPoint
    var anchorPos: [String: CGPoint]
    var anchorNames: [String] = ["C", "TR", "TL", "BR", "BL"]
    var initAnchorRect: CGRect
    
    var photoRect: CGRect!
    var initPhotoRect: CGRect!
    var editedPhotoRect: PhotoRect
    var isFlipedHorizontal: Bool
    var isFlipedVertical: Bool
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        
        isPreview = false
        previewArr = []
        
        isAnchorHidden = false
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
        
        editedPhotoRect = PhotoRect(x: 0, y: 0, w: 0, h: 0)
        isFlipedHorizontal = false
        isFlipedVertical = false
    }
    
    func initPhotoRects() {
        photoRect = nil
        initPhotoRect = nil
        editedPhotoRect = PhotoRect(x: 0, y: 0, w: 0, h: 0)
    }
    
    func initContext(_ context: CGContext) {
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 0)
        context.setFillColor(CGColor.init(gray: 1, alpha: 1))
        context.setStrokeColor(CGColor.init(gray: 1, alpha: 1))
        context.setLineWidth(0.5)
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
    
    func changePhotoRect(anchor: String) {
        if (photoRect != nil) {
            switch anchor {
            case "C":
                let x = anchorPos["C"]!.x - initAnchorRect.midX
                let y = anchorPos["C"]!.y - initAnchorRect.midY
                editedPhotoRect.x = x
                editedPhotoRect.y = y
            case "T":
                let y = anchorPos["TL"]!.y - initAnchorRect.minY
                editedPhotoRect.y = y
                editedPhotoRect.h = -y
                checkHorizontalFliped()
            case "B":
                let y = anchorPos["BL"]!.y - initAnchorRect.maxY
                editedPhotoRect.h = y
                checkHorizontalFliped()
            case "L":
                let x = anchorPos["TL"]!.x - initAnchorRect.minX
                editedPhotoRect.x = x
                editedPhotoRect.w = -x
                checkVerticalFliped()
            case "R":
                let x = anchorPos["TR"]!.x - initAnchorRect.maxX
                editedPhotoRect.w = x
                checkVerticalFliped()
            case "TL", "TR", "BL", "BR":
                changePhotoRect(anchor: String(anchor.first!))
                changePhotoRect(anchor: String(anchor.last!))
            default:
                return
            }
        }
    }
    
    func checkHorizontalFliped() {
        if ((isFlipedHorizontal == false && initPhotoRect.height + editedPhotoRect.h < 0)
                || (isFlipedHorizontal == true && initPhotoRect.height + editedPhotoRect.h > 0))
        {
            guard let fliped = flipImageVertically(originalImage: UIImage(cgImage: selectedPhoto)).cgImage else { return }
            selectedPhoto = fliped
            isFlipedHorizontal = !isFlipedHorizontal
        }
    }
    
    func checkVerticalFliped() {
        if ((isFlipedVertical == false && initPhotoRect.width + editedPhotoRect.w < 0)
                || (isFlipedVertical == true && initPhotoRect.width + editedPhotoRect.w > 0))
        {
            guard let fliped = flipImageHorizontal(originalImage: UIImage(cgImage: selectedPhoto)).cgImage else { return }
            selectedPhoto = fliped
            isFlipedVertical = !isFlipedVertical
        }
    }
    
    func endedChangePhotoRect() {
        if (photoRect != nil) {
            photoRect = CGRect(
                x: initPhotoRect.minX + editedPhotoRect.x,
                y: initPhotoRect.minY + editedPhotoRect.y,
                width: initPhotoRect.width + editedPhotoRect.w,
                height: initPhotoRect.height + editedPhotoRect.h
            )
            initPhotoRect = photoRect
            editedPhotoRect = PhotoRect(x: 0, y: 0, w: 0, h: 0)
        }
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
                    x: initPhotoRect.minX + editedPhotoRect.x,
                    y: initPhotoRect.minY + editedPhotoRect.y,
                    width: initPhotoRect.width + editedPhotoRect.w,
                    height: initPhotoRect.height + editedPhotoRect.h
                )
            }
            context.draw(selectedPhoto, in: photoRect)
        }
    }
    
    func renderPhoto() -> UIImage {
        let sideLen = canvas.lengthOfOneSide!
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: sideLen, height: sideLen))
        return renderer.image { context in
            drawPhoto(context.cgContext)
        }
    }
    
    func previewPixel() {
        let image = renderPhoto().cgImage!
        let pixLen = image.width / 16
        let pixelData = image.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        for y in 0...15 {
            for x in 0...15 {
                let point = CGPoint(x: (pixLen / 2) + (pixLen * x), y: (pixLen / 2) + (pixLen * y))
                let pixelInfo: Int = ((image.width * Int(point.y)) + Int(point.x)) * 4
                
                let r = CGFloat(data[pixelInfo]) / CGFloat(255)
                let g = CGFloat(data[pixelInfo+1]) / CGFloat(255)
                let b = CGFloat(data[pixelInfo+2]) / CGFloat(255)
                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255)
                let color = UIColor(red: r, green: g, blue: b, alpha: a)
                
                previewArr.append(color)
            }
        }
        
        isPreview = true
        canvas.setNeedsDisplay()
    }
    
    func drawPreview(_ context: CGContext) {
        for index in 0...previewArr.count - 1 {
            let y = index / 16
            let x = index % 16
            
            drawRect(context, CGPoint(x: x, y: y), previewArr[index])
        }
    }
    
    func drawRect(_ context: CGContext, _ targetPos: CGPoint, _ color: UIColor) {
        context.setFillColor(color.cgColor)
        context.setStrokeColor(color.cgColor)
        
        let xlocation = Double(targetPos.x) * Double(canvas.onePixelLength)
        let ylocation = Double(targetPos.y) * Double(canvas.onePixelLength)
        let rectangle = CGRect(x: xlocation, y: ylocation, width: Double(canvas.onePixelLength), height: Double(canvas.onePixelLength))
        
        context.addRect(rectangle)
        context.drawPath(using: .fill)
    }


    func createPixelPhoto() {
        let image = renderPhoto().cgImage!
        let pixLen = image.width / 16
        let pixelData = image.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        for y in 0...15 {
            for x in 0...15 {
                let point = CGPoint(x: (pixLen / 2) + (pixLen * x), y: (pixLen / 2) + (pixLen * y))
                let pixelInfo: Int = ((image.width * Int(point.y)) + Int(point.x)) * 4
                
                let r = CGFloat(data[pixelInfo]) / CGFloat(255)
                let g = CGFloat(data[pixelInfo+1]) / CGFloat(255)
                let b = CGFloat(data[pixelInfo+2]) / CGFloat(255)
                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255)
                
                let color = UIColor(red: r, green: g, blue: b, alpha: a)
                if (color.cgColor.alpha != 0) {
                    canvas.grid.addLocation(hex: color.hexa!, x: x, y: y)
                }
            }
        }
        
        canvas.updateViewModelImages(canvas.drawingVC.layerVM.selectedLayerIndex)
        canvas.timeMachineVM.addTime()
    }
    
    func addNewLayer() {
        guard let image = UIImage(named: "empty") else { return }
        guard let layerVM = canvas.drawingVC.layerVM else { return }
        
        layerVM.addNewLayer(layer: Layer(gridData: "", renderedImage: image, ishidden: false))
        canvas.changeGrid(index: layerVM.selectedLayerIndex, gridData: "")
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor? {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension PhotoTool {
    func alwaysUnderGirdLine(_ context: CGContext) {
        if (isPreview) {
            drawPreview(context)
        } else {
            drawPhoto(context)
        }
    }
    
    func noneTouches(_ context: CGContext) {
        if (isAnchorHidden == false && isPreview == false) {
            drawAnchors(context)
        }
    }
    
    func touchesBegan(_ touchPos: CGPoint) {
        selectedAnchor = getTouchedAnchor(touchPos)
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        if (isAnchorHidden == false && isPreview == false) {
            drawAnchors(context)
        }
    }
    
    func touchesMoved(_ context: CGContext) {
        if (isAnchorHidden == false && isPreview == false) {
            changeSelectedAnchorPos(anchor: selectedAnchor, point: canvas.moveTouchPosition)
            drawAnchors(context)
            changePhotoRect(anchor: selectedAnchor)
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        if (isAnchorHidden == false && isPreview == false) {
            initSelctedAnchorPos(anchor: selectedAnchor)
            endedChangePhotoRect()
            selectedAnchor = ""
            isFlipedHorizontal = false
            isFlipedVertical = false
        }
    }
}

struct PhotoRect {
    var x: CGFloat
    var y: CGFloat
    var w: CGFloat
    var h: CGFloat
}
