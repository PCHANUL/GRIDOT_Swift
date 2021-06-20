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
    var colorPositions: [Int: [Int]]!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
    }
    
    func setSelectedPosition(_ pos: [String: Int]) {
        print(pos)
        
        guard let x = pos["x"] else { return }
        guard let y = pos["y"] else { return }
        let color = canvas.grid.findColorSelected(x: x, y: y)
        colorPositions = grid.getLocations(hex: color)
        print(colorPositions)
        findSameColorPosition(color, x, y)
    }
    
    func isPosition(_ x: Int, _ y: Int) -> Bool {
        guard let posX = colorPositions[x] else { return false }
        return posX.firstIndex(of: y) != nil
    }
    
    func findSameColorPosition(_ hex: String, _ x: Int, _ y: Int) {
        if (isPosition(x, y) == false) {
            // 종료조건
            return
        } else {
            findSameColorPosition(hex, x + 1, y)
            findSameColorPosition(hex, x - 1, y)
            findSameColorPosition(hex, x, y + 1)
            findSameColorPosition(hex, x, y - 1)
        }
    }
    
}

// 선택한 좌표에 인접한 픽셀들 중에서 같은 색들이 선택된다.
// 인접한 픽셀들을 어떤 방식으로 찾아야하는가?
// 사방을 재귀함수로 확인,


