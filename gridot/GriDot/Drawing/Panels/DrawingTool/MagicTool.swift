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
        guard let x = pos["x"] else { return }
        guard let y = pos["y"] else { return }
        
        selectedHex = grid.findColorSelected(x: x, y: y)
        sameColorPixels = grid.getLocations(hex: selectedHex)
        selectedArea.selectedPixels = [:]
        findSameColorPixels(x, y)
    }
    
    func findSameColorPixels(_ x: Int, _ y: Int) {
        addSelectedPixel(x, y)
        removePixelInArray(x, y)
        if (isSameColor(x + 1, y)) { findSameColorPixels(x + 1, y) }
        if (isSameColor(x - 1, y)) { findSameColorPixels(x - 1, y) }
        if (isSameColor(x, y + 1)) { findSameColorPixels(x, y + 1) }
        if (isSameColor(x, y - 1)) { findSameColorPixels(x, y - 1) }
    }
    
    func removePixelInArray(_ x: Int, _ y: Int) {
        guard let pos = sameColorPixels[x] else { return }
        guard let index = pos.firstIndex(of: y) else { return }
        sameColorPixels[x]?.remove(at: index)
    }
    
    func isSameColor(_ x: Int, _ y: Int) -> Bool {
        guard let posX = sameColorPixels[x] else { return false }
        return posX.firstIndex(of: y) != nil
    }
    
    func isTouchedInsideArea(_ position: [String: Int]) -> Bool {
        guard let x = position["x"] else { return false }
        guard let y = position["y"] else { return false }
        return isSelectedPixel(x, y)
    }
    
    override func touchesBegan(_ pixelPosition: [String: Int]) {
        super.touchesBegan(pixelPosition)
        
        switch canvas.selectedDrawingMode {
        case "pen":
            getSelectedPixel()
        case "touch":
            return
        default:
            return
        }
    }
}

