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
    var isTouchesEnded: Bool!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.isBegin = false
        self.isTouchesEnded = false
    }
    
    // guideLine_method
    func addTouchGuideLine(_ context: CGContext, _ targetPos: [String: Int], _ isGuideLine: Bool) {
        if (isGuideLine) {
            context.setShadow(offset: CGSize(width: 2, height: 2), blur: 10)
        } else {
            context.setShadow(offset: CGSize(), blur: 0)
        }
        context.setLineWidth(0.5)
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setFillColor(canvas.selectedColor!.cgColor)
        let xlocation = Double(targetPos["x"]!) * Double(canvas.onePixelLength)
        let ylocation = Double(targetPos["y"]!) * Double(canvas.onePixelLength)
        let rectangle = CGRect(x: xlocation, y: ylocation, width: Double(canvas.onePixelLength), height: Double(canvas.onePixelLength))
        context.addRect(rectangle)
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
                if (isGuideLine) {
                    addTouchGuideLine(context, targetPos, isGuideLine)
                } else {
                    canvas.grid.addLocation(hex: canvas.selectedColor.hexa!, x: targetPos["x"]!, y: targetPos["y"]!)
                    if (canvas.selectedDrawingMode == "touch") {
                        addTouchGuideLine(context, targetPos, isGuideLine)
                    }
                }
            }
        }
        context.drawPath(using: .fillStroke)
        context.strokePath()
        context.setShadow(offset: CGSize(), blur: 0)
    }
}

extension LineTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            return
        case "touch":
            if (canvas.activatedDrawing) {
                addDiagonalPixels(context, isGuideLine: true)
            } else if (isTouchesEnded) {
                addDiagonalPixels(context, isGuideLine: false)
                canvas.timeMachineVM.addTime()
                isTouchesEnded = false
            }
        default:
            return
        }
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            addDiagonalPixels(context, isGuideLine: true)
        case "touch":
            if (canvas.activatedDrawing) {
                addDiagonalPixels(context, isGuideLine: true)
            } else if (isTouchesEnded) {
                addDiagonalPixels(context, isGuideLine: false)
                canvas.timeMachineVM.addTime()
                isTouchesEnded = false
            }
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            addDiagonalPixels(context, isGuideLine: false)
            canvas.timeMachineVM.addTime()
        case "touch":
            if (canvas.activatedDrawing == false && isTouchesEnded) {
                addDiagonalPixels(context, isGuideLine: false)
                canvas.timeMachineVM.addTime()
                isTouchesEnded = false
            }
        default:
            return
        }
    }
    
    func buttonUp() {
        isTouchesEnded = true
    }
}
