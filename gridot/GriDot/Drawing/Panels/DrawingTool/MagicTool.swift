//
//  MagicTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/20.
//

import UIKit

class MagicTool: SelectTool {
    var sameColorPixels: [Int: [Int]] = [:]
    var selectedHex: String!
    var isDrawing: Bool!
    
    override init(_ canvas: Canvas) {
        super.init(canvas)
        self.isDrawing = false
    }
    
    func initToolSetting() {
        drawOutlineInterval?.invalidate()
        isTouchedInside = false
        copyPixelsToGrid()
        accX = 0
        accY = 0
        selectedPixels = [:]
    }
    
    func drawSelectedAreaOutline(_ context: CGContext) {
        guard let positions = selectedPixels[selectedHex] else { return }
        let addX = Int(accX / pixelLen)
        let addY = Int(accY / pixelLen)
        for posX in positions {
            for posY in posX.value {
                let x = (pixelLen * CGFloat(posX.key)) + CGFloat(accX)
                let y = (pixelLen * CGFloat(posY)) + CGFloat(accY)
                if (!isSelectedPixel(posX.key + addX, posY + addY - 1)) { drawHorizontalOutline(context, x, y, outlineToggle) }
                if (!isSelectedPixel(posX.key + addX, posY + addY + 1)) { drawHorizontalOutline(context, x, y + pixelLen, outlineToggle) }
                if (!isSelectedPixel(posX.key + addX - 1, posY + addY)) { drawVerticalOutline(context, x, y, outlineToggle) }
                if (!isSelectedPixel(posX.key + addX + 1, posY + addY)) { drawVerticalOutline(context, x + pixelLen, y, outlineToggle) }
            }
        }
    }
    
    func getSelectedPixel() {
        let pos = canvas.transPosition(canvas.initTouchPosition)
        guard let x = pos["x"] else { return }
        guard let y = pos["y"] else { return }
        let hex = grid.findColorSelected(x: x, y: y)
        if (isSelectedPixel(x, y) == false) {
            selectedHex = hex
            sameColorPixels = grid.getLocations(hex: hex)
            selectedPixels = [:]
            findSameColorPixels(hex, x, y)
        }
    }
    
    func findSameColorPixels(_ hex: String, _ x: Int, _ y: Int) {
        addSelectedPixel(hex, x, y)
        removePixelInArray(hex, x, y)
        if (isSameColor(x + 1, y)) { findSameColorPixels(hex, x + 1, y) }
        if (isSameColor(x - 1, y)) { findSameColorPixels(hex, x - 1, y) }
        if (isSameColor(x, y + 1)) { findSameColorPixels(hex, x, y + 1) }
        if (isSameColor(x, y - 1)) { findSameColorPixels(hex, x, y - 1) }
    }
    
    func removePixelInArray(_ hex: String, _ x: Int, _ y: Int) {
        guard let pos = sameColorPixels[x] else { return }
        guard let index = pos.firstIndex(of: y) else { return }
        sameColorPixels[x]?.remove(at: index)
    }
    
    func isSameColor(_ x: Int, _ y: Int) -> Bool {
        guard let posX = sameColorPixels[x] else { return false }
        return posX.firstIndex(of: y) != nil
    }
    
    func isTouchedInsideArea(_ position: [String: Int]) -> Bool {
        guard let x = position["x"] else { return false }
        guard let y = position["y"] else { return false }
        return isSelectedPixel(x, y)
    }
    
    func removeSelectedAreaPixels() {
        for color in selectedPixels {
            for x in color.value {
                for y in x.value {
                    grid.removeLocationIfSelected(hex: color.key, x: x.key, y: y);
                }
            }
        }
    }
    
    func setSelectedArea() {
        if (isTouchedInsideArea(canvas.transPosition(canvas.initTouchPosition))) {
            if (!isTouchedInside) {
                removeSelectedAreaPixels()
            }
            isTouchedInside = true
            setStartPosition(canvas.transPosition(canvas.moveTouchPosition))
            setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
        } else {
            if (isTouchedInside) {
                copyPixelsToGrid()
                canvas.timeMachineVM.addTime()
                accX = 0
                accY = 0
            }
            getSelectedPixel()
            isTouchedInside = false
        }
        startDrawOutlineInterval()
        isDrawing = true
    }
}

extension MagicTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
        switch canvas.selectedDrawingMode {
        case "pen":
            setSelectedArea()
        case "touch":
            return
        default:
            return
        }
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            if (isDrawing) {
                drawSelectedAreaPixels(context)
                drawSelectedAreaOutline(context)
            }
        case "touch":
            drawSelectedAreaPixels(context)
            if (isDrawing) {
                drawSelectedAreaOutline(context)
            }
        default:
            return
        }
        
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            if (isTouchedInside) {
                setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
                isDrawing = false
            }
            drawSelectedAreaPixels(context)
            if (isDrawing) {
                drawSelectedAreaOutline(context)
            }
        case "touch":
            if (canvas.activatedDrawing) {
                if (isTouchedInside) {
                    setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
                    isDrawing = false
                }
            }
            drawSelectedAreaPixels(context)
            if (isDrawing) {
                drawSelectedAreaOutline(context)
            }
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            if (isTouchedInside) {
                moveSelectedAreaPixels()
                isDrawing = true
            }
        case "touch":
            drawSelectedAreaPixels(context)
            if (isDrawing) {
                drawSelectedAreaOutline(context)
            }
        default:
            return
        }
    }
    
    func buttonDown() {
        canvas.initTouchPosition = canvas.moveTouchPosition
        setSelectedArea()
    }
    
    func buttonUp() {
        if (isTouchedInside) {
            moveSelectedAreaPixels()
            isDrawing = true
        }
    }
}

