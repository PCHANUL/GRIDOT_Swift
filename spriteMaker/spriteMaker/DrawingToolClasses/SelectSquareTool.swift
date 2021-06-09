//
//  SelectSquareTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/03.
//

import UIKit

class SelectSquareTool {
    var canvas: Canvas!
    var isDrawing: Bool!
    var startPosition: [String: Int]!
    var endPosition: [String: Int]!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        isDrawing = false
    }
    
    func setStartPosition(_ touchPosition: [String: Int]) {
        startPosition = touchPosition
        toggleVisibleSelectedArea()
    }
    
    func setEndPosition(_ touchPosition: [String: Int]) {
        endPosition = touchPosition
    }
    
    func toggleVisibleSelectedArea() {
        isDrawing = true
    }
    
    func drawSelectedArea(_ context: CGContext) {
        if !isDrawing { return }
        guard let pixelLen = canvas.onePixelLength else { return }
        
        let lineWidth: CGFloat = 1
        
        let oneSide: CGFloat = 200
        let term: CGFloat = (oneSide / 30)
        
        let startPositionX = pixelLen * CGFloat(startPosition["x"]!)
        let startPositionY = pixelLen * CGFloat(startPosition["y"]!)
        let endPositionX = pixelLen * CGFloat(endPosition["x"]! + 1)
        let endPositionY = pixelLen * CGFloat(endPosition["y"]! + 1)
        
        let horizontalLen = endPositionX - startPositionX
        let verticalLen = endPositionY - startPositionY
        
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.white.cgColor)
        
        var pos: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var flag: CGFloat
        var margin: CGFloat
        
        // 가로
        flag = horizontalLen > 0 ? 1 : -1
        margin = horizontalLen > 0 ? 0 : 12
        while ((pos + (term * 2)) * flag < horizontalLen * flag - (margin * 2)) {
            x = startPositionX - (lineWidth / 2) + pos - margin
            context.move(to: CGPoint(x: x, y: startPositionY))
            context.addLine(to: CGPoint(x: x + term, y: startPositionY))
            pos += term * flag
            context.move(to: CGPoint(x: x, y: startPositionY + verticalLen))
            context.addLine(to: CGPoint(x: x + term, y: startPositionY + verticalLen))
            pos += term * flag
        }
        
        // 세로
        pos = 0
        flag = verticalLen > 0 ? 1 : -1
        margin = verticalLen > 0 ? 0 : 12
        while ((pos + (term * 2)) * flag < verticalLen * flag - (margin * 2)) {
            y = startPositionY - (lineWidth / 2) + pos - margin
            context.move(to: CGPoint(x: startPositionX + horizontalLen, y: y))
            context.addLine(to: CGPoint(x: startPositionX + horizontalLen, y: y + term))
            pos += term * flag
            context.move(to: CGPoint(x: startPositionX, y: y))
            context.addLine(to: CGPoint(x: startPositionX, y: y + term))
            pos += term * flag
        }
        
        context.move(to: CGPoint(x: startPositionX + term, y: startPositionY))
        context.addLine(to: CGPoint(x: startPositionX, y: startPositionY))
        context.addLine(to: CGPoint(x: startPositionX, y: startPositionY + term))
        
        context.move(to: CGPoint(x: startPositionX + horizontalLen - term, y: startPositionY))
        context.addLine(to: CGPoint(x: startPositionX + horizontalLen, y: startPositionY))
        context.addLine(to: CGPoint(x: startPositionX + horizontalLen, y: startPositionY + term))
        
        context.move(to: CGPoint(x: startPositionX + term, y: startPositionY + verticalLen))
        context.addLine(to: CGPoint(x: startPositionX, y: startPositionY + verticalLen))
        context.addLine(to: CGPoint(x: startPositionX, y: startPositionY + verticalLen - term))
        
        context.move(to: CGPoint(x: startPositionX + horizontalLen - term, y: startPositionY + verticalLen))
        context.addLine(to: CGPoint(x: startPositionX + horizontalLen, y: startPositionY + verticalLen))
        context.addLine(to: CGPoint(x: startPositionX + horizontalLen, y: startPositionY + verticalLen - term))
        
        context.strokePath()
    }
    
    // 그리드에 그려지지 않고 캔버스에 바로 그려진다.
    // 선택되어 그려지는 상자의 테두리를 점선으로 그리며 점선은 움직인다.
    
    // [] 선택된 영역이 움직여야 한다.
    // [] 선택된 영역을 취소할 수 있어야 한다.
    // [] 선택하는 영역을 수정할 수 있게 만드나?
    
    // 선택된 영역의 안쪽을 클릭하면 움직이고, 바깥을 클릭하면 취소되며 드래그할 경우에는 새로운 영역을 선택하기 시작
    // 모서리에 앵커를 두어서 드래그 할 경우에 영역의 크기가 수정된다.
    // 선택된 영역을 움직일때는 그리드의 데이터만 움직인다.
    
    // context를 받아서 선택된 영역에 선을 그리는 함수
    

}
