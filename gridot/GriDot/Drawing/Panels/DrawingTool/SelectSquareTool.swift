//
//  SelectSquareTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/03.
//

import UIKit

class SelectSquareTool: SelectTool {
    var minX: CGFloat = 0
    var maxX: CGFloat = 0
    var minY: CGFloat = 0
    var maxY: CGFloat = 0
    var xLen: CGFloat = 0
    var yLen: CGFloat = 0
    var isDrawing: Bool = false
    
    override init(_ canvas: Canvas) {
        super.init(canvas)
        self.isDrawing = false
    }
    
    func initToolSetting() {
        drawOutlineInterval?.invalidate()
        isTouchedInside = false
        initPositions()
        copyPixelsToGrid()
        selectedPixels = [:]
    }
    
    func initPositions() {
        minX = 0
        maxX = 0
        minY = 0
        maxY = 0
        xLen = 0
        yLen = 0
        accX = 0
        accY = 0
    }
    
    func checkSelectedTool(_ grid: Grid, _ tool: String) {
        if (tool != "SelectSquare") {
            initPositions()
            copyPixelsToGrid()
        }
    }
    
    func isTouchedInsideArea(_ touchPosition: [String: Int]) -> Bool {
        if (xLen == canvasLen && yLen == canvasLen) {
            initPositions()
            return false
        }
        guard let x = touchPosition["x"] else { return false }
        guard let y = touchPosition["y"] else { return false }
        let posX = pixelLen * CGFloat(x)
        let posY = pixelLen * CGFloat(y)
        return (minX + accX <= posX && posX <= maxX + accX
                    && minY + accY <= posY && posY <= maxY + accX)
    }
    
    func setEndPosition(_ touchPosition: [String: Int]) {
        guard let x = touchPosition["x"] else { return }
        guard let y = touchPosition["y"] else { return }
        
        endX = pixelLen * CGFloat(x + 1)
        xLen = endX - startX
        minX = xLen > 0 ? startX : endX
        maxX = xLen > 0 ? endX : startX
        xLen = xLen > 0 ? xLen : xLen * -1
        
        endY = pixelLen * CGFloat(y + 1)
        yLen = endY - startY
        minY = yLen > 0 ? startY : endY
        maxY = yLen > 0 ? endY : startY
        yLen = yLen > 0 ? yLen : yLen * -1
    }
    
    func endMovePosition() {
        minX += accX
        minY += accY
        maxX += accX
        maxY += accY
        moveSelectedAreaPixels()
    }
    
    func getSelectedAreaPixels(_ grid: Grid) {
        selectedPixels = grid.getPixelsInRect(Int(minX / pixelLen), Int(minY / pixelLen),
                                            Int(maxX / pixelLen), Int(maxY / pixelLen))
        for color in selectedPixels {
            for x in color.value {
                for y in x.value {
                    grid.removeLocationIfSelected(hex: color.key, x: x.key, y: y);
                }
            }
        }
    }
    
    func drawSelectedAreaOutline(_ context: CGContext) {
        let accMinX: CGFloat = minX + accX
        let accMinY: CGFloat = minY + accY
        let accMaxX: CGFloat = maxX + accX
        let accMaxY: CGFloat = maxY + accY
        var x: CGFloat = accMinX
        var y: CGFloat = accMinY
        
        while (x < accMaxX) {
            drawHorizontalOutline(context, x, accMinY, outlineToggle)
            drawHorizontalOutline(context, x, accMaxY, outlineToggle)
            x += pixelLen
        }
        
        while (y < accMaxY) {
            drawVerticalOutline(context, accMinX, y, outlineToggle)
            drawVerticalOutline(context, accMaxX, y, outlineToggle)
            y += pixelLen
        }
    }
    
    func setSelectedArea() {
        if (isTouchedInsideArea(canvas.transPosition(canvas.moveTouchPosition))) {
            setStartPosition(canvas.transPosition(canvas.initTouchPosition))
            setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
            if (!isTouchedInside) {
                getSelectedAreaPixels(grid)
            }
            isTouchedInside = true
        } else {
            initPositions()
            copyPixelsToGrid()
            if (isTouchedInside) {
                canvas.timeMachineVM.addTime()
            }
            setStartPosition(canvas.transPosition(canvas.initTouchPosition))
            setEndPosition(canvas.transPosition(canvas.moveTouchPosition))
            isTouchedInside = false
        }
        startDrawOutlineInterval()
        isDrawing = true
    }
}

extension SelectSquareTool {
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
            if (isDrawing) {
                drawSelectedAreaPixels(context)
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
            } else {
                setEndPosition(canvas.transPosition(canvas.moveTouchPosition))
            }
            if (isDrawing) {
                drawSelectedAreaPixels(context)
                drawSelectedAreaOutline(context)
            }
        case "touch":
            if (canvas.activatedDrawing) {
                if (isTouchedInside) {
                    setMovePosition(canvas.transPosition(canvas.moveTouchPosition))
                } else {
                    setEndPosition(canvas.transPosition(canvas.moveTouchPosition))
                }
            }
            if (isDrawing) {
                drawSelectedAreaPixels(context)
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
                endMovePosition()
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
            endMovePosition()
            canvas.timeMachineVM.addTime()
        }
    }
}
