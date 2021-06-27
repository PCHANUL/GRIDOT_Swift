//
//  SelectTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/26.
//

import UIKit

class SelectTool {
    var grid: Grid!
    var canvas: Canvas!
    var canvasLen: CGFloat!
    var pixelLen: CGFloat!
    var outlineTerm: CGFloat!
    var outlineToggle: Bool!
    var selectedPixels: [String: [Int: [Int]]] = [:]
    var drawOutlineInterval: Timer?
    
    var isTouchedInside: Bool!
    var accX: CGFloat = 0
    var accY: CGFloat = 0
    var startX: CGFloat = 0
    var startY: CGFloat = 0
    var endX: CGFloat = 0
    var endY: CGFloat = 0

    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.canvasLen = canvas.lengthOfOneSide
        self.pixelLen = canvas.onePixelLength
        self.outlineTerm = self.pixelLen / 4
        self.isTouchedInside = false
        self.outlineToggle = true
    }
    
    func isSelectedPosition(_ hex: String, _ x: Int, _ y: Int) -> Bool {
        guard let posHex = selectedPixels[hex] else { return false }
        guard let posX = posHex[x] else { return false }
        return posX.firstIndex(of: y) != nil
    }
    
    func setStartPosition(_ touchPosition: [String: Int]) {
        startX = (pixelLen * CGFloat(touchPosition["x"]!))
        startY = (pixelLen * CGFloat(touchPosition["y"]!))
    }
    
    func setMovePosition(_ touchPosition: [String: Int]) {
        endX = pixelLen * CGFloat(touchPosition["x"]! + 1)
        endY = pixelLen * CGFloat(touchPosition["y"]! + 1)
        accX = endX - startX
        accY = endY - startY
    }
    
    func addPosition(_ hex: String, _ x: Int, _ y: Int) {
        if (selectedPixels[hex] == nil) { selectedPixels[hex] = [:] }
        if (selectedPixels[hex]?[x] == nil) { selectedPixels[hex]?[x] = [] }
        selectedPixels[hex]?[x]?.append(y)
    }
    
    func moveSelectedAreaPixels() {
        var arr: [Int: [Int]]
        for color in selectedPixels {
            arr = [:]
            for x in color.value {
                let xkey = Int(x.key) + Int(accX / pixelLen)
                arr[xkey] = x.value.map({ return $0 + Int(accY / pixelLen) })
            }
            selectedPixels[color.key] = arr
        }
    }
    
    func drawSelectedAreaPixels(_ context: CGContext) {
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(0.5)
        let widthOfPixel = Double(pixelLen)
        for color in selectedPixels {
            for x in color.value {
                for y in x.value {
                    context.setFillColor(color.key.uicolor!.cgColor)
                    let xlocation = (Double(x.key) * widthOfPixel) + Double(accX)
                    let ylocation = (Double(y) * widthOfPixel)  + Double(accY)
                    let rectangle = CGRect(x: xlocation, y: ylocation,
                                           width: widthOfPixel, height: widthOfPixel)
                    context.addRect(rectangle)
                    context.drawPath(using: .fillStroke)
                }
            }
        }
        context.strokePath()
    }
    
    func drawHorizontalOutline(_ context: CGContext, _ x: CGFloat, _ y: CGFloat, _ toggle: Bool!) {
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.white.cgColor)
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
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.white.cgColor)
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
