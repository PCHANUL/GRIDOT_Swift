//
//  PaintTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/01.
//

import UIKit

class PaintTool {
    var canvas: Canvas!
    var grid: Grid!
    var painted: [Int: [Int]]!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.painted = [:]
    }
    
    // 빈공간을 모두 채우거나
    // 현재 위치의 색과 연결된 픽셀을 바꾼다.
    
    // grid의 pixel을 확인하여 색을 칠한다.
    // 색을 칠한 곳은 피한다.
    func isPainted(_ x: Int, _ y: Int) -> Bool {
        guard let yPixels = painted[x] else { return false }
        if yPixels.firstIndex(of: y) == nil { return false }
        else { return true }
    }
    
    func paintSameAreaPixels(_ x: Int, _ y: Int) {
        if (isPainted(x, y) == false && x < canvas.numsOfPixels && x > -1 && y < canvas.numsOfPixels && y > -1) {
            grid.addLocation(hex: canvas.selectedColor.hexa!, x: x, y: y)
            if (painted[x] != nil) {
                painted[x]!.append(y)
            } else {
                painted[x] = [y]
            }
            if (grid.isSeletedPixel(x + 1, y) == false) { paintSameAreaPixels(x + 1, y) }
            if (grid.isSeletedPixel(x, y + 1) == false) { paintSameAreaPixels(x, y + 1) }
            if (grid.isSeletedPixel(x - 1, y) == false) { paintSameAreaPixels(x - 1, y) }
            if (grid.isSeletedPixel(x, y - 1) == false) { paintSameAreaPixels(x, y - 1) }
        }
    }
    
}

extension PaintTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
        paintSameAreaPixels(pixelPosition["x"]!, pixelPosition["y"]!)
    }
    func touchesBeganOnDraw(_ context: CGContext) {
    }
    func touchesMoved(_ context: CGContext) {
    }
    func touchesEnded(_ context: CGContext) {
    }
}
