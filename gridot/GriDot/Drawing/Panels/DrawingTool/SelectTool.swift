//
//  SelectTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/26.
//

import UIKit

class SelectTool: NSObject {
    var grid: Grid!
    var canvas: Canvas!
    var selectedArea: SelectedArea!
    var pixelLen: CGFloat!
    var outlineTerm: CGFloat!
    var outlineToggle: Bool!
    var drawOutlineInterval: Timer?
    
    var accX: CGFloat = 0
    var accY: CGFloat = 0
    var startX: CGFloat = 0
    var startY: CGFloat = 0
    var endX: CGFloat = 0
    var endY: CGFloat = 0
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.selectedArea = canvas.selectedArea
        self.pixelLen = canvas.onePixelLength
        self.outlineTerm = self.pixelLen / 4
        self.outlineToggle = true
    }
    
    func setStartPosition(_ touchPos: CGPoint) {
        startX = pixelLen * touchPos.x
        startY = pixelLen * touchPos.y
    }
    
    func setMovePosition(_ touchPos: CGPoint) {
        endX = pixelLen * touchPos.x
        endY = pixelLen * touchPos.y
        accX = endX - startX
        accY = endY - startY
    }
    
    func drawHorizontalOutline(_ context: CGContext, _ x: CGFloat, _ y: CGFloat, _ toggle: Bool!) {
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.init(named: "Icon")!.cgColor)
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
        context.setStrokeColor(UIColor.init(named: "Icon")!.cgColor)
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
    
    func touchesBeganOnDraw(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            return
        case "touch":
            return
        default:
            return
        }
    }

    func touchesBegan(_ pixelPos: CGPoint) {
        switch canvas.selectedDrawingMode {
        case "pen":
            selectedArea.initSelectedAreaToStart()
        case "touch":
            return
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            selectedArea.setSelectedGrid()
        default:
            return
        }
    }
    
    func buttonDown() {
        selectedArea.initSelectedAreaToStart()
    }
    
    func buttonUp() {
        selectedArea.setSelectedGrid()
    }
}
