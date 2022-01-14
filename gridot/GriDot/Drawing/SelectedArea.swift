//
//  SelectedArea.swift
//  GriDot
//
//  Created by 박찬울 on 2022/01/14.
//

import UIKit

class SelectedArea: NSObject {
    var grid: Grid!
    var canvas: Canvas!
    var onePixelLength: CGFloat!
    var selectedPixels: [Int: [Int]] = [:]
    var selectedPixelGrid: Grid = Grid()
    var accX: CGFloat = 0
    var accY: CGFloat = 0
    var isDrawing: Bool = false
    var outlineToggle: Bool = false
    var drawOutlineInterval: Timer?
    
    init(_ canvas: Canvas) {
        self.grid = canvas.grid
        self.canvas = canvas
        self.onePixelLength = canvas.onePixelLength
    }
    
    // 선택 영역 픽셀을 grid에서 가져오기
    func setSelectedGrid() {
        selectedPixelGrid.initGrid()
        if (selectedPixels.count == 0) {
            selectedPixelGrid.grid = canvas.grid.gridLocations
            canvas.grid.initGrid()
        } else {
            for (x, yArr) in selectedPixels {
                for y in yArr {
                    let hex = grid.findColorSelected(x: x, y: y)
                    selectedPixelGrid.addLocation(hex: hex, x: x, y: y)
                }
            }
        }
    }
    
    // 선택 영역 픽셀을 grid에서 지우기
    func removeSelectedPixels() {
        for (x, yArr) in selectedPixels {
            for y in yArr {
                let hex = grid.findColorSelected(x: x, y: y)
                grid.removeLocationIfSelected(hex: hex, x: x, y: y)
            }
        }
    }
    
    // 선택 영역 픽셀을 grid로 옮기기
    func moveSelectedPixelsToGrid() {
        let widthOfPixel = Double(onePixelLength)
        
        for hex in selectedPixelGrid.grid {
            for x in hex.value {
                for y in x.value {
                    let xPos = Double(x.key) + (Double(accX) / widthOfPixel)
                    let yPos = Double(y) + (Double(accY) / widthOfPixel)
                    grid.addLocation(hex: hex.key, x: Int(xPos), y: Int(yPos))
                }
            }
        }
        selectedPixelGrid.initGrid()
    }
    
    // 선택된 영역에 점선과 픽셀을 그린다.
    func drawSelectedArea(_ context: CGContext) {
        drawSelectedAreaPixels(context)
        drawSelectedAreaOutline(context)
    }
    
    // 선택된 영역의 픽셀을 그린다
    func drawSelectedAreaPixels(_ context: CGContext) {
        context.setStrokeColor(UIColor.init(named: "Color_gridLine")!.cgColor)
        context.setLineWidth(0.5)
        let widthOfPixel = Double(onePixelLength)
        for hex in selectedPixelGrid.gridLocations {
            for x in hex.value {
                for y in x.value {
                    if (hex.key == "none") { continue }
                    guard let uiColor = hex.key.uicolor else { return }
                    
                    context.setFillColor(uiColor.cgColor)
                    let xlocation = (Double(x.key) * widthOfPixel) + Double(accX)
                    let ylocation = (Double(y) * widthOfPixel)  + Double(accY)
                    let rectangle = CGRect(x: xlocation, y: ylocation,
                                           width: widthOfPixel, height: widthOfPixel)
                    context.addRect(rectangle)
                    context.drawPath(using: .fillStroke)
                }
            }
        }
        context.strokePath()
    }
    
    // 점선으로 선택된 영역을 그린다.
    func drawSelectedAreaOutline(_ context: CGContext) {
        for posX in selectedPixels {
            for posY in posX.value {
                let x = (onePixelLength * CGFloat(posX.key)) + CGFloat(accX)
                let y = (onePixelLength * CGFloat(posY)) + CGFloat(accY)
                
                if (!isSelectedPixel(posX.key, posY - 1))
                { drawSelectedAreaOutline(context, isVertical: false, x, y) }
                if (!isSelectedPixel(posX.key, posY + 1))
                { drawSelectedAreaOutline(context, isVertical: false, x, y + onePixelLength) }
                if (!isSelectedPixel(posX.key - 1, posY))
                { drawSelectedAreaOutline(context, isVertical: true, x, y) }
                if (!isSelectedPixel(posX.key + 1, posY))
                { drawSelectedAreaOutline(context, isVertical: true, x + onePixelLength, y) }
            }
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
    
    // 선택 영역 확인
    func isSelectedPixel(_ x: Int, _ y: Int) -> Bool {
        guard let posX = selectedPixels[x] else { return false }
        if (posX.firstIndex(of: y) != nil) { return true }
        return false
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
        canvas.updateViewModelImages(canvas.targetLayerIndex)
        canvas.drawingVC.drawingToolBar.cancelButton.removeFromSuperview()
        canvas.drawingVC.drawingToolBar.drawingToolCVTrailing.constant = 5
        moveSelectedPixelsToGrid()
        isDrawing = false
        selectedPixels = [:]
        selectedPixelGrid.initGrid()
        canvas.timeMachineVM.addTime()
        canvas.setNeedsDisplay()
    }
}
