//
//  SelectedArea.swift
//  GriDot
//
//  Created by 박찬울 on 2022/01/14.
//

import UIKit

class SelectedArea: Grid {
    var canvas: Canvas!
    var onePixelLength: CGFloat!
    var selectedPixels: [Int32] = Array(repeating: 0, count: 16)
    var accX: CGFloat = 0
    var accY: CGFloat = 0
    var isDrawing: Bool = false
    var outlineToggle: Bool = false
    var drawOutlineInterval: Timer?
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.onePixelLength = canvas.onePixelLength
    }
    
    func initSelectedAreaToStart() {
        startDrawOutlineInterval()
        isDrawing = true
        selectedPixels = Array(repeating: 0, count: 16)
        accX = 0
        accY = 0
    }

    // tool을 위한 선택 영역 확인
    func checkPixelForDrawingTool(_ pos: CGPoint) -> Bool {
        if (isDrawing == false) { return true }
        return selectedPixelArrContains(pos)
    }
    
    // 선택 영역 확인
    func selectedPixelArrContains(_ pos: CGPoint) -> Bool {
        let x = Int(pos.x)
        let y = Int(pos.y)
        return selectedPixels[y].getBitStatus(x)
    }
    
    // 선택 영역 map
    func selectedPixelArrMap(_ callback: (_ x: Int, _ y: Int)->()) {
        for y in 0..<16 {
            if (selectedPixels[y] == 0) { continue }
            for x in 0..<16 {
                if (selectedPixels[y].getBitStatus(x)) {
                    callback(x, y)
                }
            }
        }
    }
    
    // 선택 영역 추가
    func addSelectedPixel(_ pos: CGPoint) {
        let x = Int(pos.x)
        let y = Int(pos.y)
        selectedPixels[y].setBitOn(x)
    }
    
    // 선택 영역 픽셀을 grid에서 가져오기
    func setSelectedGrid() {
        initGrid()
        if (selectedPixels.count == 0) {
            intGrid = canvas.grid.intGrid
            canvas.grid.initGrid()
        } else {
            selectedPixelArrMap { (x, y) in
                let pos = CGPoint(x: x, y: y)
                let hex = canvas.grid.findColorSelected(pos)
                addLocation(hex, pos)
            }
        }
    }
    
    // 선택 영역 픽셀을 grid에서 지우기
    func removeSelectedPixels() {
        selectedPixelArrMap { (x, y) in
            let pos = CGPoint(x: x, y: y)
            let hex = canvas.grid.findColorSelected(pos)
            canvas.grid.removeLocationIfSelected(hex, pos)
        }
    }
    
    // 선택 영역 픽셀을 grid로 옮기기
    func moveSelectedPixelsToGrid() {
        let widthOfPixel = Double(onePixelLength)
        
        for (hex, posArr) in intGrid {
            for y in 0..<16 {
                if (posArr[y] == 0) { continue }
                for x in 0..<16 {
                    if (posArr[y].getBitStatus(x)) {
                        let pos = CGPoint(
                            x: Double(x) + (Double(accX) / widthOfPixel),
                            y: Double(y) + (Double(accY) / widthOfPixel)
                        )
                        canvas.grid.addLocation(hex, pos)
                    }
                }
            }
        }
    }
    
    // 선택된 영역의 픽셀을 그린다
    func drawSelectedAreaPixels(_ context: CGContext) {
        context.setStrokeColor(UIColor.init(named: "Color_gridLine")!.cgColor)
        context.setLineWidth(0.5)
        let widthOfPixel = Double(onePixelLength)

        for (hex, posArr) in intGrid {
            for y in 0..<16 {
                if (posArr[y] == 0) { continue }
                for x in 0..<16 {
                    if (posArr[y].getBitStatus(x)) {
                        guard let uiColor = hex.uicolor else { return }
                        let xPos = (Double(x) * widthOfPixel) + Double(accX)
                        let yPos = (Double(y) * widthOfPixel) + Double(accY)
                        let rectangle = CGRect(x: xPos, y: yPos, width: widthOfPixel, height: widthOfPixel)
                        context.setFillColor(uiColor.cgColor)
                        context.addRect(rectangle)
                        context.drawPath(using: .fillStroke)
                    }
                }
            }
        }
        context.strokePath()
    }
    
    // 점선으로 선택된 영역을 그린다.
    func drawSelectedAreaOutline(_ context: CGContext) {
        selectedPixelArrMap { posX, posY in
            let x = (onePixelLength * CGFloat(posX)) + CGFloat(accX)
            let y = (onePixelLength * CGFloat(posY)) + CGFloat(accY)
            
            if (!selectedPixelArrContains(CGPoint(x: posX, y: posY - 1)))
            { drawSelectedAreaOutline(context, isVertical: false, x, y) }
            if (!selectedPixelArrContains(CGPoint(x: posX, y: posY + 1)))
            { drawSelectedAreaOutline(context, isVertical: false, x, y + onePixelLength) }
            if (!selectedPixelArrContains(CGPoint(x: posX - 1, y: posY)))
            { drawSelectedAreaOutline(context, isVertical: true, x, y) }
            if (!selectedPixelArrContains(CGPoint(x: posX + 1, y: posY)))
            { drawSelectedAreaOutline(context, isVertical: true, x + onePixelLength, y) }
        }
    }
    
    func drawSelectedAreaOutline(_ context: CGContext, isVertical: Bool, _ x: CGFloat, _ y: CGFloat) {
        let term = onePixelLength / 4
        context.setLineWidth(1.5)
        
        drawLineWithColorAndDirection(context, outlineToggle, isVertical, CGPoint(x: x, y: y))
        drawLineWithColorAndDirection(context, !outlineToggle, isVertical, CGPoint(x: x + (isVertical ? 0 : term), y: y + (isVertical ? term : 0)))
        drawLineWithColorAndDirection(context, !outlineToggle, isVertical, CGPoint(x: x + (isVertical ? 0 : term * 2), y: y + (isVertical ? term * 2 : 0)))
        drawLineWithColorAndDirection(context, outlineToggle, isVertical, CGPoint(x: x + (isVertical ? 0 : term * 3), y: y + (isVertical ? term * 3 : 0)))
    }
    
    func drawLineWithColorAndDirection(_ context: CGContext, _ isWhite: Bool, _ isVertical: Bool, _ start: CGPoint) {
        let color = isWhite ? UIColor.white : UIColor.gray
        let len = onePixelLength / 4
        let x = start.x + (isVertical ? 0 : len)
        let y = start.y + (isVertical ? len : 0)
        
        context.setStrokeColor(color.cgColor)
        context.move(to: start)
        context.addLine(to: CGPoint(x: x, y: y))
        context.strokePath()
    }
    
    // 선택 영역 외곽선을 위한 인터벌
    func startDrawOutlineInterval() {
        if (!(drawOutlineInterval?.isValid ?? false)) {
            canvas.drawingVC.drawingToolBar.addSelectToolControlButtton { [self] in
                stopDrawOutlineInterval()
            }
            drawOutlineInterval = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true)
            { [self] (Timer) in
                canvas.setNeedsDisplay()
                outlineToggle = !outlineToggle
            }
        }
    }
    
    func stopDrawOutlineInterval() {
        drawOutlineInterval?.invalidate()
        canvas.updateViewModelImageIntData(canvas.targetLayerIndex)
        canvas.drawingVC.drawingToolBar.cancelButton.removeFromSuperview()
        canvas.drawingVC.drawingToolBar.drawingToolCVTrailing.constant = 5
        moveSelectedPixelsToGrid()
        isDrawing = false
        selectedPixels = Array(repeating: 0, count: 16)
        initGrid()
        canvas.timeMachineVM.addTime()
        canvas.setNeedsDisplay()
    }
}
