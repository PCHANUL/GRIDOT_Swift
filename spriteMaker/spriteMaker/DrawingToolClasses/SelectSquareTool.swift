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
    let pixelLen: CGFloat!
    let canvasLen: CGFloat!
    
    var startX: CGFloat!
    var startY: CGFloat!
    var endX: CGFloat!
    var endY: CGFloat!
    var minX: CGFloat!
    var maxX: CGFloat!
    var minY: CGFloat!
    var maxY: CGFloat!
    var xLen: CGFloat!
    var yLen: CGFloat!
    
    var isTouchedInside: Bool!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        isDrawing = false
        isTouchedInside = false
        pixelLen = canvas.onePixelLength
        canvasLen = canvas.lengthOfOneSide
    }
    
    func isTouchedInsideArea(_ touchPosition: [String: Int]) -> Bool {
        if (xLen == canvasLen && yLen == canvasLen) {
            initPositions()
            return false
        }
        if ((minX == nil) || (maxX == nil) || (minY == nil) || (maxY == nil)) { return false }
        guard let x = touchPosition["x"] else { return false }
        guard let y = touchPosition["y"] else { return false }
        let posX = pixelLen * CGFloat(x)
        let posY = pixelLen * CGFloat(y)
        return (minX! <= posX && posX <= maxX! && minY! <= posY && posY <= maxY!)
    }
    
    func setStartPosition(_ touchPosition: [String: Int]) {
        startPosition = touchPosition
        startX = pixelLen * CGFloat(touchPosition["x"]!)
        startY = pixelLen * CGFloat(touchPosition["y"]!)
        isDrawing = true
    }
    
    func setEndPosition(_ touchPosition: [String: Int]) {
        endPosition = touchPosition
        endX = pixelLen * CGFloat(touchPosition["x"]! + 1)
        xLen = endX - startX
        minX = xLen > 0 ? startX : endX
        maxX = xLen > 0 ? endX : startX
        xLen = xLen > 0 ? xLen : xLen * -1
        
        endY = pixelLen * CGFloat(touchPosition["y"]! + 1)
        yLen = endY - startY
        minY = yLen > 0 ? startY : endY
        maxY = yLen > 0 ? endY : startY
        yLen = yLen > 0 ? yLen : yLen * -1
    }
    
    func setMovePosition(_ touchPosition: [String: Int]) {
        endX = pixelLen * CGFloat(touchPosition["x"]! + 1)
        endY = pixelLen * CGFloat(touchPosition["y"]! + 1)
        
        minX += endX - startX
        maxX += endX - startX
        minY += endY - startY
        maxY += endY - startY
        startX = endX
        startY = endY
    }
    
    func initPositions() {
        startX = 0
        startY = 0
        endX = 0
        endY = 0
        minX = 0
        maxX = 0
        minY = 0
        maxY = 0
        xLen = 0
        yLen = 0
    }
    
    func drawSelectedArea(_ context: CGContext) {
        if !isDrawing { return }
        let term: CGFloat
        var pos: CGFloat
       
        term = 7
        pos = 0
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.white.cgColor)
        
        context.move(to: CGPoint(x: minX, y: minY))
        while ((pos + (term * 2)) <= xLen) {
            pos += term
            context.addLine(to: CGPoint(x: minX + pos, y: minY))
            context.move(to: CGPoint(x: minX + pos - term, y: maxY))
            context.addLine(to: CGPoint(x: minX + pos, y: maxY))
            pos += term
            context.move(to: CGPoint(x: minX + pos, y: minY))
        }
        context.move(to: CGPoint(x: minX + pos, y: maxY))
        context.addLine(to: CGPoint(x: maxX, y: maxY))
        context.move(to: CGPoint(x: minX + pos, y: minY))
        context.addLine(to: CGPoint(x: maxX, y: minY))
        
        pos = 0
        context.move(to: CGPoint(x: minX, y: minY))
        while ((pos + (term * 2)) <= yLen) {
            pos += term
            context.addLine(to: CGPoint(x: minX, y: minY + pos))
            context.move(to: CGPoint(x: maxX, y: minY + pos - term))
            context.addLine(to: CGPoint(x: maxX, y: minY + pos))
            pos += term
            context.move(to: CGPoint(x: minX, y: minY + pos))
        }
        context.move(to: CGPoint(x: maxX, y: minY + pos))
        context.addLine(to: CGPoint(x: maxX, y: maxY))
        context.move(to: CGPoint(x: minX, y: minY + pos))
        context.addLine(to: CGPoint(x: minX, y: maxY))
        
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
