//
//  DrawingLine.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/20.
//

import UIKit

class DrawingLine {
    var numsOfPixels: Int!
    var onePixelLength: CGFloat!
    var lengthOfOneSide: CGFloat!
    
    init(
        _ numsOfPixels: Int,
        _ onePixelLength: CGFloat,
        _ lengthOfOneSide: CGFloat
    ) {
        self.numsOfPixels = numsOfPixels
        self.onePixelLength = onePixelLength
        self.lengthOfOneSide = lengthOfOneSide
    }
    
    // draw_method
    func drawGridLine(context: CGContext) {
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(0.5)
        
        for i in 1...Int(numsOfPixels - 1) {
            let gridWidth = onePixelLength * CGFloat(i)
            context.move(to: CGPoint(x: gridWidth, y: 0))
            context.addLine(to: CGPoint(x: gridWidth, y: lengthOfOneSide))
            context.move(to: CGPoint(x: 0, y: gridWidth))
            context.addLine(to: CGPoint(x: lengthOfOneSide, y: gridWidth))
        }
        context.strokePath()
    }
    
    func drawTouchGuideLine(_ context: CGContext, _ selectedColor: UIColor, _ initTouchPosition: CGPoint, _ moveTouchPosition: CGPoint) {
        // 터치가 시작된 곳에서 부터 움직인 곳까지 경로를 표시
        context.setStrokeColor(selectedColor.cgColor)
        context.setLineWidth(3)
        
        context.move(to: initTouchPosition)
        context.addLine(to: moveTouchPosition)
        context.strokePath()
        
        context.setFillColor(selectedColor.cgColor)
        context.addArc(center: moveTouchPosition, radius: onePixelLength / 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.fillPath()
    }
    
    func getQuadrant(start: [String: Int], end: [String: Int]) -> [String: Int]{
        // start를 기준으로한 사분면
        let x = (end["x"]! - start["x"]!).signum()
        let y = (end["y"]! - start["y"]!).signum()
        return ["x": x, "y": y]
    }
    
    func addDiagonalPixels(_ context: CGContext, _ grid: Grid, _ initTouchPosition: CGPoint, _ moveTouchPosition: CGPoint, _ selectedColor: UIColor) {
        let startPoint = transPosition(initTouchPosition, onePixelLength)
        let endPoint = transPosition(moveTouchPosition, onePixelLength)
        let quadrant = getQuadrant(start: startPoint, end: endPoint)
        
        print("--> start: ", startPoint)
        print("--> end: ", endPoint)
        
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
                grid.addLocation(hex: selectedColor.hexa!, x: targetPos["x"]!, y: targetPos["y"]!)
            }
        }
        context.strokePath()
    }
}
