//
//  switchTouchesFunc.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

extension Canvas {
    func switchToolsTouchesBegan(_ pixelPosition: [String: Int]) {
        guard let selectedLayer = panelVC.layerVM.selectedLayer else { return }
        if (!selectedLayer.ishidden) {
            switch panelVC.drawingToolVM.selectedTool.name {
            case "SelectSquare":
                print("select square")
            case "Line", "Square":
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
    }
    
    func switchToolsTouchesBeganOnDraw(_ context: CGContext) {
        guard let selectedLayer = panelVC.layerVM.selectedLayer else { return }
        if (!selectedLayer.ishidden) {
            switch panelVC.drawingToolVM.selectedTool.name {
            case "Pencil":
                pencilTool.drawAnchor(context)
            case "Picker":
                pickerTool.drawPicker(context)
            case "Undo":
                undoTool.undoCanvasData()
            default: break
            }
        }
    }
    
    func switchToolsTouchesMoved(_ context: CGContext) {
        switch panelVC.drawingToolVM.selectedTool.name {
        case "SelectSquare":
            print("move square")
        case "Line":
            lineTool.addDiagonalPixels(context, isGuideLine: true)
        case "Square":
            squareTool.addSquarePixels(context, isGuideLine: true)
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
        case "SelectSquare":
            print("end square")
        case "Line":
            lineTool.addDiagonalPixels(context, isGuideLine: false)
        case "Square":
            squareTool.addSquarePixels(context, isGuideLine: false)
        case "Picker":
            let endPosition = transPosition(moveTouchPosition)
            let removedColor = grid.findColorSelected(x: endPosition["x"]!, y: endPosition["y"]!)
            if (removedColor != "none") {
                selectedColor = removedColor.uicolor
                panelVC.colorPaletteVM.selectedColorIndex = -1
                panelVC.colorPickerToolBar.selectedColor = removedColor.uicolor
                panelVC.colorPickerToolBar.updateColorBasedCanvasForThreeSection(true)
            }
        default: break
        }
    }
}
