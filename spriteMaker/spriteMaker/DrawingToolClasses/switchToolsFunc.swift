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
            print("draw")
            switch selectedDrawingMode {
            case "pen":
                print("pen")
            case "touch":
                print("touch")
                // 캔버스 화면 가운데에 손가락을 그린다.
                setCenterTouchPosition()
                context.setShadow(offset: CGSize(), blur: 0)
                context.setFillColor(self.selectedColor.cgColor)
                context.addArc(center: self.moveTouchPosition, radius: self.onePixelLength / 4, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
                context.fillPath()
                
                guard let image = UIImage(named: "finger") else { return }
                let flipedImage = flipImageVertically(originalImage: image)
                context.setShadow(offset: CGSize(width: 0, height: 0), blur: 10)
                context.draw(flipedImage.cgImage!, in: CGRect(x: self.moveTouchPosition.x - 1.5, y: self.moveTouchPosition.y - 0.5, width: 20, height: 20))
                context.fillPath()
                
            default:
                return
            }
        }
    }
    
    func switchToolsTouchesBegan(_ pixelPosition: [String: Int]) {
        guard let selectedLayer = panelVC.layerVM.selectedLayer else { return }
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
            case "Undo":
                timeMachineVM.undo()
            default: break
            }
        }
    }
    
    func switchToolsTouchesBeganOnDraw(_ context: CGContext) {
        guard let selectedLayer = panelVC.layerVM.selectedLayer else { return }
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
