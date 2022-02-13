//
//  HoldTool.swift
//  GriDot
//
//  Created by 박찬울 on 2022/01/11.
//

import UIKit

class HandTool: NSObject {
    var pixels: [String: [Int: [Int]]] = [:]
    var canvas: Canvas!
    var selectedArea: SelectedArea!
    var pixelLen: CGFloat!
    
    var startX: CGFloat = 0
    var startY: CGFloat = 0
    var endX: CGFloat = 0
    var endY: CGFloat = 0
    var isHolded: Bool = false
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.selectedArea = canvas.selectedArea
        self.pixelLen = canvas.onePixelLength
    }

    func setStartPosition(_ touchPos: CGPoint) {
        startX = pixelLen * touchPos.x
        startY = pixelLen * touchPos.y
    }
    
    func setMovePosition(_ touchPos: CGPoint) {
        endX = pixelLen * CGFloat(touchPos.x)
        endY = pixelLen * CGFloat(touchPos.y)
        selectedArea.acc.x = endX - startX
        selectedArea.acc.y = endY - startY
    }
    
    func getSelectedPixelsFromGrid() {
        if (!isHolded) {
            selectedArea.setSelectedGrid()
            isHolded = true
        }
    }
    
    func endedUsingHandTool() {
        if (selectedArea.intGrid.count != 0) {
            selectedArea.pos.x += selectedArea.acc.x
            selectedArea.pos.y += selectedArea.acc.y
            selectedArea.acc.x = 0
            selectedArea.acc.y = 0
        } else {
            selectedArea.moveSelectedPixelsToGrid()
            isHolded = false
        }
        canvas.timeMachineVM.addTime()
        canvas.setNeedsDisplay()
    }
}

extension HandTool {
    func setUnused() {
        if (isHolded) {
            selectedArea.moveSelectedPixelsToGrid()
            canvas.timeMachineVM.addTime()
            isHolded = false
            print("unused")
        }
    }
    
    func initToolSetting() {
        if (isHolded) {
            selectedArea.moveSelectedPixelsToGrid()
            isHolded = false
        }
    }
    
    func touchesBegan(_ pixelPos: CGPoint) {
        switch canvas.selectedDrawingMode {
        case "pen":
            setStartPosition(canvas.transPosition(canvas.initTouchPosition))
        case "touch":
            return
        default:
            return
        }
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        selectedArea.drawSelectedAreaPixels(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            getSelectedPixelsFromGrid()
            setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
            selectedArea.drawSelectedAreaPixels(context)
        case "touch":
            if (canvas.activatedDrawing) {
                getSelectedPixelsFromGrid()
                setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
                selectedArea.drawSelectedAreaPixels(context)
            }
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            endedUsingHandTool()
        default:
            return
        }
    }
    
    func buttonDown() {
        setStartPosition(canvas.transPosition(canvas.initTouchPosition))
        getSelectedPixelsFromGrid()
    }
    
    func buttonUp() {
        endedUsingHandTool()
    }
}
