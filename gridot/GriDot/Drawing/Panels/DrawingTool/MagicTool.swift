//
//  MagicTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/20.
//

import UIKit

class MagicTool: SelectTool {
    var sameColorPixels: [Int: [Int]] = [:]
    var selectedHex: String!
    
    override init(_ canvas: Canvas) {
        super.init(canvas)
    }
    
    func getSelectedPixel() {
        let pos = canvas.transPosition(canvas.initTouchPosition)
        
        selectedHex = grid.findColorSelected(pos)
        sameColorPixels = grid.getLocations(hex: selectedHex)
        selectedArea.selectedPixels = [:]
        findSameColorPixels(Int(pos.x), Int(pos.y))
    }
    
    func findSameColorPixels(_ x: Int, _ y: Int) {
        addSelectedPixel(CGPoint(x: x, y: y))
        removePixelInArray(CGPoint(x: x, y: y))
        if (isSameColor(x + 1, y)) { findSameColorPixels(x + 1, y) }
        if (isSameColor(x - 1, y)) { findSameColorPixels(x - 1, y) }
        if (isSameColor(x, y + 1)) { findSameColorPixels(x, y + 1) }
        if (isSameColor(x, y - 1)) { findSameColorPixels(x, y - 1) }
    }
    
    func removePixelInArray(_ pos: CGPoint) {
        let x = Int(pos.x)
        let y = Int(pos.y)
        guard let pos = sameColorPixels[x] else { return }
        guard let index = pos.firstIndex(of: y) else { return }
        sameColorPixels[x]?.remove(at: index)
    }
    
    func isSameColor(_ x: Int, _ y: Int) -> Bool {
        guard let posX = sameColorPixels[x] else { return false }
        return posX.firstIndex(of: y) != nil
    }
    
    func isTouchedInsideArea(_ pos: CGPoint) -> Bool {
        return isSelectedPixel(pos)
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

