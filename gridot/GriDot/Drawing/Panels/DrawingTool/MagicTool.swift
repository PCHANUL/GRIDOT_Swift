//
//  MagicTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/20.
//

import UIKit

class MagicTool: SelectTool {
    var sameColorPixels: [Int32] = Array(repeating: 0, count: 16)
    
    override init(_ canvas: Canvas) {
        super.init(canvas)
    }
    
    func getSelectedPixel() {
        let pos = canvas.transPosition(canvas.initTouchPosition)
        guard let intColor = grid.getIntColorOfPixel(pos) else { return }
         
        grid.mapSameColor(intColor) { x, y in
            sameColorPixels[y].setBitOn(x)
        }
        selectedArea.selectedPixels = Array(repeating: 0, count: 16)
        findSameColorPixels(Int(pos.x), Int(pos.y))
    }
    
    func findSameColorPixels(_ x: Int, _ y: Int) {
        selectedArea.addSelectedPixel(CGPoint(x: x, y: y))
        sameColorPixels[y].setBitOff(x)
        if (isSameColor(x + 1, y)) { findSameColorPixels(x + 1, y) }
        if (isSameColor(x - 1, y)) { findSameColorPixels(x - 1, y) }
        if (isSameColor(x, y + 1)) { findSameColorPixels(x, y + 1) }
        if (isSameColor(x, y - 1)) { findSameColorPixels(x, y - 1) }
    }
    
    func isSameColor(_ x: Int, _ y: Int) -> Bool {
        if (x < 0 || x > 15 || y < 0 || y > 15) { return false }
        return sameColorPixels[y].getBitStatus(x)
    }
    
    override func touchesBegan(_ pixelPos: CGPoint) {
        super.touchesBegan(pixelPos)
        
        switch canvas.selectedDrawingMode {
        case "pen":
            getSelectedPixel()
        case "touch":
            return
        default:
            return
        }
    }
    
    override func buttonDown() {
        super.buttonDown()
        getSelectedPixel()
    }
}

