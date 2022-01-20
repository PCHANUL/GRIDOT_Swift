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
    var selectedPixelColor: String!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.painted = [:]
    }
    
    func isPainted(_ x: Int, _ y: Int) -> Bool {
        guard let yPixels = painted[x] else { return false }
        if yPixels.firstIndex(of: y) == nil { return false }
        else { return true }
    }
    
    func isSamePixel(_ hex: String, _ x: Int, _ y: Int) -> Bool {
        if (hex != "none") {
            return grid.isSelected(hex, CGPoint(x: x, y: y))
        }
        for color in grid.gridLocations.keys {
            if (grid.isSelected(color, CGPoint(x: x, y: y))) { return false }
        }
        return true
    }
    
    func paintSameAreaPixels(_ pos: CGPoint) {
        let x = Int(pos.x)
        let y = Int(pos.y)
        
        if (canvas.selectedArea.isDrawing && canvas.selectedArea.isSelectedPixel(pos) == false) { return }
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
            selectedPixelColor = grid.findColorSelected(pixelPos)
            paintSameAreaPixels(pixelPos)
            painted = [:]
            canvas.timeMachineVM.addTime()
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
        selectedPixelColor = grid.findColorSelected(pos)
        paintSameAreaPixels(pos)
        painted = [:]
    }
    
    func buttonUp() {
        canvas.timeMachineVM.addTime()
    }
}
