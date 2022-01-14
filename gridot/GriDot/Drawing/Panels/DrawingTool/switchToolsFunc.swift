//
//  switchTouchesFunc.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

extension Canvas {
    
    func switchToolsAlwaysUnderGirdLine(_ context: CGContext) {
        switch selectedDrawingTool {
        case "Photo":
            photoTool.alwaysUnderGirdLine(context)
        default:
            return
        }
    }
    
    func switchToolsNoneTouches(_ context: CGContext) {
        guard let selectedLayer = drawingVC.layerVM.selectedLayer else { return }
        if (!selectedLayer.ishidden) {
            switch selectedDrawingMode {
            case "pen":
                switch selectedDrawingTool {
                case "Photo":
                    photoTool.noneTouches(context)
                case "Picker":
                    pickerTool.noneTouches(context)
                default:
                    return
                }
            case "touch":
                switch selectedDrawingTool {
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
    
    func switchToolsTouchesBegan(_ touchPosition: CGPoint) {
        guard let selectedLayer = drawingVC.layerVM.selectedLayer else { return }
        let pixelPosition = transPosition(touchPosition)
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesBegan(pixelPosition)
        }
        if (!selectedLayer.ishidden) {
            switch selectedDrawingTool {
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
                photoTool.touchesBegan(touchPosition)
            case "Hand":
                handTool.touchesBegan(pixelPosition)
            default: break
            }
        }
    }
    
    func switchToolsTouchesBeganOnDraw(_ context: CGContext) {
        guard let selectedLayer = drawingVC.layerVM.selectedLayer else { return }
        if (!selectedLayer.ishidden) {
            switch selectedDrawingTool {
            case "Paint":
                paintTool.touchesBeganOnDraw(context)
            case "SelectSquare":
                selectSquareTool.touchesBeganOnDraw(context)
            case "Line":
                lineTool.touchesBeganOnDraw(context)
            case "Square":
                squareTool.touchesBeganOnDraw(context, isFilledSquare: false)
            case "SquareFilled":
                squareTool.touchesBeganOnDraw(context, isFilledSquare: true)
            case "Pencil":
                pencilTool.touchesBeganOnDraw(context)
            case "Eraser":
                eraserTool.touchesBeganOnDraw(context)
            case "Picker":
                pickerTool.touchesBeganOnDraw(context)
            case "Photo":
                photoTool.touchesBeganOnDraw(context)
            case "Hand":
                handTool.touchesBeganOnDraw(context)
            default: break
            }
        }
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesBeganOnDraw(context)
        }
    }
    
    func switchToolsTouchesMoved(_ context: CGContext) {
        switch selectedDrawingTool {
        case "Paint":
            paintTool.touchesMoved(context)
        case "SelectSquare":
            selectSquareTool.touchesMoved(context)
        case "Line":
            lineTool.touchesMoved(context)
        case "Square":
            squareTool.touchesMoved(context, isFilledSquare: false)
        case "SquareFilled":
            squareTool.touchesMoved(context, isFilledSquare: true)
        case "Eraser":
            eraserTool.touchesMoved(context)
        case "Pencil":
            pencilTool.touchesMoved(context)
        case "Picker":
            pickerTool.touchesMoved(context)
        case "Photo":
            photoTool.touchesMoved(context)
        case "Hand":
            handTool.touchesMoved(context)
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
        switch selectedDrawingTool {
        case "Paint":
            paintTool.touchesEnded(context)
        case "Magic":
            magicTool.touchesEnded(context)
        case "SelectSquare":
            selectSquareTool.touchesEnded(context)
        case "Line":
            lineTool.touchesEnded(context)
        case "Square":
            squareTool.touchesEnded(context, isFilledSquare: false)
        case "SquareFilled":
            squareTool.touchesEnded(context, isFilledSquare: true)
        case "Picker":
            pickerTool.touchesEnded(context)
        case "Pencil":
            pencilTool.touchesEnded(context)
        case "Eraser":
            eraserTool.touchesEnded(context)
        case "Photo":
            photoTool.touchesEnded(context)
        case "Hand":
            handTool.touchesEnded(context)
        default: break
        }
    }
    
    func switchToolsInitSetting() {
        switch selectedDrawingTool {
        case "Picker":
            pickerTool.initToolSetting()
        default:
            return
        }
    }
    
    func switchToolsSetUnused() {
        switch selectedDrawingTool {
        case "Picker":
            pickerTool.setUnused()
        case "Hand":
            handTool.setUnused()
        default:
            return
        }
    }
    
    func switchToolsButtonDown(_ buttonNo: Int) {
        switch selectedDrawingTool {
        case "SelectSquare":
            selectSquareTool.buttonDown()
        case "Paint":
            paintTool.buttonDown()
        case "Eraser":
            eraserTool.buttonDown()
        case "Magic":
            magicTool.buttonDown()
        case "Hand":
            handTool.buttonDown()
        default:
            return
        }
    }
    
    func switchToolsButtonUp(_ buttonNo: Int) {
        switch selectedDrawingTool {
        case "SelectSquare":
            selectSquareTool.buttonUp()
        case "Paint":
            paintTool.buttonUp()
        case "Pencil":
            pencilTool.buttonUp()
        case "Eraser":
            eraserTool.buttonUp()
        case "Square", "SquareFilled":
            squareTool.buttonUp()
        case "Line":
            lineTool.buttonUp()
        case "Magic":
            magicTool.buttonUp()
        case "Hand":
            handTool.buttonUp()
        default:
            return
        }
    }
}

