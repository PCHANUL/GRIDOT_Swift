//
//  switchTouchesFunc.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

extension Canvas {
    
    func switchToolsAlwaysUnderGirdLine(_ context: CGContext) {
        switch drawingCVC.drawingToolVM.selectedTool.name {
        case "Photo":
            photoTool.alwaysUnderGirdLine(context)
        default:
            return
        }
    }
    
    func switchToolsNoneTouches(_ context: CGContext) {
        guard let selectedLayer = drawingCVC.layerVM.selectedLayer else { return }
        if (!selectedLayer.ishidden) {
            switch selectedDrawingMode {
            case "pen":
                switch drawingCVC.drawingToolVM.selectedTool.name {
                case "Photo":
                    photoTool.noneTouches(context)
                default:
                    return
                }
            case "touch":
                switch drawingCVC.drawingToolVM.selectedTool.name {
                case "Pencil":
                    pencilTool.noneTouches(context)
                default:
                    break
                }
                touchDrawingMode.noneTouches(context)
            default:
                return
            }
        }
    }
    
    func switchToolsTouchesBegan(_ pixelPosition: [String: Int]) {
        guard let selectedLayer = drawingCVC.layerVM.selectedLayer else { return }
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesBegan(pixelPosition)
        }
        print(drawingCVC.drawingToolVM.selectedTool.name)
        if (!selectedLayer.ishidden) {
            switch drawingCVC.drawingToolVM.selectedTool.name {
            case "Paint":
                paintTool.touchesBegan(pixelPosition)
            case "Magic":
                magicTool.touchesBegan(pixelPosition)
            case "SelectSquare":
                selectSquareTool.touchesBegan(pixelPosition)
            case "Line":
                lineTool.touchesBegan(pixelPosition)
            case "Square":
                squareTool.touchesBegan(pixelPosition)
            case "Eraser":
                eraserTool.touchesBegan(pixelPosition)
            case "Picker":
                pickerTool.touchesBegan(pixelPosition)
            case "Photo":
                photoTool.touchesBegan(pixelPosition)
            default: break
            }
        }
    }
    
    func switchToolsTouchesBeganOnDraw(_ context: CGContext) {
        guard let selectedLayer = drawingCVC.layerVM.selectedLayer else { return }
        if (!selectedLayer.ishidden) {
            switch drawingCVC.drawingToolVM.selectedTool.name {
            case "Paint":
                paintTool.touchesBeganOnDraw(context)
            case "Magic":
                magicTool.touchesBeganOnDraw(context)
            case "SelectSquare":
                selectSquareTool.touchesBeganOnDraw(context)
            case "Line":
                lineTool.touchesBeganOnDraw(context)
            case "Square":
                squareTool.touchesBeganOnDraw(context)
            case "Pencil":
                pencilTool.touchesBeganOnDraw(context)
            case "Eraser":
                eraserTool.touchesBeganOnDraw(context)
            case "Picker":
                pickerTool.touchesBeganOnDraw(context)
            case "Photo":
                photoTool.touchesBeganOnDraw(context)
            default: break
            }
        }
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesBeganOnDraw(context)
        }
    }
    
    func switchToolsTouchesMoved(_ context: CGContext) {
        switch drawingCVC.drawingToolVM.selectedTool.name {
        case "Paint":
            paintTool.touchesMoved(context)
        case "Magic":
            magicTool.touchesMoved(context)
        case "SelectSquare":
            selectSquareTool.touchesMoved(context)
        case "Line":
            lineTool.touchesMoved(context)
        case "Square":
            squareTool.touchesMoved(context)
        case "Eraser":
            eraserTool.touchesMoved(context)
        case "Pencil":
            pencilTool.touchesMoved(context)
        case "Picker":
            pickerTool.touchesMoved(context)
        case "Photo":
            photoTool.touchesMoved(context)
        default: break
        }
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesMoved(context)
        }
    }
    
    func switchToolsTouchesEnded(_ context: CGContext) {
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesEnded(context)
        }
        switch drawingCVC.drawingToolVM.selectedTool.name {
        case "Paint":
            paintTool.touchesEnded(context)
        case "Magic":
            magicTool.touchesEnded(context)
        case "SelectSquare":
            selectSquareTool.touchesEnded(context)
        case "Line":
            lineTool.touchesEnded(context)
        case "Square":
            squareTool.touchesEnded(context)
        case "Picker":
            pickerTool.touchesEnded(context)
        case "Pencil":
            pencilTool.touchesEnded(context)
        case "Eraser":
            eraserTool.touchesEnded(context)
        case "Photo":
            photoTool.touchesEnded(context)
        default: break
        }
    }
    
    func switchToolsButtonDown() {
        print("down", drawingCVC.drawingToolVM.selectedTool.name)
        switch drawingCVC.drawingToolVM.selectedTool.name {
        case "SelectSquare":
            selectSquareTool.buttonDown()
        case "Paint":
            paintTool.buttonDown()
        case "Eraser":
            eraserTool.buttonDown()
        case "Magic":
            magicTool.buttonDown()
        default:
            return
        }
    }
    
    func switchToolsButtonUp() {
        switch drawingCVC.drawingToolVM.selectedTool.name {
        case "SelectSquare":
            selectSquareTool.buttonUp()
        case "Paint":
            paintTool.buttonUp()
        case "Pencil":
            pencilTool.buttonUp()
        case "Eraser":
            eraserTool.buttonUp()
        case "Square":
            squareTool.buttonUp()
        case "Line":
            lineTool.buttonUp()
        case "Magic":
            magicTool.buttonUp()
        default:
            return
        }
    }
}

