//
//  Grid.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit

class Grid {
    var data: [Int] = generateInitGrid()
    
    var isEmpty: Bool {
        for ele in data {
            if (ele != -1) { return false }
        }
        return true
    }
    
    func initGrid() {
        data = generateInitGrid()
    }
    
    func addLocation(_ hex: String, _ pos: CGPoint) {
        guard let gridIndex = getGridIndex(pos) else { return }
        guard let intColor = transHexToInt(hex) else { return }
        data[gridIndex] = intColor
    }
    
    func isSelected(_ pos: CGPoint) -> Bool {
        guard let index = getGridIndex(pos) else { return false }
        return (data[index] == 0)
    }
    
    func findColorSelected(_ pos: CGPoint) -> String? {
        guard let index = getGridIndex(pos) else { return nil }
        guard let hex = transIntToHex(data[index]) else { return nil }
        return (hex)
    }
    
    func getIntColorOfPixel(_ pos: CGPoint) -> Int? {
        guard let index = getGridIndex(pos) else { return nil }
        return (data[index])
    }
    
    func mapSameColor(_ intColor: Int, _ callback: (_ x: Int, _ y: Int)->()) {
        for y in 0..<16 {
            for x in 0..<16 {
                guard let idx = getGridIndex(CGPoint(x: x, y: y)) else { continue }
                if (data[idx] == intColor) {
                    callback(x, y)
                }
            }
        }
    }
    
    func removeLocation(_ pos: CGPoint) {
        guard let gridIndex = getGridIndex(pos) else { return }
        data[gridIndex] = -1
    }
}

func generateInitGrid() -> [Int] {
    let pixelNum = 16
    return Array(repeating: -1, count: pixelNum * pixelNum)
}

func transHexToInt(_ hex: String) -> Int? {
    let str = hex.getSubstring(from: 1, to: 7)
    guard let result = Int(str, radix: 16) else { return nil }
    return (result)
}

func transIntToHex(_ val: Int) -> String? {
    var result = String(val, radix: 16, uppercase: true)
    while (result.count < 6) {
        result.insert("0", at: result.startIndex)
    }
    if (result.count != 6) { return nil }
    return ("#\(result)")
}

func getGridIndex(_ pos: CGPoint) -> Int? {
    let x = Int(pos.x), y = Int(pos.y)
    if (x < 0 || x > 15 || y < 0 || y > 15) { return nil }
    return ((y * 16) + x)
}

// UIColor to HEX
extension UIColor {
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: nil) else { return nil }
        r = r > 1 ? 1 : r
        g = g > 1 ? 1 : g
        b = b > 1 ? 1 : b
        
        r = r < 0 ? 0 : r
        g = g < 0 ? 0 : g
        b = b < 0 ? 0 : b
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
        if (self == "none") { return nil }
        guard let (r, g, b) = rgb else { return nil }
        return UIColor.init(
            red: CGFloat(r)/255,
            green: CGFloat(g)/255,
            blue: CGFloat(b)/255,
            alpha: 1
        )
    }

    var rgb: (red: Int, green: Int, blue: Int)? {
        let r = Int(getSubstring(from: 1, to: 3), radix: 16)!
        let g = Int(getSubstring(from: 3, to: 5), radix: 16)!
        let b = Int(getSubstring(from: 5, to: 7), radix: 16)!
        return (r, g, b)
    }
    
    var rgb32: (red: Int32, green: Int32, blue: Int32)? {
        let r = Int32(getSubstring(from: 1, to: 3), radix: 16)!
        let g = Int32(getSubstring(from: 3, to: 5), radix: 16)!
        let b = Int32(getSubstring(from: 5, to: 7), radix: 16)!
        return (r, g, b)
    }
    
    func getSubstring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: to - from)
        return String(self[start ..< end])
    }
}
