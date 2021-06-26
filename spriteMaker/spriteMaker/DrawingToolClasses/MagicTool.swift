//
//  MagicTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/20.
//

import UIKit

class MagicTool: SelectTool {
    var colorPositions: [Int: [Int]] = [:]
    
    override init(_ canvas: Canvas) {
        super.init(canvas)
    }
    
    func setSelectedPosition(_ hex: String, _ pos: [String: Int]) {
        guard let x = pos["x"] else { return }
        guard let y = pos["y"] else { return }
        if (isSelectedPosition(hex, x, y) == false) {
            let color = canvas.grid.findColorSelected(x: x, y: y)
            colorPositions = grid.getLocations(hex: color)
            selectedPositions = [:]
            findSameColorPosition(color, x, y)
        }
        if (!(drawOutlineInterval?.isValid ?? false)) {
            startDrawOutlineInterval()
        }
    }
    
    func drawHorizontalOutline(_ context: CGContext, _ x: CGFloat, _ y: CGFloat, _ toggle: Bool!) {
        if (toggle) {
            context.move(to: CGPoint(x: x, y: y))
            context.addLine(to: CGPoint(x: x + outlineTerm, y: y))
            context.move(to: CGPoint(x: x + (outlineTerm * 3), y: y))
            context.addLine(to: CGPoint(x: x + (outlineTerm * 4), y: y))
        } else {
            context.move(to: CGPoint(x: x + outlineTerm, y: y))
            context.addLine(to: CGPoint(x: x + (outlineTerm * 3), y: y))
        }
        context.strokePath()
    }
    
    func drawVerticalOutline(_ context: CGContext, _ x: CGFloat, _ y: CGFloat, _ toggle: Bool!) {
        if (toggle) {
            context.move(to: CGPoint(x: x, y: y))
            context.addLine(to: CGPoint(x: x, y: y + outlineTerm))
            context.move(to: CGPoint(x: x, y: y + (outlineTerm * 3)))
            context.addLine(to: CGPoint(x: x, y: y + (outlineTerm * 4)))
        } else {
            context.move(to: CGPoint(x: x, y: y + outlineTerm))
            context.addLine(to: CGPoint(x: x, y: y + (outlineTerm * 3)))
        }
        context.strokePath()
    }
    
    func drawSelectedOutline(_ context: CGContext) {
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        for hex in selectedPositions {
            for posX in hex.value {
                for posY in posX.value {
                    let x = pixelLen * CGFloat(posX.key)
                    let y = pixelLen * CGFloat(posY)
                    if (!isSelectedPosition(hex.key, posX.key, posY - 1)) { drawHorizontalOutline(context, x, y, outlineToggle) }
                    if (!isSelectedPosition(hex.key, posX.key, posY + 1)) { drawHorizontalOutline(context, x, y + pixelLen, outlineToggle) }
                    if (!isSelectedPosition(hex.key, posX.key - 1, posY)) { drawVerticalOutline(context, x, y, outlineToggle) }
                    if (!isSelectedPosition(hex.key, posX.key + 1, posY)) { drawVerticalOutline(context, x + pixelLen, y, outlineToggle) }
                }
            }
        }
    }
    
    func startDrawOutlineInterval() {
        outlineToggle = true
        drawOutlineInterval = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true)
        { (Timer) in
            if (self.canvas.panelVC.drawingToolVM.selectedTool.name != "Magic") {
                Timer.invalidate()
            }
            self.canvas.setNeedsDisplay()
            self.outlineToggle = !self.outlineToggle
        }
    }
    
    func isSelectedPosition(_ hex: String, _ x: Int, _ y: Int) -> Bool {
        guard let posX = selectedPositions[hex]?[x] else { return false }
        return posX.firstIndex(of: y) != nil
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
    
    func addPosition(_ hex: String, _ x: Int, _ y: Int) {
        if (selectedPositions[hex] == nil) { selectedPositions[hex] = [:] }
        if (selectedPositions[hex]?[x] == nil) { selectedPositions[hex]?[x] = [] }
        selectedPositions[hex]?[x]?.append(y)
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

