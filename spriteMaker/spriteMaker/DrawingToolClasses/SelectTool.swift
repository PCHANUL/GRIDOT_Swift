//
//  SelectTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/26.
//

import UIKit

class SelectTool {
    var canvas: Canvas!
    var grid: Grid!
    var pixelLen: CGFloat!
    var outlineTerm: CGFloat!
    var outlineToggle: Bool!
    var selectedPositions: [String: [Int: [Int]]] = [:]
    var drawOutlineInterval: Timer?

    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.pixelLen = canvas.onePixelLength
        self.outlineTerm = self.pixelLen / 4
    }
    
    func isSelectedPosition(_ hex: String, _ x: Int, _ y: Int) -> Bool {
        guard let posHex = selectedPositions[hex] else { return false }
        guard let posX = posHex[x] else { return false }
        return posX.firstIndex(of: y) != nil
    }
    
    func addPosition(_ hex: String, _ x: Int, _ y: Int) {
        if (selectedPositions[hex] == nil) { selectedPositions[hex] = [:] }
        if (selectedPositions[hex]?[x] == nil) { selectedPositions[hex]?[x] = [] }
        selectedPositions[hex]?[x]?.append(y)
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
}
