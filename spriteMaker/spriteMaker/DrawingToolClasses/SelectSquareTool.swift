//
//  SelectSquareTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/03.
//

import UIKit

class SelectSquareTool: SelectTool {
    var minX: CGFloat!
    var maxX: CGFloat!
    var minY: CGFloat!
    var maxY: CGFloat!
    var xLen: CGFloat!
    var yLen: CGFloat!
    
    override init(_ canvas: Canvas) {
        super.init(canvas)
    }
    
    func initPositions() {
        minX = 0
        maxX = 0
        minY = 0
        maxY = 0
        xLen = 0
        yLen = 0
        accX = 0
        accY = 0
    }
    
    func replacePixels(_ grid: Grid) {
        for color in selectedPixels {
            for x in color.value {
                for y in x.value {
                    grid.addLocation(hex: color.key, x: x.key, y: y);
                }
            }
        }
    }
    
    func checkSelectedTool(_ grid: Grid, _ tool: String) {
        if (tool != "SelectSquare") {
            initPositions()
            replacePixels(grid)
        }
    }
    
    func isTouchedInsideArea(_ touchPosition: [String: Int]) -> Bool {
        if (xLen == canvasLen && yLen == canvasLen) {
            initPositions()
            return false
        }
        if ((minX == nil) || (maxX == nil) || (minY == nil) || (maxY == nil)) { return false }
        guard let x = touchPosition["x"] else { return false }
        guard let y = touchPosition["y"] else { return false }
        let posX = pixelLen * CGFloat(x)
        let posY = pixelLen * CGFloat(y)
        return (minX! + accX <= posX && posX <= maxX! + accX
                    && minY! + accY <= posY && posY <= maxY! + accX)
    }
    
    func setEndPosition(_ touchPosition: [String: Int]) {
        endX = pixelLen * CGFloat(touchPosition["x"]! + 1)
        xLen = endX - startX
        minX = xLen > 0 ? startX : endX
        maxX = xLen > 0 ? endX : startX
        xLen = xLen > 0 ? xLen : xLen * -1
        
        endY = pixelLen * CGFloat(touchPosition["y"]! + 1)
        yLen = endY - startY
        minY = yLen > 0 ? startY : endY
        maxY = yLen > 0 ? endY : startY
        yLen = yLen > 0 ? yLen : yLen * -1
    }
    
    func endMovePosition() {
        moveSelectedAreaPixels()
        minX += accX
        minY += accY
        maxX += accX
        maxY += accY
        accX = 0
        accY = 0
    }
    
    func getSelectedAreaPixels(_ grid: Grid) {
        selectedPixels = grid.getPixelsInRect(Int(minX / pixelLen), Int(minY / pixelLen),
                                            Int(maxX / pixelLen), Int(maxY / pixelLen))
        for color in selectedPixels {
            for x in color.value {
                for y in x.value {
                    grid.removeLocationIfSelected(hex: color.key, x: x.key, y: y);
                }
            }
        }
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
}
