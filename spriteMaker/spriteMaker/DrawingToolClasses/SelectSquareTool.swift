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
        
        let startPositionX = pixelLen * CGFloat(startPosition["x"]!)
        let startPositionY = pixelLen * CGFloat(startPosition["y"]!)
        let endPositionX = pixelLen * CGFloat(endPosition["x"]! + 1)
        let endPositionY = pixelLen * CGFloat(endPosition["y"]! + 1)
        
        let horizontalLen = endPositionX - startPositionX
        let verticalLen = endPositionY - startPositionY
        
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.white.cgColor)
        
        let term: CGFloat = 7
        var pos: CGFloat = 0
        var flag: CGFloat
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.move(to: CGPoint(x: startPositionX, y: startPositionY))
        
        flag = endPositionX - startPositionX < 0 ? -1 : 1
        while ((pos + (term * 2 * flag)) * flag <= horizontalLen * flag) {
            pos += term * flag
            context.addLine(to: CGPoint(x: startPositionX + pos, y: startPositionY))
            context.move(to: CGPoint(x: startPositionX + pos - (term * flag), y: endPositionY))
            context.addLine(to: CGPoint(x: startPositionX + pos, y: endPositionY))
            pos += term * flag
            context.move(to: CGPoint(x: startPositionX + pos, y: startPositionY))
        }
        context.move(to: CGPoint(x: startPositionX + pos, y: endPositionY))
        context.addLine(to: CGPoint(x: endPositionX, y: endPositionY))
        context.move(to: CGPoint(x: startPositionX + pos, y: startPositionY))
        context.addLine(to: CGPoint(x: endPositionX, y: startPositionY))
        
        pos = 0
        flag = endPositionY - startPositionY < 0 ? -1 : 1
        while ((pos + (term * 2 * flag)) * flag <= verticalLen * flag) {
            pos += term * flag
            context.addLine(to: CGPoint(x: endPositionX, y: startPositionY + pos))
            context.move(to: CGPoint(x: startPositionX, y: startPositionY + pos - (term * flag)))
            context.addLine(to: CGPoint(x: startPositionX, y: startPositionY + pos))
            pos += term * flag
            context.move(to: CGPoint(x: endPositionX, y: startPositionY + pos))
        }
        context.move(to: CGPoint(x: startPositionX, y: startPositionY + pos))
        context.addLine(to: CGPoint(x: startPositionX, y: endPositionY))
        context.move(to: CGPoint(x: endPositionX, y: startPositionY + pos))
        context.addLine(to: CGPoint(x: endPositionX, y: endPositionY))
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
