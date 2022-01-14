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
    
    func setEndPosition(_ touchPosition: [String: Int]) {
        guard let x = touchPosition["x"] else { return }
        guard let y = touchPosition["y"] else { return }
        
        endX = pixelLen * CGFloat(x + 1)
        xLen = endX - startX
        minX = xLen > 0 ? startX : endX
        maxX = xLen > 0 ? endX : startX
        xLen = xLen > 0 ? xLen : xLen * -1
        
        endY = pixelLen * CGFloat(y + 1)
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
        for x in selectedArea.selectedPixels {
            for y in x.value {
                let color = grid.findColorSelected(x: x.key, y: y)
                grid.removeLocationIfSelected(
                    hex: color, x: x.key, y: y
                )
            }
        }
    }
    
    func setPixelsInRect(_ minX: Int, _ minY: Int, _ maxX: Int, _ maxY: Int) -> [Int: [Int]] {
        var pixels: [Int: [Int]] = [:]
        
        for x in minX..<maxX {
            pixels[x] = []
            for y in minY..<maxY {
                pixels[x]?.append(y)
            }
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
    
    override func touchesBegan(_ pixelPosition: [String: Int]) {
        super.touchesBegan(pixelPosition)
        
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
}
