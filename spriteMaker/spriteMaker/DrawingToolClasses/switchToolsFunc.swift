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
            let position = transPosition(moveTouchPosition)
            selectPixel(pixelPosition: position)
        case "Eraser":
            print("eraser")
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
            let pixelPosition = transPosition(moveTouchPosition)
            removePixel(pixelPosition: pixelPosition)
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
