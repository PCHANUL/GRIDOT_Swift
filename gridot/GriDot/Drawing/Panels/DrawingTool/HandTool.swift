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
    var pixelLen: CGFloat!
    
    var startX: CGFloat = 0
    var startY: CGFloat = 0
    var endX: CGFloat = 0
    var endY: CGFloat = 0
    
    var isHolded: Bool = false
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.pixelLen = canvas.onePixelLength
    }

    func setStartPosition(_ touchPosition: [String: Int]) {
        startX = (pixelLen * CGFloat(touchPosition["x"]!))
        startY = (pixelLen * CGFloat(touchPosition["y"]!))
    }
    
    func setMovePosition(_ touchPosition: [String: Int]) {
        endX = pixelLen * CGFloat(touchPosition["x"]!)
        endY = pixelLen * CGFloat(touchPosition["y"]!)
        canvas.accX = endX - startX
        canvas.accY = endY - startY
    }
    
    func getSelectedPixelsFromGrid() {
        if (!isHolded) {
            if (canvas.selectedPixels.count == 0) {
                pixels = canvas.grid.gridLocations
                canvas.selectedPixelGrid.grid = pixels
                canvas.grid.initGrid()
            } else {
                pixels = canvas.selectedPixelGrid.gridLocations
                canvas.removeSelectedPixels()
            }
            isHolded = true
        }
    }
    
    func setSelectedPixelsToGrid() {
        let widthOfPixel = Double(pixelLen)
        
        for hex in pixels {
            for x in hex.value {
                for y in x.value {
                    let xPos = Double(x.key) + (Double(canvas.accX) / widthOfPixel)
                    let yPos = Double(y) + (Double(canvas.accY) / widthOfPixel)
                    canvas.grid.addLocation(hex: hex.key, x: Int(xPos), y: Int(yPos))
                }
            }
        }
        pixels = [:]
    }
}

extension HandTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
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
        canvas.drawSelectedAreaPixels(context)
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            getSelectedPixelsFromGrid()
            setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
            canvas.drawSelectedAreaPixels(context)
        case "touch":
            if (isHolded) {
                setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
                canvas.drawSelectedAreaPixels(context)
            }
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            isHolded = false
            setSelectedPixelsToGrid()
            canvas.timeMachineVM.addTime()
        default:
            return
        }
    }
    
    func buttonDown() {
        setStartPosition(canvas.transPosition(canvas.initTouchPosition))
        getSelectedPixelsFromGrid()
    }
    
    func buttonUp() {
        isHolded = false
        setSelectedPixelsToGrid()
        canvas.accX = 0
        canvas.accY = 0
        startX = 0
        startY = 0
        endX = 0
        endY = 0
        canvas.timeMachineVM.addTime()
    }
}
