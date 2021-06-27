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
        if (isSelectedPosition(hex, x, y) == false) {
            selectedHex = hex
            colorPositions = grid.getLocations(hex: hex)
            selectedPixels = [:]
            findSameColorPosition(hex, x, y)
        }
        if (!(drawOutlineInterval?.isValid ?? false)) {
            startDrawOutlineInterval()
        }
    }
    
    func drawSelectedAreaOutline(_ context: CGContext) {
        guard let positions = selectedPixels[selectedHex] else { return }
        for posX in positions {
            for posY in posX.value {
                let x = pixelLen * CGFloat(posX.key)
                let y = pixelLen * CGFloat(posY)
                if (!isSelectedPosition(selectedHex, posX.key, posY - 1)) { drawHorizontalOutline(context, x, y, outlineToggle) }
                if (!isSelectedPosition(selectedHex, posX.key, posY + 1)) { drawHorizontalOutline(context, x, y + pixelLen, outlineToggle) }
                if (!isSelectedPosition(selectedHex, posX.key - 1, posY)) { drawVerticalOutline(context, x, y, outlineToggle) }
                if (!isSelectedPosition(selectedHex, posX.key + 1, posY)) { drawVerticalOutline(context, x + pixelLen, y, outlineToggle) }
            }
        }
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
