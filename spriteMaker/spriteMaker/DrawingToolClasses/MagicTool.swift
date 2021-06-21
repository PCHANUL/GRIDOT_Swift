//
//  MagicTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/20.
//

import UIKit

class MagicTool {
    var canvas: Canvas!
    var grid: Grid!
    var pixelLen: CGFloat!
    var term: CGFloat!
    var colorPositions: [Int: [Int]] = [:]
    var selectedPositions: [Int: [Int]] = [:]
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.pixelLen = canvas.onePixelLength
        self.term = self.pixelLen / 3
    }
    
    func setSelectedPosition(_ pos: [String: Int]) {
        print(pos)
        guard let x = pos["x"] else { return }
        guard let y = pos["y"] else { return }
        if (isSelectedPosition(x, y) == false) {
            let color = canvas.grid.findColorSelected(x: x, y: y)
            colorPositions = grid.getLocations(hex: color)
            selectedPositions = [:]
            findSameColorPosition(color, x, y)
        }
        print(selectedPositions)
    }
    
    func drawHorizontalOutline(_ context: CGContext, _ x: CGFloat, _ y: CGFloat) {
        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: x + term, y: y))
        context.move(to: CGPoint(x: x + (term * 2), y: y))
        context.addLine(to: CGPoint(x: x + (term * 3), y: y))
        context.strokePath()
    }
    
    func drawVerticalOutline(_ context: CGContext, _ x: CGFloat, _ y: CGFloat) {
        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: x, y: y + term))
        context.move(to: CGPoint(x: x, y: y + (term * 2)))
        context.addLine(to: CGPoint(x: x, y: y + (term * 3)))
        context.strokePath()
    }
    
    func drawSelectedOutline(_ context: CGContext) {
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        for posX in selectedPositions {
            for posY in posX.value {
                let x = pixelLen * CGFloat(posX.key)
                let y = pixelLen * CGFloat(posY)
                if (!isSelectedPosition(posX.key, posY - 1)) { drawHorizontalOutline(context, x, y) }
                if (!isSelectedPosition(posX.key, posY + 1)) { drawHorizontalOutline(context, x, y + pixelLen) }
                if (!isSelectedPosition(posX.key - 1, posY)) { drawVerticalOutline(context, x, y) }
                if (!isSelectedPosition(posX.key + 1, posY)) { drawVerticalOutline(context, x + pixelLen, y) }
            }
        }
    }
    
    func isSelectedPosition(_ x: Int, _ y: Int) -> Bool {
        guard let posX = selectedPositions[x] else { return false }
        return posX.firstIndex(of: y) != nil
    }
    
    func isPosition(_ x: Int, _ y: Int) -> Bool {
        guard let posX = colorPositions[x] else { return false }
        return posX.firstIndex(of: y) != nil
    }
    
    func removePosition(_ x: Int, _ y: Int) {
        guard let pos = colorPositions[x] else { return }
        guard let index = pos.firstIndex(of: y) else { return }
        colorPositions[x]?.remove(at: index)
    }
    
    func addPosition(_ x: Int, _ y: Int) {
        if (selectedPositions[x] == nil) { selectedPositions[x] = [] }
        selectedPositions[x]?.append(y)
    }
    
    // colorPositions의 요소를 하나씩 지워서 만약에 없다면 다음으로 넘어간다.
    func findSameColorPosition(_ hex: String, _ x: Int, _ y: Int) {
        addPosition(x, y)
        removePosition(x, y)
        if (isPosition(x + 1, y)) { findSameColorPosition(hex, x + 1, y) }
        if (isPosition(x - 1, y)) { findSameColorPosition(hex, x - 1, y) }
        if (isPosition(x, y + 1)) { findSameColorPosition(hex, x, y + 1) }
        if (isPosition(x, y - 1)) { findSameColorPosition(hex, x, y - 1) }
    }
    
}

// 선택한 좌표에 인접한 픽셀들 중에서 같은 색들이 선택된다.
// 인접한 픽셀들을 어떤 방식으로 찾아야하는가?
// 사방을 재귀함수로 확인,


