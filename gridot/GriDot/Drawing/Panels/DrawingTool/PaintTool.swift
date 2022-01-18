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
            return grid.isSelected(hex, x, y)
        }
        for color in grid.gridLocations.keys {
            if (grid.isSelected(color, x, y)) { return false }
        }
        return true
    }
    
    func paintSameAreaPixels(_ x: Int, _ y: Int) {
        if (canvas.selectedArea.isDrawing && canvas.selectedArea.isSelectedPixel(x, y) == false) { return }
        if (isPainted(x, y) == false && x < canvas.numsOfPixels && x > -1 && y < canvas.numsOfPixels && y > -1) {
            canvas.addPixel(["x": x, "y": y], canvas.selectedColor.hexa!)
            if (painted[x] != nil) {
                painted[x]!.append(y)
            } else {
                painted[x] = [y]
            }
            if (isSamePixel(selectedPixelColor, x + 1, y)) { paintSameAreaPixels(x + 1, y) }
            if (isSamePixel(selectedPixelColor, x, y + 1)) { paintSameAreaPixels(x, y + 1) }
            if (isSamePixel(selectedPixelColor, x - 1, y)) { paintSameAreaPixels(x - 1, y) }
            if (isSamePixel(selectedPixelColor, x, y - 1)) { paintSameAreaPixels(x, y - 1) }
        }
    }
    
}

extension PaintTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
        if (canvas.selectedDrawingMode == "pen") {
            guard let x = pixelPosition["x"] else { return }
            guard let y = pixelPosition["y"] else { return }
            selectedPixelColor = grid.findColorSelected(x: x, y: y)
            paintSameAreaPixels(x, y)
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
        let pixelPosition = canvas.transPosition(canvas.moveTouchPosition)
        guard let x = pixelPosition["x"] else { return }
        guard let y = pixelPosition["y"] else { return }
        selectedPixelColor = grid.findColorSelected(x: x, y: y)
        paintSameAreaPixels(x, y)
        painted = [:]
    }
    
    func buttonUp() {
        canvas.timeMachineVM.addTime()
    }
}
