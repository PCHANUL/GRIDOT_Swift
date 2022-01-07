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
    
    func initToolSetting() {
        drawOutlineInterval?.invalidate()
        accX = 0
        accY = 0
        canvas.selectedPixels = [:]
    }
    
    func getSelectedPixel() {
        let pos = canvas.transPosition(canvas.initTouchPosition)
        guard let x = pos["x"] else { return }
        guard let y = pos["y"] else { return }
        let hex = grid.findColorSelected(x: x, y: y)
        if (isSelectedPixel(x, y) == false) {
            selectedHex = hex
            sameColorPixels = grid.getLocations(hex: hex)
            canvas.selectedPixels = [:]
            findSameColorPixels(hex, x, y)
        }
    }
    
    func findSameColorPixels(_ hex: String, _ x: Int, _ y: Int) {
        addSelectedPixel(x, y)
        removePixelInArray(hex, x, y)
        if (isSameColor(x + 1, y)) { findSameColorPixels(hex, x + 1, y) }
        if (isSameColor(x - 1, y)) { findSameColorPixels(hex, x - 1, y) }
        if (isSameColor(x, y + 1)) { findSameColorPixels(hex, x, y + 1) }
        if (isSameColor(x, y - 1)) { findSameColorPixels(hex, x, y - 1) }
    }
    
    func removePixelInArray(_ hex: String, _ x: Int, _ y: Int) {
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
    
    func setSelectedArea() {
        getSelectedPixel()
        canvas.startDrawOutlineInterval()
        canvas.isDrawingSelectLine = true
    }
}

extension MagicTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
        switch canvas.selectedDrawingMode {
        case "pen":
            setSelectedArea()
        case "touch":
            return
        default:
            return
        }
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            return
        case "touch":
            return
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        
    }
    
    func buttonDown() {
        canvas.initTouchPosition = canvas.moveTouchPosition
        setSelectedArea()
    }
    
    func buttonUp() {
        
    }
}

