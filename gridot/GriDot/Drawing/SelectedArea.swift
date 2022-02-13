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
    var isDrawing: Bool = false
    var outlineToggle: Bool = false
    var drawOutlineInterval: Timer?
    var acc: CGPoint = CGPoint(x: 0, y: 0)
    var pos: CGPoint = CGPoint(x: 0, y: 0)
    var selectedPixels: [Int32] = Array(repeating: 0, count: 16)
    // selectedPixels는 선택된 범위에 점선을 그리기 위한 위치를 가지고 있다.
    // self.intGrid는 화면에 픽셀을 그리기 위한 색상과 위치를 가지고 있다.
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.onePixelLength = canvas.onePixelLength
    }
    
    func initSelectedAreaToStart() {
        startDrawOutlineInterval()
        isDrawing = true
        selectedPixels = Array(repeating: 0, count: 16)
        acc = CGPoint(x: 0, y: 0)
        pos = CGPoint(x: 0, y: 0)
    }
    
    func isSelectedPixelEmpty() -> Bool {
        for i in selectedPixels {
            if (i != 0) { return false }
        }
        return true
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
        if (x < 0 || x > 15 || y < 0 || y > 15) { return false }
        return selectedPixels[y].getBitStatus(x)
    }
    
    // 선택 영역 map
    func mapSelectedPixelArr(_ callback: (_ x: Int, _ y: Int) -> ()) {
        for y in 0..<16 {
            if (selectedPixels[y] == 0) { continue }
            for x in 0..<16 {
                if (selectedPixels[y].getBitStatus(x)) {
                    callback(x, y)
                }
            }
        }
    }
    
    // 선택 영역 픽셀을 grid에서 가져오기
    func setSelectedGrid() {
        if (isSelectedPixelEmpty()) {
            initGrid()
            intGrid = canvas.grid.intGrid
            canvas.grid.initGrid()
        } else if (intGrid.count == 0) {
            mapSelectedPixelArr { (x, y) in
                let pos = CGPoint(x: x, y: y)
                let hex = canvas.grid.findColorSelected(pos)
                addLocation(hex, pos)
                canvas.grid.removeLocationIfSelected(hex, pos)
            }
        }
    }
    
    // 선택 영역 픽셀을 grid에서 지우기
    func removeSelectedPixels() {
        mapSelectedPixelArr { (x, y) in
            let pos = CGPoint(x: x, y: y)
            let hex = canvas.grid.findColorSelected(pos)
            canvas.grid.removeLocationIfSelected(hex, pos)
        }
    }
    
    // 선택 영역 픽셀을 grid로 옮기기
    func moveSelectedPixelsToGrid() {
        mapIntGridDic { hex, pos in
            canvas.grid.addLocation(hex, pos)
        }
        acc = CGPoint(x: 0, y: 0)
        pos = CGPoint(x: 0, y: 0)
        initGrid()
    }
    
    // 선택 영역 추가
    func addSelectedPixel(_ pos: CGPoint) {
        let x = Int(pos.x)
        let y = Int(pos.y)
        if (x < 0 || x > 15 || y < 0 || y > 15) { return }
        selectedPixels[y].setBitOn(x)
    }
    
    func setSelectedPixelWithIntGrid() {
        selectedPixels = Array(repeating: 0, count: 16)
        mapIntGridDic { hex, pos in
            selectedPixels[Int(pos.y)].setBitOn(Int(pos.x))
        }
    }
    
    // grid map
    func mapIntGridDic(_ callback: (_ hex: String, _ pos: CGPoint) -> ()) {
        let widthOfPixel = Double(onePixelLength)
        var newPos = CGPoint(x: 0, y: 0)
        let addedX = (Double(acc.x + pos.x) / widthOfPixel)
        let addedY = (Double(acc.y + pos.y) / widthOfPixel)
        
        for (hex, posArr) in intGrid {
            for y in 0..<16 {
                if (posArr[y] == 0) { continue }
                for x in 0..<16 {
                    if (posArr[y].getBitStatus(x)) {
                        newPos.x = Double(x) + addedX
                        newPos.y = Double(y) + addedY
                        if (newPos.x < 0 || newPos.x > 15
                            || newPos.y < 0 || newPos.y > 15)
                        { continue }
                        callback(hex, newPos)
                    }
                }
            }
        }
    }
    
    // 선택된 영역의 픽셀을 그린다
    func drawSelectedAreaPixels(_ context: CGContext) {
        context.setLineWidth(0.2)

        mapIntGridDic { hex, pos in
            guard let uiColor = hex.uicolor else { return }
            let x = pos.x * onePixelLength
            let y = pos.y * onePixelLength
            let rectangle = CGRect(x: x, y: y, width: onePixelLength, height: onePixelLength)
            
            context.setFillColor(uiColor.cgColor)
            context.setStrokeColor(uiColor.cgColor)
            context.addRect(rectangle)
            context.drawPath(using: .fillStroke)
        }
        context.strokePath()
    }
    
    // 점선으로 선택된 영역을 그린다.
    func drawSelectedAreaOutline(_ context: CGContext) {
        mapSelectedPixelArr { posX, posY in
            let x = (onePixelLength * CGFloat(posX)) + CGFloat(acc.x + pos.x)
            let y = (onePixelLength * CGFloat(posY)) + CGFloat(acc.y + pos.y)
            
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
        
        drawLineWithColorAndDirection(context, outlineToggle, isVertical,
            CGPoint(x: x, y: y))
        drawLineWithColorAndDirection(context, !outlineToggle, isVertical,
            CGPoint(x: x + (isVertical ? 0 : term), y: y + (isVertical ? term : 0)))
        drawLineWithColorAndDirection(context, !outlineToggle, isVertical,
            CGPoint(x: x + (isVertical ? 0 : term * 2), y: y + (isVertical ? term * 2 : 0)))
        drawLineWithColorAndDirection(context, outlineToggle, isVertical,
            CGPoint(x: x + (isVertical ? 0 : term * 3), y: y + (isVertical ? term * 3 : 0)))
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
        canvas.updateLayerImage(canvas.targetLayerIndex)
        canvas.drawingVC.drawingToolBar.cancelButton.removeFromSuperview()
        canvas.drawingVC.drawingToolBar.drawingToolCVTrailing.constant = 5
        moveSelectedPixelsToGrid()
        pos = CGPoint(x: 0, y: 0)
        isDrawing = false
        selectedPixels = Array(repeating: 0, count: 16)
        canvas.timeMachineVM.addTime()
        canvas.setNeedsDisplay()
    }
}
