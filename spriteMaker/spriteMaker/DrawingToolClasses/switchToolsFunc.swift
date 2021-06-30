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
            case "Magic":
                if (magicTool.isTouchedInsideArea(transPosition(initTouchPosition))) {
                    magicTool.removeSelectedAreaPixels()
                    magicTool.setStartPosition(transPosition(initTouchPosition))
                    magicTool.setMovePosition(transPosition(moveTouchPosition))
                    magicTool.isTouchedInside = true
                } else {
                    if (magicTool.isTouchedInside) {
                        magicTool.accX = 0
                        magicTool.accY = 0
                        magicTool.copyPixelsToGrid()
                        magicTool.isTouchedInside = false
                    }
                    let pos = transPosition(initTouchPosition)
                    let selectedColor = grid.findColorSelected(x: pos["x"]!, y: pos["y"]!)
                    magicTool.getSelectedPixel(selectedColor, pos)
                    magicTool.startDrawOutlineInterval("Magic")
                }
            case "SelectLasso":
                print("selectLasso")
            case "SelectSquare":
                if (selectSquareTool.isTouchedInsideArea(transPosition(moveTouchPosition))) {
                    selectSquareTool.setStartPosition(transPosition(initTouchPosition))
                    selectSquareTool.setMovePosition(transPosition(moveTouchPosition))
                    if (!selectSquareTool.isTouchedInside) {
                        selectSquareTool.getSelectedAreaPixels(grid)
                    }
                    selectSquareTool.isTouchedInside = true
                } else {
                    selectSquareTool.isTouchedInside = false
                    selectSquareTool.initPositions()
                    selectSquareTool.copyPixelsToGrid()
                    selectSquareTool.setStartPosition(transPosition(initTouchPosition))
                    selectSquareTool.setEndPosition(transPosition(moveTouchPosition))
                }
                selectSquareTool.startDrawOutlineInterval("SelectSquare")
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
            case "Magic":
                magicTool.drawSelectedAreaPixels(context)
                magicTool.drawSelectedAreaOutline(context)
            case "SelectLasso":
                print("selectLasso")
            case "SelectSquare":
                selectSquareTool.drawSelectedAreaPixels(context)
                selectSquareTool.drawSelectedAreaOutline(context)
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
        case "Magic":
            if (magicTool.isTouchedInside) {
                magicTool.setMovePosition(transPosition(moveTouchPosition))
            }
            magicTool.drawSelectedAreaPixels(context)
            magicTool.drawSelectedAreaOutline(context)
        case "SelectLasso":
            print("selectLasso")
        case "SelectSquare":
            if (selectSquareTool.isTouchedInside) {
                selectSquareTool.setMovePosition(transPosition(moveTouchPosition))
            } else {
                selectSquareTool.setEndPosition(transPosition(moveTouchPosition))
            }
            selectSquareTool.drawSelectedAreaPixels(context)
            selectSquareTool.drawSelectedAreaOutline(context)
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
        case "Magic":
            if (magicTool.isTouchedInside) {
                magicTool.moveSelectedAreaPixels()
                magicTool.copyPixelsToGrid()
                magicTool.isTouchedInside = false
                magicTool.startDrawOutlineInterval("Magic")
            }
        case "SelectLasso":
            print("selectLasso")
        case "SelectSquare":
            if (selectSquareTool.isTouchedInside) {
                selectSquareTool.endMovePosition()
            }
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
