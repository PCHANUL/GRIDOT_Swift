//
//  switchTouchesFunc.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

extension Canvas {
    func switchToolsTouchesBegan() {
        switch panelVC.drawingToolVM.selectedTool.name {
        case "Line":
            print("line")
            selectPixel(pixelPosition: transPosition(moveTouchPosition))
        case "Eraser":
            print("eraser")
            removePixel(pixelPosition: transPosition(moveTouchPosition))
//            selectedColor
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
