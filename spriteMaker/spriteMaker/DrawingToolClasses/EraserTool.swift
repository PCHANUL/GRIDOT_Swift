//
//  DrawingEraser.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

class EraserTool {
    var canvas: Canvas!
    var grid: Grid!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
    }
    
    func drawEraser(_ context: CGContext) {
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.addArc(center: canvas.moveTouchPosition, radius: canvas.onePixelLength / 1.5, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.strokePath()
        
        context.setFillColor(canvas.selectedColor.cgColor)
        context.addArc(center: canvas.moveTouchPosition, radius: canvas.onePixelLength / 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.fillPath()
    }
}

extension EraserTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
        let removedColor = grid.findColorSelected(x: pixelPosition["x"]!, y: pixelPosition["y"]!)
        if (removedColor != "none") {
            canvas.selectedColor = removedColor.uicolor
            canvas.panelVC.colorPaletteVM.selectedColorIndex = -1
            canvas.panelVC.colorPickerToolBar.selectedColor = removedColor.uicolor
            canvas.panelVC.colorPickerToolBar.updateColorBasedCanvasForThreeSection(true)
        }
        if (canvas.selectedDrawingMode == "pen") {
            canvas.removePixel(pixelPosition: canvas.transPosition(canvas.initTouchPosition))
        }
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        if (canvas.selectedDrawingMode == "touch") {
            canvas.moveTouchPosition = canvas.touchDrawingMode.cursorPosition
            drawEraser(context)
        }
    }
    
    func touchesMoved(_ context: CGContext) {
        drawEraser(context)
        switch canvas.selectedDrawingMode {
        case "pen":
            canvas.removePixel(pixelPosition: canvas.transPosition(canvas.moveTouchPosition))
        case "touch":
            if (canvas.activatedDrawing) {
                canvas.removePixel(pixelPosition: canvas.transPosition(canvas.moveTouchPosition))
            }
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        if (canvas.selectedDrawingMode == "pen") {
            canvas.timeMachineVM.addTime()
        }
    }
    
    func buttonDown() {
        canvas.removePixel(pixelPosition: canvas.transPosition(canvas.moveTouchPosition))
    }
    
    func buttonUp() {
        canvas.timeMachineVM.addTime()
    }
}
