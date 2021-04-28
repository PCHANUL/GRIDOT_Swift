//
//  PickerTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/28.
//

import UIKit

class PickerTool {
    var canvas: Canvas!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
    }
    
    func drawPicker(_ context: CGContext) {
        let pixelSize = canvas.onePixelLength! * 1.5
        let posX = canvas.moveTouchPosition.x
        let posY = canvas.moveTouchPosition.y
        let posGrid = canvas.transPosition(canvas.moveTouchPosition)
        var curColor = canvas.grid.findColorSelected(x: posGrid["x"]!, y: posGrid["y"]!)
        curColor = curColor == "none" ? "#555555" : curColor
        
        var rectangle: CGRect!
        var rectPosX: CGFloat = posX - (20 + pixelSize / 2) - (canvas.onePixelLength * 3)
        var rectPosY: CGFloat = posY - (20 + pixelSize / 2) - (canvas.onePixelLength * 3)
        var countX = 0
        var countY = 0
        
        while countY < 5 {
            while countX < 5 {
                context.setFillColor(UIColor.lightGray.cgColor)
                rectangle = CGRect(x: rectPosX, y: rectPosY, width: pixelSize, height: pixelSize)
                context.addRect(rectangle)
                context.drawPath(using: .fillStroke)
                rectPosX += pixelSize
                countX += 1
            }
            countX = 0
            countY += 1
            rectPosX = posX - (20 + pixelSize / 2) - (canvas.onePixelLength * 3)
            rectPosY += pixelSize
        }
        
        context.setLineWidth(canvas.onePixelLength / 5)
        context.setFillColor(curColor.uicolor!.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        rectangle = CGRect(x: posX - (20 + pixelSize / 2), y: posY - 20 - pixelSize / 2, width: pixelSize, height: pixelSize)
        context.addRect(rectangle)
        context.drawPath(using: .fillStroke)

        // draw colored outline
        context.setStrokeColor(curColor.uicolor!.cgColor)
        context.setLineWidth(canvas.onePixelLength / 2)
        context.addArc(
            center: CGPoint(x: posX - 20, y: posY - 20),
            radius: canvas.onePixelLength * 3,
            startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true
        )
        context.strokePath()
        
        // draw outline
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(canvas.onePixelLength / 5)
        context.addArc(
            center: CGPoint(x: posX - 20, y: posY - 20),
            radius: canvas.onePixelLength * 2.7,
            startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true
        )
        context.strokePath()
    }
}

// [] 격자 모양으로 된 picker 그리기
// [] 가운데와 가장자리는 현재 위치의 색
// [] 현재 위치 주변의 색과 좌표를 가져오는 함수
// [] 가져온 좌표를 현재 위치를 기준으로 색칠

// 터치를 시작하면 picker가 화면에 그려진다.
// picker는 캔버스를 확대하여 보여준다.
// 기본 picker를 참고하여 비슷하게
// 현재 위치로 주변 픽셀들의 색을 구하고

// 터치가 끝나면 해당 위치의 색을 가져온다.
// 위치를 가지고 grid에서 색을 가져온다.
// 만약에 selected가 false라면 기본 색을 가져온다.


