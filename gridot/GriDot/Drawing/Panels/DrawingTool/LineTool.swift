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
    func addTouchGuideLine(_ context: CGContext, _ targetPos: CGPoint) {
        let xlocation = Double(targetPos.x) * Double(canvas.onePixelLength)
        let ylocation = Double(targetPos.y) * Double(canvas.onePixelLength)
        let rectangle = CGRect(
            x: xlocation, y: ylocation,
            width: Double(canvas.onePixelLength), height: Double(canvas.onePixelLength)
        )
        context.setLineWidth(0.5)
        context.setFillColor(canvas.selectedColor!.cgColor)
        context.setStrokeColor(UIColor.init(named: "Color_gridLine")!.cgColor)
        context.setShadow(offset: CGSize(), blur: 1, color: UIColor.gray.cgColor)
        context.addRect(rectangle)
    }
    
    // start를 기준으로한 사분면
    func getQuadrant(start: CGPoint, end: CGPoint) -> CGPoint {
        let x = (Int(end.x) - Int(start.x)).signum()
        let y = (Int(end.y) - Int(start.y)).signum()
        return CGPoint(x: x, y: y)
    }
    
    func drawDiagonal(_ context: CGContext) {
        getDiagonalPixels { pos in
            addTouchGuideLine(context, pos)
        } completion: {
            context.setStrokeColor(UIColor.init(named: "Color_gridLine")!.cgColor)
            context.drawPath(using: .fillStroke)
            context.setShadow(offset: CGSize(), blur: 0)
        }
    }
    
    func addDiagonal() {
        getDiagonalPixels { pos in
            canvas.addPixel(pos)
        } completion: {
            canvas.setNeedsDisplay()
        }
    }
    
    func getDiagonalPixels(addLine: (_ pos: CGPoint)->(), completion: ()->()) {
        let startPoint = canvas.transPosition(canvas.initTouchPosition)
        let endPoint = canvas.transPosition(canvas.moveTouchPosition)
        let quadrant = getQuadrant(start: startPoint, end: endPoint)
        print("quadrant", quadrant)
        
        if (quadrant.x == 0 && quadrant.y == 0) { return }
        
        // 긴 변을 짧은 변으로 나눈 몫이 하나의 계단이 된다
        let yLength = Int(abs(startPoint.y - endPoint.y) + 1)
        let xLength = Int(abs(startPoint.x - endPoint.x) + 1)
        let stairsLength = max(xLength, yLength) / min(xLength, yLength)
        
        // x, y길이를 비교하여 대각선을 그리는 방향을 설정
        let targetSide = xLength > yLength ? yLength : xLength
        
        // 한 계단의 길이가
        for j in 0..<targetSide {
            for i in 0..<stairsLength {
                let long = CGFloat(i + j * stairsLength)
                let short = CGFloat(j)
                let pixelPos = CGPoint(
                    x: startPoint.x + (quadrant.x * (xLength > yLength ? long : short)),
                    y: startPoint.y + (quadrant.y * (xLength > yLength ? short : long))
                )
                print(pixelPos)
                addLine(pixelPos)
            }
        }
        completion()
    }
}

extension LineTool {
    func touchesBegan(_ pixelPos: CGPoint) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            return
        case "touch":
            if (canvas.activatedDrawing) {
                drawDiagonal(context)
            }
        default:
            return
        }
    }
    
    func touchesMoved(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            drawDiagonal(context)
        case "touch":
            if (canvas.activatedDrawing) {
                drawDiagonal(context)
            }
        default:
            return
        }
    }
    
    func touchesEnded(_ context: CGContext) {
        switch canvas.selectedDrawingMode {
        case "pen":
            addDiagonal()
            canvas.timeMachineVM.addTime()
        case "touch":
            return
        default:
            return
        }
    }
    
    func buttonUp() {
        addDiagonal()
        canvas.timeMachineVM.addTime()
    }
}
