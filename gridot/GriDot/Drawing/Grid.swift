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
    let str = hex.getSubstring(from: 1, to: 6)
    guard let result = Int(str, radix: 10) else { return nil }
    return (result)
}

func transIntToHex(_ val: Int) -> String? {
    let result = String(val, radix: 16)
    if (result.count != 6) { return nil }
    return ("#\(result)")
}

func getGridIndex(_ pos: CGPoint) -> Int? {
    let x = Int(pos.x), y = Int(pos.y)
    if (15 < y || 0 > y || 15 < x || 0 > x) { return nil }
    return ((y * 16) + x)
}

//class Grid {
//    var intGrid: [String: [Int32]] = [:]
//
//    func initGrid() {
//        intGrid = [:]
//    }
//
//    func isColored(hex: String) -> Bool {
//        guard let _ = intGrid[hex] else { return false }
//        return true
//    }
//
//    func isSelected(_ hex: String, _ pos: CGPoint) -> Bool {
//        let x = Int(pos.x)
//        let y = Int(pos.y)
//        guard let posArr = intGrid[hex] else { return false }
//        if (15 < y || 0 > y || 15 < x || 0 > x) { return false }
//        if (posArr[y] == 0) { return false }
//        return posArr[y].getBitStatus(x)
//    }
//
//    func findColorSelected(_ pos: CGPoint) -> String {
//        let x = Int(pos.x)
//        let y = Int(pos.y)
//
//        for (hex, locations) in intGrid {
//            if (locations[y].getBitStatus(x) == true) {
//                return hex
//            }
//        }
//        return "none"
//    }
//
//    func addNewColor(_ hex: String, _ pos: CGPoint) {
//        for color in intGrid.keys {
//            if color != hex { removeLocationIfSelected(color, pos) }
//        }
//        intGrid[hex] = Array(repeating: 0, count: 16)
//        intGrid[hex]![Int(pos.y)].setBitOn(Int(pos.x))
//    }
//
//    func addLocation(_ hex: String, _ pos: CGPoint) {
//        if (hex == "none" || pos.x < 0 || pos.x > 15 || pos.y < 0 || pos.y > 15) { return }
//        let x = Int(pos.x)
//        let y = Int(pos.y)
//
//        // 다른 색이 이미 칠해져 있다면 제거
//        for color in intGrid.keys {
//            if color != hex { removeLocationIfSelected(color, pos) }
//        }
//
//        // 같은 색으로 이미 색칠되지 않았다면 색칠
//        if (isSelected(hex, pos) == false) {
//            if (intGrid[hex] != nil) {
//                intGrid[hex]![y].setBitOn(x)
//            } else {
//                addNewColor(hex, pos)
//            }
//        }
//    }
//
//    func removeLocation(_ pos: CGPoint) {
//        let hex = findColorSelected(pos)
//        removeLocationIfSelected(hex, pos)
//    }
//
//    func removeLocationIfSelected(_ hex: String, _ pos: CGPoint) {
//        let x = Int(pos.x)
//        let y = Int(pos.y)
//
//        if (isSelected(hex, pos)) {
//            intGrid[hex]![y].setBitOff(x)
//            if (intGrid[hex]![y] == 0) {
//                let isEmpty = intGrid[hex]?.filter({$0 != 0})
//                if (isEmpty!.count == 0) {
//                    intGrid.removeValue(forKey: hex)
//                }
//            }
//        }
//    }
//
//    func getLocations(hex: String) -> [Int32] {
//        guard let colorLocations = intGrid[hex] else { return [] }
//        return colorLocations
//    }
//}

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
