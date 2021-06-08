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
        isDrawing = !isDrawing
    }
    
    func drawSelectedArea(_ context: CGContext) {
        if !isDrawing { return }
        guard let pixelLen = canvas.onePixelLength else { return }
        
        let lineWidth: CGFloat = 1
        
        let oneSide: CGFloat = 200
        let term: CGFloat = (oneSide / 30)
        
        let startPositionX = pixelLen * CGFloat(startPosition["x"]!)
        let startPositionY = pixelLen * CGFloat(startPosition["y"]!)
        let endPositionX = pixelLen * CGFloat(endPosition["x"]!)
        let endPositionY = pixelLen * CGFloat(endPosition["y"]!)
        
        let horizontalLen = endPositionX - startPositionX
        let verticalLen = endPositionY - startPositionY
        
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.white.cgColor)
        
        // 가로
        var i = 0
        var pos: CGFloat = 0
        while (pos < horizontalLen) {
            context.move(to: CGPoint(x: startPositionX - (lineWidth / 2) + pos, y: startPositionY))
            context.addLine(to: CGPoint(x: startPositionX + term + pos, y: startPositionY))
            pos += term
            context.move(to: CGPoint(x: startPositionX - (lineWidth / 2) + pos, y: startPositionY + verticalLen))
            context.addLine(to: CGPoint(x: startPositionX + term + pos, y: startPositionY + verticalLen))
            pos += term
            i += 1
        }
        
        // 세로
        i = 0
        pos = 0
        while (pos < verticalLen) {
            context.move(to: CGPoint(x: startPositionX + horizontalLen, y: startPositionY - (lineWidth / 2) + pos))
            context.addLine(to: CGPoint(x: startPositionX + horizontalLen, y: startPositionY + term + pos))
            pos += term
            context.move(to: CGPoint(x: startPositionX, y: startPositionY - (lineWidth / 2) + pos))
            context.addLine(to: CGPoint(x: startPositionX, y: startPositionY + term + pos))
            pos += term
            i += 1
        }
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
