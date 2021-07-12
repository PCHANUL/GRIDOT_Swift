//
//  DrawingLine.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

class LineTool {
    var canvas: Canvas!
    var grid: Grid!
    var drawGuidePointInterval: Timer?
    var pixelSize: CGFloat?
    var isBegin: Bool!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.isBegin = false
    }
    
    // guideLine_method
    func addTouchGuideLine(_ context: CGContext, _ targetPos: [String: Int]) {
        context.setShadow(offset: CGSize(width: 2, height: 2), blur: 10)
        context.setFillColor(canvas.selectedColor!.cgColor)
        let xlocation = Double(targetPos["x"]!) * Double(canvas.onePixelLength)
        let ylocation = Double(targetPos["y"]!) * Double(canvas.onePixelLength)
        let rectangle = CGRect(x: xlocation, y: ylocation, width: Double(canvas.onePixelLength), height: Double(canvas.onePixelLength))
        context.addRect(rectangle)
    }
    
    func drawTouchGuideLine(_ context: CGContext) {
        context.drawPath(using: .fillStroke)
        context.setShadow(offset: CGSize(), blur: 0)
    }
    
    func drawTouchGuidePoint(_ context: CGContext) {
        let x = canvas.initTouchPosition.x - (canvas.onePixelLength / 2) - pixelSize!
        let y = canvas.initTouchPosition.y - (canvas.onePixelLength / 2) - pixelSize!
        
        context.setLineWidth(2)
        context.setStrokeColor(UIColor.white.cgColor)
        context.addRect(CGRect(x: x, y: y, width: canvas.onePixelLength + (pixelSize! * 2), height: canvas.onePixelLength + (pixelSize! * 2)))
        context.strokePath()
    }
    
    func startDrawGuidePointInterval() {
        if (!(drawGuidePointInterval?.isValid ?? false)) {
            pixelSize = 30
            drawGuidePointInterval = Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true)
            { (Timer) in
                if (self.pixelSize == 0) {
                    Timer.invalidate()
                    self.isBegin = false
                    return
                }
                self.canvas.setNeedsDisplay()
                self.pixelSize! -= 1
            }
        }
    }
    
    func getQuadrant(start: [String: Int], end: [String: Int]) -> [String: Int]{
        // start를 기준으로한 사분면
        let x = (end["x"]! - start["x"]!).signum()
        let y = (end["y"]! - start["y"]!).signum()
        return ["x": x, "y": y]
    }
    
    func addDiagonalPixels(_ context: CGContext, isGuideLine: Bool) {
        let startPoint = canvas.transPosition(canvas.initTouchPosition)
        let endPoint = canvas.transPosition(canvas.moveTouchPosition)
        let quadrant = getQuadrant(start: startPoint, end: endPoint)
        
        if (isGuideLine == false && quadrant["x"] == 0 && quadrant["y"] == 0) { return }
        
        // 긴 변을 짧은 변으로 나눈 몫이 하나의 계단이 된다
        let yLength = abs(startPoint["y"]! - endPoint["y"]!) + 1
        let xLength = abs(startPoint["x"]! - endPoint["x"]!) + 1
        let stairsLength = max(xLength, yLength) / min(xLength, yLength)
        
        // x, y길이를 비교하여 대각선을 그리는 방향을 설정
        let targetSide = xLength > yLength ? yLength : xLength
        let posArray = xLength > yLength ? ["x", "y"] : ["y", "x"]
        
        // 한 계단의 길이가
        for j in 0..<targetSide {
            for i in 0..<stairsLength {
                let targetPos = [
                    posArray[0]: startPoint[posArray[0]]! + (i + j * stairsLength) * quadrant[posArray[0]]!,
                    posArray[1]: startPoint[posArray[1]]! + (j) * quadrant[posArray[1]]!
                ]
                if isGuideLine {
                    addTouchGuideLine(context, targetPos)
                } else {
                    canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: targetPos["x"]!, y: targetPos["y"]!)
                }
            }
        }
        if isGuideLine {
            drawTouchGuideLine(context)
        } else {
            canvas.timeMachineVM.addTime()
        }
    }
}

extension LineTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
        isBegin = true
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        if (isBegin) {
            startDrawGuidePointInterval()
            drawTouchGuidePoint(context)
        }
    }
    
    func touchesMoved(_ context: CGContext) {
        addDiagonalPixels(context, isGuideLine: true)
    }
    
    func touchesEnded(_ context: CGContext) {
        addDiagonalPixels(context, isGuideLine: false)
    }
}
