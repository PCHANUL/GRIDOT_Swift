//
//  PaintTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/01.
//

import UIKit

class PaintTool {
    var canvas: Canvas!
    var grid: Grid!
    var painted: [Int: [Int]]!
    var paintedPixels: [Int32] = Array(repeating: 0, count: 16)
    var selectedPixelColor: Int = -1
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.painted = [:]
    }
    
    func isPainted(_ x: Int, _ y: Int) -> Bool {
        return paintedPixels[y].getBitStatus(x)
    }
    
    func isSamePixel(_ intColor: Int, _ x: Int, _ y: Int) -> Bool {
        guard let index = getGridIndex(CGPoint(x: x, y: y)) else { return false }
        return (grid.data[index] == intColor)
    }
    
    func paintSameAreaPixels(_ pos: CGPoint) {
        let x = Int(pos.x)
        let y = Int(pos.y)
        
        if (canvas.selectedArea.checkPixelForDrawingTool(pos) == false) { return }
        if (isPainted(x, y) == false && x < canvas.numsOfPixels && x > -1 && y < canvas.numsOfPixels && y > -1) {
            if (painted[x] != nil) {
                painted[x]!.append(y)
            } else {
                painted[x] = [y]
            }
            canvas.addPixel(pos, canvas.selectedColor.hexa!)
            if (isSamePixel(selectedPixelColor, x + 1, y)) { paintSameAreaPixels(CGPoint(x: x + 1, y: y)) }
            if (isSamePixel(selectedPixelColor, x, y + 1)) { paintSameAreaPixels(CGPoint(x: x, y: y + 1)) }
            if (isSamePixel(selectedPixelColor, x - 1, y)) { paintSameAreaPixels(CGPoint(x: x - 1, y: y)) }
            if (isSamePixel(selectedPixelColor, x, y - 1)) { paintSameAreaPixels(CGPoint(x: x, y: y - 1)) }
        }
    }
}

extension PaintTool {
    func touchesBegan(_ pixelPos: CGPoint) {
        if (canvas.selectedDrawingMode == "pen") {
            guard let intColor = grid.getIntColorOfPixel(pixelPos) else { return }
            selectedPixelColor = intColor
            paintSameAreaPixels(pixelPos)
            canvas.timeMachineVM.addTime()
            painted = [:]
        }
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
    }
    
    func touchesMoved(_ context: CGContext) {
    }
    
    func touchesEnded(_ context: CGContext) {
    }
    
    func buttonDown() {
        let pos = canvas.transPosition(canvas.moveTouchPosition)
        guard let intColor = grid.getIntColorOfPixel(pos) else { return }
        selectedPixelColor = intColor
        paintSameAreaPixels(pos)
        painted = [:]
    }
    
    func buttonUp() {
        canvas.timeMachineVM.addTime()
    }
}
