//
//  SelectSquareTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/03.
//

import UIKit

class SelectSquareTool: SelectTool {
    var minX: CGFloat = 0
    var maxX: CGFloat = 0
    var minY: CGFloat = 0
    var maxY: CGFloat = 0
    var xLen: CGFloat = 0
    var yLen: CGFloat = 0
    
    override init(_ canvas: Canvas) {
        super.init(canvas)
    }
    
    func isTouchedInsideArea(_ touchPosition: [String: Int]) -> Bool {
        guard let x = touchPosition["x"] else { return false }
        guard let y = touchPosition["y"] else { return false }
        let posX = pixelLen * CGFloat(x)
        let posY = pixelLen * CGFloat(y)
        return (minX + accX <= posX && posX <= maxX + accX
                    && minY + accY <= posY && posY <= maxY + accX)
    }
    
    func setEndPosition(_ touchPos: CGPoint) {
        endX = pixelLen * CGFloat(touchPos.x + 1)
        xLen = endX - startX
        minX = xLen > 0 ? startX : endX
        maxX = xLen > 0 ? endX : startX
        xLen = xLen > 0 ? xLen : xLen * -1
        
        endY = pixelLen * CGFloat(touchPos.y + 1)
        yLen = endY - startY
        minY = yLen > 0 ? startY : endY
        maxY = yLen > 0 ? endY : startY
        yLen = yLen > 0 ? yLen : yLen * -1
    }
    
    func endMovePosition() {
        minX += accX
        minY += accY
        maxX += accX
        maxY += accY
    }
    
    func getSelectedAreaPixels(_ grid: Grid) {
        selectedArea.selectedPixels = setPixelsInRect(
            Int(minX / pixelLen), Int(minY / pixelLen),
            Int(maxX / pixelLen), Int(maxY / pixelLen)
        )
    }
    
    func removeSelectedAreaPixels() {
        selectedArea.mapSelectedPixelArr { x, y in
            grid.removeLocation(CGPoint(x: x, y: y))
        }
    }
    
    func setPixelsInRect(_ minX: Int, _ minY: Int, _ maxX: Int, _ maxY: Int) -> [Int32] {
        var pixels: [Int32] = Array(repeating: 0, count: 16)
        var xPixel: Int32 = 0
        
        for x in minX..<maxX {
            xPixel.setBitOn(x)
        }
        
        for y in minY..<maxY {
            pixels[y] = xPixel
        }
        
        return pixels
    }
    
    func drawSelectedAreaOutline(_ context: CGContext) {
        let accMinX: CGFloat = minX + accX
        let accMinY: CGFloat = minY + accY
        let accMaxX: CGFloat = maxX + accX
        let accMaxY: CGFloat = maxY + accY
        var x: CGFloat = accMinX
        var y: CGFloat = accMinY
        
        while (x < accMaxX) {
            drawHorizontalOutline(context, x, accMinY, outlineToggle)
            drawHorizontalOutline(context, x, accMaxY, outlineToggle)
            x += pixelLen
        }
        
        while (y < accMaxY) {
            drawVerticalOutline(context, accMinX, y, outlineToggle)
            drawVerticalOutline(context, accMaxX, y, outlineToggle)
            y += pixelLen
        }
    }
    
    override func touchesBegan(_ pixelPos: CGPoint) {
        super.touchesBegan(pixelPos)
        
        switch canvas.selectedDrawingMode {
        case "pen":
            setStartPosition(canvas.transPosition(canvas.initTouchPosition))
            setEndPosition(canvas.transPosition(canvas.moveTouchPosition))
        case "touch":
            return
        default:
            return
        }
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            setEndPosition(canvas.transPosition(canvas.moveTouchPosition))
            getSelectedAreaPixels(grid)
        case "touch":
            if (canvas.activatedDrawing) {
                setEndPosition(canvas.transPosition(canvas.moveTouchPosition))
                getSelectedAreaPixels(grid)
            }
        default:
            return
        }
    }
    
    override func touchesEnded(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            getSelectedAreaPixels(grid)
        default:
            return
        }
        super.touchesEnded(context)
    }
    
    override func buttonDown() {
        super.buttonDown()
        setStartPosition(canvas.transPosition(canvas.initTouchPosition))
        setEndPosition(canvas.transPosition(canvas.moveTouchPosition))
    }
    
    override func buttonUp() {
        getSelectedAreaPixels(grid)
        super.buttonUp()
    }
}
