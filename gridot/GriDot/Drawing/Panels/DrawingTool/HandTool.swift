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

    func setStartPosition(_ touchPosition: [String: Int]) {
        startX = (pixelLen * CGFloat(touchPosition["x"]!))
        startY = (pixelLen * CGFloat(touchPosition["y"]!))
    }
    
    func setMovePosition(_ touchPosition: [String: Int]) {
        endX = pixelLen * CGFloat(touchPosition["x"]!)
        endY = pixelLen * CGFloat(touchPosition["y"]!)
        selectedArea.accX = endX - startX
        selectedArea.accY = endY - startY
    }
    
    func getSelectedPixelsFromGrid() {
        if (!isHolded) {
            selectedArea.setSelectedGrid()
            selectedArea.removeSelectedPixels()
            isHolded = true
        }
    }
}

extension HandTool {
    func setUnused() {
        if (isHolded) {
            selectedArea.moveSelectedPixelsToGrid()
            isHolded = false
        }
    }
    
    func touchesBegan(_ pixelPosition: [String: Int]) {
        switch canvas.selectedDrawingMode {
        case "pen":
            if (!isHolded) {
                setStartPosition(canvas.transPosition(canvas.initTouchPosition))
            }
        case "touch":
            return
        default:
            return
        }
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        selectedArea.drawSelectedArea(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            getSelectedPixelsFromGrid()
            setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
            selectedArea.drawSelectedArea(context)
        case "touch":
            if (isHolded) {
                setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
                selectedArea.drawSelectedArea(context)
            }
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            return
        default:
            return
        }
    }
    
    func buttonDown() {
        setStartPosition(canvas.transPosition(canvas.initTouchPosition))
        getSelectedPixelsFromGrid()
    }
    
    func buttonUp() {
        
    }
}
