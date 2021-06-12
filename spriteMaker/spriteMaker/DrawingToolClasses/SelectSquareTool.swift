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
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        isDrawing = false
        pixelLen = canvas.onePixelLength
    }
    
    func isTouchedInsideArea(_ touchPosition: [String: Int]) -> Bool? {
        guard let x = touchPosition["x"] else { return nil }
        guard let y = touchPosition["y"] else { return nil }
        let posX = pixelLen * CGFloat(x)
        let posY = pixelLen * CGFloat(y)
        return (minX < posX && posX < maxX && minY < posY && posY < maxY)
    }
    
    func setStartPosition(_ touchPosition: [String: Int]) {
        startX = pixelLen * CGFloat(touchPosition["x"]!)
        startY = pixelLen * CGFloat(touchPosition["y"]!)
        isDrawing = true
    }
    
    func setEndPosition(_ touchPosition: [String: Int]) {
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
    
    
    func drawSelectedArea(_ context: CGContext) {
        if !isDrawing { return }
        let term: CGFloat
        var pos: CGFloat
        var flag: CGFloat
       
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.move(to: CGPoint(x: startX, y: startY))
        
        term = 7
        pos = 0
        flag = endX - startX < 0 ? -1 : 1
        while ((pos + (term * 2 * flag)) * flag <= xLen * flag) {
            pos += term * flag
            context.addLine(to: CGPoint(x: startX + pos, y: startY))
            context.move(to: CGPoint(x: startX + pos - (term * flag), y: endY))
            context.addLine(to: CGPoint(x: startX + pos, y: endY))
            pos += term * flag
            context.move(to: CGPoint(x: startX + pos, y: startY))
        }
        context.move(to: CGPoint(x: startX + pos, y: endY))
        context.addLine(to: CGPoint(x: endX, y: endY))
        context.move(to: CGPoint(x: startX + pos, y: startY))
        context.addLine(to: CGPoint(x: endX, y: startY))
        
        pos = 0
        flag = endY - startY < 0 ? -1 : 1
        context.move(to: CGPoint(x: startX, y: startY))
        while ((pos + (term * 2 * flag)) * flag <= yLen * flag) {
            pos += term * flag
            context.addLine(to: CGPoint(x: startX, y: startY + pos))
            context.move(to: CGPoint(x: endX, y: startY + pos - (term * flag)))
            context.addLine(to: CGPoint(x: endX, y: startY + pos))
            pos += term * flag
            context.move(to: CGPoint(x: startX, y: startY + pos))
        }
        context.move(to: CGPoint(x: endX, y: startY + pos))
        context.addLine(to: CGPoint(x: endX, y: endY))
        context.move(to: CGPoint(x: startX, y: startY + pos))
        context.addLine(to: CGPoint(x: startX, y: endY))
        
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
