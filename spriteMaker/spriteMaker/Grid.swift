//
//  Grid.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit

class Grid {
    
    // [] 그리드 클래스를 리팩토링한다.
    // - [] 그리드를 저장하는 방식은 [색상 : [좌표]] 이다.
    
    
    private var gridArray: [[Int]] = []
    var count: Int = 0
    
    init(numsOfPixels: Int) {
        self.createGrid(numsOfPixels: numsOfPixels)
    }
    
    func isEmpty(x: Int, y: Int) -> Bool {
        return gridArray[y][x] == 0
    }
    
    func createGrid(numsOfPixels: Int) {
        gridArray = Array(repeating: Array(repeating: 0, count: numsOfPixels), count: numsOfPixels)
    }
    
    func readGrid() -> [[Int]] {
        return gridArray
    }
    
    func updateGrid(targetPos: [String: Int], isEmptyPixel: Bool) {
        self.gridArray[targetPos["y"]!][targetPos["x"]!] = isEmptyPixel ? 1 : 0
        count += isEmptyPixel ? 1 : -1
    }
    
    func changeGrid(newGrid: [[Int]]) {
        self.gridArray = newGrid
    }
}


// UIColor to HEX
extension UIColor {
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: nil) else { return nil }
        return (r,g,b)
    }
    
    var hexa: String? {
        guard let (r,g,b) = rgb else { return nil }
        return "#" + UInt8(r*255).hexa + UInt8(g*255).hexa + UInt8(b*255).hexa
    }
}

extension UInt8 {
    var hexa: String {
        let value = String(self, radix: 16, uppercase: true)
        return (self < 16 ? "0": "") + value
    }
}

// HEX to UIColor
extension String {
    var uicolor: UIColor? {
        guard let (r, g, b) = rgb else { return nil }
        return UIColor.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
    }

    var rgb: (red: Int, green: Int, blue: Int)? {
        let r = Int(getSubstring(from: 1, to: 3), radix: 16)!
        let g = Int(getSubstring(from: 3, to: 5), radix: 16)!
        let b = Int(getSubstring(from: 5, to: 7), radix: 16)!
        return (r, g, b)
    }
    
    func getSubstring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: to - from)
        return String(self[start ..< end])
    }
    
}
