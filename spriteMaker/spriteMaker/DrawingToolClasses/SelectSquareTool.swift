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
    
    var accX: CGFloat!
    var accY: CGFloat!
    var isTouchedInside: Bool!
    var pixelsInArea: [String: [Int: [Int]]]!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        isDrawing = false
        isTouchedInside = false
        pixelLen = canvas.onePixelLength
        canvasLen = canvas.lengthOfOneSide
        accX = 0
        accY = 0
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
        accX = 0
        accY = 0
    }
    
    func replacePixels(_ grid: Grid) {
        if pixelsInArea == nil { return }
        for color in pixelsInArea {
            for x in color.value {
                for y in x.value {
                    grid.addLocation(hex: color.key, x: x.key, y: y);
                }
            }
        }
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
        return (minX! + accX <= posX && posX <= maxX! + accX
                    && minY! + accY <= posY && posY <= maxY! + accX)
    }
    
    func setStartPosition(_ touchPosition: [String: Int]) {
        startPosition = touchPosition
        startX = (pixelLen * CGFloat(touchPosition["x"]!))
        startY = (pixelLen * CGFloat(touchPosition["y"]!))
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
        accX = endX - startX
        accY = endY - startY
    }
    
    func endMovePosition() {
        moveSelectedAreaPixels()
        minX += accX
        minY += accY
        maxX += accX
        maxY += accY
        accX = 0
        accY = 0
    }
    
    func getSelectedAreaPixels(_ grid: Grid) {
        pixelsInArea = grid.getPixelsInRect(Int(minX / pixelLen), Int(minY / pixelLen),
                                            Int(maxX / pixelLen), Int(maxY / pixelLen))
        for color in pixelsInArea {
            for x in color.value {
                for y in x.value {
                    grid.removeLocationIfSelected(hex: color.key, x: x.key, y: y);
                }
            }
        }
    }
    
    func moveSelectedAreaPixels() {
        var arr: [Int: [Int]]
        for color in pixelsInArea {
            arr = [:]
            for x in color.value {
                let xkey = Int(x.key) + Int(accX / pixelLen)
                arr[xkey] = x.value.map({ return $0 + Int(accY / pixelLen) })
            }
            pixelsInArea[color.key] = arr
        }
    }
    
    func drawSelectedAreaPixels(_ context: CGContext) {
        if (!isTouchedInside) { return }
        context.setLineWidth(0)
        let widthOfPixel = Double(pixelLen)
        for color in pixelsInArea {
            for x in color.value {
                for y in x.value {
                    context.setFillColor(color.key.uicolor!.cgColor)
                    let xlocation = (Double(x.key) * widthOfPixel) + Double(accX)
                    let ylocation = (Double(y) * widthOfPixel)  + Double(accY)
                    let rectangle = CGRect(x: xlocation, y: ylocation,
                                           width: widthOfPixel, height: widthOfPixel)
                    context.addRect(rectangle)
                    context.drawPath(using: .fillStroke)
                }
            }
        }
        context.strokePath()
    }
    
    // grid에서 min과 max사이에 있는 픽셀의 위치를 모두 가져온다.
    // grid에서 해당 픽셀들을 모두 제거한다.
    // 가져온 픽셀들을 context로 그린다.
    
    func drawSelectedArea(_ context: CGContext) {
        if !isDrawing { return }
        let term: CGFloat
        var pos: CGFloat
        let accMinX: CGFloat!
        let accMinY: CGFloat!
        let accMaxX: CGFloat!
        let accMaxY: CGFloat!
       
        term = 7
        pos = 0
        accMinX = minX + accX
        accMinY = minY + accY
        accMaxX = maxX + accX
        accMaxY = maxY + accY
        
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.white.cgColor)
        
        context.move(to: CGPoint(x: accMinX, y: accMinY))
        while ((pos + (term * 2)) <= xLen) {
            pos += term
            context.addLine(to: CGPoint(x: accMinX + pos, y: accMinY))
            context.move(to: CGPoint(x: accMinX + pos - term, y: accMaxY))
            context.addLine(to: CGPoint(x: accMinX + pos, y: accMaxY))
            pos += term
            context.move(to: CGPoint(x: accMinX + pos, y: accMinY))
        }
        context.move(to: CGPoint(x: accMinX + pos, y: accMaxY))
        context.addLine(to: CGPoint(x: accMaxX, y: accMaxY))
        context.move(to: CGPoint(x: accMinX + pos, y: accMinY))
        context.addLine(to: CGPoint(x: accMaxX, y: accMinY))
        
        pos = 0
        context.move(to: CGPoint(x: accMinX, y: accMinY))
        while ((pos + (term * 2)) <= yLen) {
            pos += term
            context.addLine(to: CGPoint(x: accMinX, y: accMinY + pos))
            context.move(to: CGPoint(x: accMaxX, y: accMinY + pos - term))
            context.addLine(to: CGPoint(x: accMaxX, y: accMinY + pos))
            pos += term
            context.move(to: CGPoint(x: accMinX, y: accMinY + pos))
        }
        context.move(to: CGPoint(x: accMaxX, y: accMinY + pos))
        context.addLine(to: CGPoint(x: accMaxX, y: accMaxY))
        context.move(to: CGPoint(x: accMinX, y: accMinY + pos))
        context.addLine(to: CGPoint(x: accMinX, y: accMaxY))
        
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
