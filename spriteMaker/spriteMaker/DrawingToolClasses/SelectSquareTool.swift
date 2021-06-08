//
//  SelectSquareTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/03.
//

import UIKit

class SelectSquareTool {
    var canvas: Canvas!
    var drawAreaInterval: Timer!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
    }
    
    func drawSelectedArea(_ context: CGContext) {
        // 네모를 그린다.
        guard let canvaslen = canvas.lengthOfOneSide else { return }
        let oneSide: CGFloat = 200
        let position = (canvaslen / 2) - (oneSide / 2)
        let lineWidth: CGFloat = 1
        context.setLineWidth(lineWidth)
//        context.setStrokeColor(UIColor.lightGray.cgColor)
//        context.addRect(CGRect(x: position, y: position, width: oneSide, height: oneSide))
//        context.strokePath()
        
        context.setStrokeColor(UIColor.white.cgColor)
        
        let term: CGFloat = (oneSide / 10)
        
        var i = 0
        var pos: CGFloat = 0
        
        drawAreaInterval = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)
        { (Timer) in
            print("0")
            // 가로
            i = 0
            pos = 0
            while (i < 5) {
                context.move(to: CGPoint(x: position - (lineWidth / 2) + pos, y: position))
                context.addLine(to: CGPoint(x: position + term + pos, y: position))
                pos += term
                context.move(to: CGPoint(x: position - (lineWidth / 2) + pos, y: position + oneSide))
                context.addLine(to: CGPoint(x: position + term + pos, y: position + oneSide))
                pos += term
                i += 1
            }
            
            // 세로
            i = 0
            pos = 0
            while (i < 5) {
                context.move(to: CGPoint(x: position + oneSide, y: position - (lineWidth / 2) + pos))
                context.addLine(to: CGPoint(x: position + oneSide, y: position + term + pos))
                pos += term
                context.move(to: CGPoint(x: position, y: position - (lineWidth / 2) + pos))
                context.addLine(to: CGPoint(x: position, y: position + term + pos))
                pos += term
                i += 1
            }
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
