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
    
    func getNewDicAddedAccValue(_ arr: [Int32], _ accX: Int, _ accY: Int) -> [Int32] {
        var newArr: [Int32] = Array(repeating: 0, count: 16)
        
        for y in 0..<16 {
            for x in 0..<16 {
                if (arr[y].getBitStatus(x)) {
                    let newY = y + accY
                    let newX = x + accX
                    
                    if (newX < 0 || newX > 15 || newY < 0 || newY > 15) { continue }
                    newArr[y + accY].setBitOn(x + accX)
                }
            }
        }
        return newArr
    }
}

extension HandTool {
    func setUnused() {
        if (isHolded) {
            selectedArea.moveSelectedPixelsToGrid()
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
            if (selectedArea.selectedPixels.count != 0) {
                let accX = Int(selectedArea.accX / pixelLen)
                let accY = Int(selectedArea.accY / pixelLen)
                
                selectedArea.selectedPixels = getNewDicAddedAccValue(selectedArea.selectedPixels, accX, accY)

                for (hex, dic) in selectedArea.intGrid {
                    selectedArea.intGrid[hex] = getNewDicAddedAccValue(dic, accX, accY)
                }
                selectedArea.accX = 0
                selectedArea.accY = 0
            } else {
                selectedArea.moveSelectedPixelsToGrid()
                isHolded = false
            }
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
        if (selectedArea.selectedPixels.count != 0) {
            let accX = Int(selectedArea.accX / pixelLen)
            let accY = Int(selectedArea.accY / pixelLen)
            
            selectedArea.selectedPixels = getNewDicAddedAccValue(selectedArea.selectedPixels, accX, accY)
            for (hex, dic) in selectedArea.intGrid {
                selectedArea.intGrid[hex] = getNewDicAddedAccValue(dic, accX, accY)
            }
            selectedArea.accX = 0
            selectedArea.accY = 0
        } else {
            selectedArea.moveSelectedPixelsToGrid()
            isHolded = false
        }
        canvas.timeMachineVM.addTime()
    }
}
