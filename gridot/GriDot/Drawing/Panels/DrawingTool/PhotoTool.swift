//
//  PhotoTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/12.
//

import UIKit

/// rect 변경을 위한 구조체입니다.
/// CGRect를 사용하지 않는 이유는 width, height 값이 음수일 수 있기 때문입니다.
struct EditedPhotoRect {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var w: CGFloat = 0
    var h: CGFloat = 0
}

class Photo {
    var cgImage: CGImage
    var sideLength: CGFloat
    
    var initRect: CGRect = .zero
    var editedRect: EditedPhotoRect = .init()
    var rect: CGRect {
        CGRect(
            x: initRect.minX + editedRect.x,
            y: initRect.minY + editedRect.y,
            width: initRect.width + editedRect.w,
            height: initRect.height + editedRect.h
        )
    }
    
    var isFlipedHorizontal: Bool = false
    var isFlipedVertical: Bool = false
    
    init(cgImage: CGImage, sideLength: CGFloat) {
        let imageRatio = CGFloat(cgImage.width) / CGFloat(cgImage.height)
        let imageWidth = sideLength * 0.8 * imageRatio
        let imageHeight = sideLength * 0.8
        
        self.cgImage = cgImage
        self.sideLength = sideLength
        self.initRect = CGRect(
            x: (sideLength / 2) - (imageWidth / 2),
            y: (sideLength / 2) - (imageHeight / 2),
            width: imageWidth, height: imageHeight
        )
    }
    
    func editRect(
        x: CGFloat = 0,
        y: CGFloat = 0,
        width: CGFloat = 0,
        height: CGFloat = 0
    ) {
        editedRect = EditedPhotoRect(
            x: x == 0 ? editedRect.x : x,
            y: y == 0 ? editedRect.y : y,
            w: width == 0 ? editedRect.w : width,
            h: height == 0 ? editedRect.h : height
        )
    }
    
    func setEditedRect() {
        self.initRect = rect
        self.editedRect = .init()
    }
    
    func checkHorizontalFliped() {
        if (
            (isFlipedHorizontal == false && initRect.height + editedRect.h <= 0)
            || (isFlipedHorizontal == true && initRect.height + editedRect.h >= 0)
        ) {
            guard let fliped = flipImageVertically(originalImage: cgImage) else { return }
            
            cgImage = fliped
            isFlipedHorizontal = !isFlipedHorizontal
        }
    }
    
    func checkVerticalFliped() {
        if (
            (isFlipedVertical == false && initRect.width + editedRect.w <= 0)
            || (isFlipedVertical == true && initRect.width + editedRect.w >= 0)
        ) {
            guard let fliped = flipImageHorizontal(originalImage: cgImage) else { return }

            cgImage = fliped
            isFlipedVertical = !isFlipedVertical
        }
    }
}

class PhotoTool {
    var canvas: Canvas!
    var grid: Grid!
    var selectedAnchor: String
    
    var isPreview: Bool
    var previewArr: [UIColor]

    var isAnchorHidden: Bool
    var centerAnchorRadius: CGFloat
    var centerPos: CGPoint
    var anchorPos: [String: CGPoint]
    var anchorNames: [String] = ["C", "TR", "TL", "BR", "BL"]
    var initAnchorRect: CGRect
    
//    var selectedPhoto: CGImage!
//
//    var photoRect: CGRect!
//    var initPhotoRect: CGRect!
//    var editedPhotoRect: PhotoRect
//    var isFlipedHorizontal: Bool
//    var isFlipedVertical: Bool
    
    var photo: Photo? = nil
    var hasPhoto: Bool { return (photo != nil) }
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        
        isPreview = false
        previewArr = []
        
        isAnchorHidden = false
        selectedAnchor = ""
        centerAnchorRadius = canvas.lengthOfOneSide * 0.07
        centerPos = CGPoint(x: canvas.lengthOfOneSide / 2, y: canvas.lengthOfOneSide / 2)
        
        let centerVal = (centerAnchorRadius / 2) + 25
        anchorPos = [
            "C": CGPoint(x: centerPos.x, y: centerPos.y),
            "TL": CGPoint(x: centerPos.x - centerVal, y: centerPos.y - centerVal),
            "TR": CGPoint(x: centerPos.x + centerVal, y: centerPos.y - centerVal),
            "BL": CGPoint(x: centerPos.x - centerVal, y: centerPos.y + centerVal),
            "BR": CGPoint(x: centerPos.x + centerVal, y: centerPos.y + centerVal)
        ]
        
        initAnchorRect = CGRect(
            x: anchorPos["TR"]!.x,
            y: anchorPos["TR"]!.y,
            width: anchorPos["TL"]!.x - anchorPos["TR"]!.x,
            height: anchorPos["BR"]!.y - anchorPos["TR"]!.y
        )
    }
    
    func initPhoto(photo: CGImage) {
        self.photo = .init(cgImage: photo, sideLength: canvas.lengthOfOneSide)
    }
    
    func clearPhoto() {
        self.photo = nil
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
        if (photo != nil) {
            switch anchor {
            case "C":
                let x = anchorPos["C"]!.x - initAnchorRect.midX
                let y = anchorPos["C"]!.y - initAnchorRect.midY
                photo!.editRect(x: x, y: y)
            case "T":
                let y = anchorPos["TL"]!.y - initAnchorRect.minY
                photo!.editRect(y: y, height: -y)
                photo!.checkHorizontalFliped()
            case "B":
                let y = anchorPos["BL"]!.y - initAnchorRect.maxY
                photo!.editRect(height: y)
                photo!.checkHorizontalFliped()
            case "L":
                let x = anchorPos["TL"]!.x - initAnchorRect.minX
                photo!.editRect(x: x, width: -x)
                photo!.checkVerticalFliped()
            case "R":
                let x = anchorPos["TR"]!.x - initAnchorRect.maxX
                photo!.editRect(width: x)
                photo!.checkVerticalFliped()
            case "TL", "TR", "BL", "BR":
                changePhotoRect(anchor: String(anchor.first!))
                changePhotoRect(anchor: String(anchor.last!))
            default:
                return
            }
        }
    }
    
    func endedChangePhotoRect() {
        if (self.photo != nil) {
            self.photo!.setEditedRect()
        }
    }
    
    func drawPhoto(photo: Photo, _ context: CGContext) {
        context.draw(photo.cgImage, in: photo.rect)
    }
    
    func renderCanvasPhoto(photo: Photo) -> CGImage? {
        let sideLen = canvas.lengthOfOneSide!
        let size = CGSize(width: sideLen, height: sideLen)

        // 비트맵 기반 그래픽 컨텍스트 생성
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
           return nil
        }

        // UIGraphicsPushContext를 사용하여 생성된 컨텍스트를 현재 컨텍스트로 설정
        UIGraphicsPushContext(context)

        // 사용자 정의 drawPhoto 함수를 호출하여 컨텍스트에 그림
        drawPhoto(photo: photo, context)

        // UIGraphicsPopContext를 호출하여 이전 컨텍스트로 되돌림
        UIGraphicsPopContext()

        // CGImage 생성
        return context.makeImage()
    }
    
    func setPreviewArr(cgImage: CGImage) {
        self.previewArr.removeAll()
        let pixLen = cgImage.width / 16
        let pixelData = cgImage.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        for y in 0...15 {
            for x in 0...15 {
                let point = CGPoint(x: (pixLen / 2) + (pixLen * x), y: (pixLen / 2) + (pixLen * y))
                let pixelInfo: Int = ((cgImage.width * Int(point.y)) + Int(point.x)) * 4
                
                let r = CGFloat(data[pixelInfo]) / CGFloat(255)
                let g = CGFloat(data[pixelInfo+1]) / CGFloat(255)
                let b = CGFloat(data[pixelInfo+2]) / CGFloat(255)
                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255)
                let color = UIColor(red: r, green: g, blue: b, alpha: a)
                
                previewArr.append(color)
            }
        }
    }
    
    func previewPixel() {
        guard let photo = self.photo else { return }
        guard let image = renderCanvasPhoto(photo: photo) else { return }
        guard let fliped = flipImageVertically(originalImage: image) else { return }
        
        setPreviewArr(cgImage: fliped)
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
        let rectangle = CGRect(
            x: xlocation,
            y: ylocation,
            width: Double(canvas.onePixelLength),
            height: Double(canvas.onePixelLength)
        )
        
        context.addRect(rectangle)
        context.drawPath(using: .fill)
    }


    func createPixelPhoto() {
        guard let photo = self.photo else { return }
        guard let image = renderCanvasPhoto(photo: photo) else { return }
        guard let fliped = flipImageVertically(originalImage: image) else { return }
        
        let pixLen = fliped.width / 16
        let pixelData = fliped.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        for y in 0...15 {
            for x in 0...15 {
                let point = CGPoint(x: (pixLen / 2) + (pixLen * x), y: (pixLen / 2) + (pixLen * y))
                let pixelInfo: Int = ((fliped.width * Int(point.y)) + Int(point.x)) * 4
                
                let r = CGFloat(data[pixelInfo]) / CGFloat(255)
                let g = CGFloat(data[pixelInfo+1]) / CGFloat(255)
                let b = CGFloat(data[pixelInfo+2]) / CGFloat(255)
                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255)
                
                let color = UIColor(red: r, green: g, blue: b, alpha: a)
                if (color.cgColor.alpha != 0) {
                    canvas.addPixel(CGPoint(x: x, y: y), color.hexa!)
                }
            }
        }
        
        canvas.updateLayerImage(canvas.drawingVC.layerVM.selectedLayerIndex)
        canvas.timeMachineVM.addTime()
    }
    
    func addNewLayer() {
        guard let layerVM = canvas.drawingVC.layerVM else { return }
        
        layerVM.addNewLayer(layer: Layer())
        canvas.changeGrid(index: layerVM.selectedLayerIndex, gridData: layerVM.selectedLayer!.data)
    }
}

extension PhotoTool {
    
    /// 유저가 PhotoTool을 선택하는 순간부터 draw 메서드에서 계속 호출됩니다.
    /// photo 또는 preview를 캔버스에 렌더링합니다.
    func alwaysUnderGirdLine(_ context: CGContext) {
        if (isPreview) {
            drawPreview(context)
        } else if (hasPhoto) {
            drawPhoto(photo: photo!, context)
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
            
            guard let photo = self.photo else { return }
            photo.isFlipedHorizontal = false
            photo.isFlipedVertical = false
        }
    }
}
