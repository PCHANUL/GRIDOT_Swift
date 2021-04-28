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
            selectPixel(pixelPosition: transPosition(initTouchPosition))
        case "Eraser":
            let removedColor = grid.findColorSelected(x: pixelPosition["x"]!, y: pixelPosition["y"]!)
            if (removedColor != "none") {
                selectedColor = removedColor.uicolor
                panelVC.colorPaletteVM.selectedColorIndex = -1
                panelVC.colorPickerToolBar.selectedColor = removedColor.uicolor
                panelVC.colorPickerToolBar.updateColorBasedCanvasForThreeSection(true)
            }
            removePixel(pixelPosition: transPosition(initTouchPosition))
        default: break
        }
    }
    
    func switchToolsTouchesBeganOnDraw(_ context: CGContext) {
        switch panelVC.drawingToolVM.selectedTool.name {
        case "Pencil":
            pencilTool.drawAnchor(context)
        case "Picker":
            pickerTool.drawPicker(context)
        default: break
        }
    }
    
    func switchToolsTouchesMoved(_ context: CGContext) {
        switch panelVC.drawingToolVM.selectedTool.name {
        case "Line":
            lineTool.drawTouchGuideLine(context)
        case "Eraser":
            eraserTool.drawEraser(context)
            removePixel(pixelPosition: transPosition(moveTouchPosition))
        case "Pencil":
            pencilTool.drawPixel(context)
            pencilTool.drawAnchor(context)
        case "Picker":
            pickerTool.drawPicker(context)
        default: break
        }
    }
    
    func switchToolsTouchesEnded(_ context: CGContext) {
        switch panelVC.drawingToolVM.selectedTool.name {
        case "Line":
            lineTool.addDiagonalPixels(context)
        default: break
        }
    }
}
