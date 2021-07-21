//
//  switchTouchesFunc.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

extension Canvas {
    func switchToolsNoneTouches(_ context: CGContext) {
        guard let selectedLayer = panelVC.layerVM.selectedLayer else { return }
        if (!selectedLayer.ishidden) {
            switch selectedDrawingMode {
            case "pen":
                print("pen")
            case "touch":
                print("touch")
                touchDrawingMode.noneTouches(context)
            default:
                return
            }
        }
    }
    
    // touch이고 active가 false이면 안된다.
    func switchToolsTouchesBegan(_ pixelPosition: [String: Int]) {
        guard let selectedLayer = panelVC.layerVM.selectedLayer else { return }
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesBegan(pixelPosition)
            if (!activatedDrawing) { return }
        }
        if (!selectedLayer.ishidden) {
            switch panelVC.drawingToolVM.selectedTool.name {
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
            default: break
            }
        }
    }
    
    func switchToolsTouchesBeganOnDraw(_ context: CGContext) {
        guard let selectedLayer = panelVC.layerVM.selectedLayer else { return }
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesBeganOnDraw(context)
            if (!activatedDrawing) { return }
        }
        if (!selectedLayer.ishidden) {
            switch panelVC.drawingToolVM.selectedTool.name {
            case "Paint":
                paintTool.touchesBeganOnDraw(context)
            case "Magic":
                magicTool.touchesBeganOnDraw(context)
            case "SelectSquare":
                selectSquareTool.touchesBeganOnDraw(context)
            case "Line":
                lineTool.touchesBeganOnDraw(context)
            case "Pencil":
                pencilTool.touchesBeganOnDraw(context)
            case "Picker":
                pickerTool.touchesBeganOnDraw(context)
            default: break
            }
        }
    }
    
    func switchToolsTouchesMoved(_ context: CGContext) {
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesMoved(context)
            if (!activatedDrawing) { return }
        }
        switch panelVC.drawingToolVM.selectedTool.name {
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
        default: break
        }
    }
    
    func switchToolsTouchesEnded(_ context: CGContext) {
        if (selectedDrawingMode == "touch") {
            touchDrawingMode.touchesEnded(context)
            if (!activatedDrawing) { return }
        }
        switch panelVC.drawingToolVM.selectedTool.name {
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
        default: break
        }
    }
}
