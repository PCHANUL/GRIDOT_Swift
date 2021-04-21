//
//  switchTouchesFunc.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

extension Canvas {
    func switchToolsTouchesBegan(_ pixelPosition: [String: Int]) {
        switch panelVC.drawingToolVM.selectedTool.name {
        case "Line":
            print("line")
            selectPixel(pixelPosition: transPosition(moveTouchPosition))
        case "Eraser":
            print("eraser")
            let removedColor = grid.findColorSelected(x: pixelPosition["x"]!, y: pixelPosition["y"]!)
            if (removedColor != "none") {
                selectedColor = removedColor.uicolor
                panelVC.colorPaletteVM.selectedColorIndex = -1
                panelVC.colorPickerToolBar.selectedColor = removedColor.uicolor
                panelVC.colorPickerToolBar.updateColorBasedCanvasForThreeSection(true)
            }
            removePixel(pixelPosition: transPosition(moveTouchPosition))
            
        default: break
        }
    }
    
    func switchToolsTouchesMoved(_ context: CGContext) {
        switch panelVC.drawingToolVM.selectedTool.name {
        case "Line":
            print("line")
            lineTool.drawTouchGuideLine(context)
        case "Eraser":
            print("eraser")
            eraserTool.drawEraser(context)
            removePixel(pixelPosition: transPosition(moveTouchPosition))
        default: break
        }
    }
    
    func switchToolsTouchesEnded(_ context: CGContext) {
        switch panelVC.drawingToolVM.selectedTool.name {
        case "Line":
            print("line")
            lineTool.addDiagonalPixels(context)
        case "Eraser":
            print("eraser")
        default: break
        }
    }
}
