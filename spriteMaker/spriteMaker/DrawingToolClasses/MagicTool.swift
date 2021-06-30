//
//  MagicTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/20.
//

import UIKit

class MagicTool: SelectTool {
    var colorPositions: [Int: [Int]] = [:]
    var selectedHex: String!
    
    override init(_ canvas: Canvas) {
        super.init(canvas)
    }
    
    func setSelectedPosition(_ hex: String, _ pos: [String: Int]) {
        guard let x = pos["x"] else { return }
        guard let y = pos["y"] else { return }
        if (isSelectedPosition(x, y) == false) {
            selectedHex = hex
            colorPositions = grid.getLocations(hex: hex)
            selectedPixels = [:]
            findSameColorPosition(hex, x, y)
        }
    }
    
    func removeSelectedPixels() {
        for color in selectedPixels {
            for x in color.value {
                for y in x.value {
                    grid.removeLocationIfSelected(hex: color.key, x: x.key, y: y);
                }
            }
        }
    }
    
    func drawSelectedAreaOutline(_ context: CGContext) {
        if (isTouchedInside) { return }
        guard let positions = selectedPixels[selectedHex] else { return }
        let addX = Int(accX / pixelLen)
        let addY = Int(accY / pixelLen)
        for posX in positions {
            for posY in posX.value {
                let x = (pixelLen * CGFloat(posX.key)) + CGFloat(accX)
                let y = (pixelLen * CGFloat(posY)) + CGFloat(accY)
                if (!isSelectedPosition(posX.key + addX, posY + addY - 1)) { drawHorizontalOutline(context, x, y, outlineToggle) }
                if (!isSelectedPosition(posX.key + addX, posY + addY + 1)) { drawHorizontalOutline(context, x, y + pixelLen, outlineToggle) }
                if (!isSelectedPosition(posX.key + addX - 1, posY + addY)) { drawVerticalOutline(context, x, y, outlineToggle) }
                if (!isSelectedPosition(posX.key + addX + 1, posY + addY)) { drawVerticalOutline(context, x + pixelLen, y, outlineToggle) }
            }
        }
    }
    
    func isTouchedInsideArea(_ position: [String: Int]) -> Bool {
        guard let x = position["x"] else { return false }
        guard let y = position["y"] else { return false }
        return isSelectedPosition(x, y)
    }
    
    func isPosition(_ x: Int, _ y: Int) -> Bool {
        guard let posX = colorPositions[x] else { return false }
        return posX.firstIndex(of: y) != nil
    }
    
    func removePosition(_ hex: String, _ x: Int, _ y: Int) {
        guard let pos = colorPositions[x] else { return }
        guard let index = pos.firstIndex(of: y) else { return }
        colorPositions[x]?.remove(at: index)
    }
    
    func findSameColorPosition(_ hex: String, _ x: Int, _ y: Int) {
        addPosition(hex, x, y)
        removePosition(hex, x, y)
        if (isPosition(x + 1, y)) { findSameColorPosition(hex, x + 1, y) }
        if (isPosition(x - 1, y)) { findSameColorPosition(hex, x - 1, y) }
        if (isPosition(x, y + 1)) { findSameColorPosition(hex, x, y + 1) }
        if (isPosition(x, y - 1)) { findSameColorPosition(hex, x, y - 1) }
    }
}
