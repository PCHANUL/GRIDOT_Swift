//
//  Grid.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit

class Grid {
    private var grid: [String: [Int: [Int]]] = [:]  // grid [color: [x: [y]]]
    
    var gridLocations: [String: [Int: [Int]]] {
        return grid
    }
    
    func initGrid() {
        grid = [:]
    }
    
    func isColored(hex: String) -> Bool {
        guard let _ = grid[hex] else { return false }
        return true
    }
    
    func isSelected(_ hex: String, _ x: Int, _ y: Int) -> Bool {
        guard let colorLocations = grid[hex] else { return false }
        guard let location = colorLocations[x] else { return false }
        if location.firstIndex(of: y) == nil { return false }
        else { return true }
    }
    
    func findColorSelected(x: Int, y: Int) -> String {
        for (hex, locations) in grid {
            guard let location = locations[x] else { continue }
            if (location.firstIndex(of: y) != nil) { return hex }
        }
        return "none"
    }
    
    func getPixelsInRect(_ minX: Int, _ minY: Int, _ maxX: Int, _ maxY: Int) -> [String: [Int: [Int]]] {
        var pixels: [String: [Int: [Int]]] = [:]
        var arrY: [Int: [Int]]
        
        for hex in grid {
            arrY = [:]
            for x in minX..<maxX {
                pixels[hex.key] = [:]
                if (hex.value[x] != nil) {
                    arrY[x] = hex.value[x]!.filter({ return (minY <= $0 && maxY > $0) })
                }
                pixels[hex.key] = arrY
            }
        }
        return pixels
    }
    
    func addColor(hex: String, x: Int, y: Int) {
        for color in grid.keys {
            if color != hex { removeLocationIfSelected(hex: color, x: x, y: y) }
        }
        grid[hex] = [Int(x): [y]]
    }
    
    func addLocation(hex: String, x: Int, y: Int) {
        
        // 다른 색이 이미 칠해져 있다면 제거
        for color in grid.keys {
            if color != hex { removeLocationIfSelected(hex: color, x: x, y: y) }
        }
        
        // 같은 색으로 이미 색칠되지 않았다면 색칠
        if isSelected(hex, x, y) == false {
            if grid[hex] == nil {
                addColor(hex: hex, x: x, y: y)
            } else if var locations = grid[hex]![x] {
                locations.append(y)
                grid[hex]![x] = locations
            } else {
                grid[hex]![x] = [y]
            }
        }
    }
    
    func removeLocation(_ x: Int, _ y: Int) {
        for (hex, locations) in grid {
            guard let location = locations[x] else { continue }
            if (location.firstIndex(of: y) != nil) {
                let filtered = grid[hex]?[x]?.filter { $0 != y }
                if filtered!.count == 0 {
                    grid[hex]!.removeValue(forKey: x)
                    if grid[hex]!.keys.count == 0 {
                        grid.removeValue(forKey: hex)
                    }
                } else {
                    grid[hex]?[x] = filtered
                }
                return
            }
        }
    }
    
    func removeLocationIfSelected(hex: String, x: Int, y: Int) {
        if isSelected(hex, x, y) {
            let filtered = grid[hex]?[x]?.filter { $0 != y }
            if filtered!.count == 0 {
                grid[hex]!.removeValue(forKey: x)
                if grid[hex]!.keys.count == 0 {
                    grid.removeValue(forKey: hex)
                }
            } else {
                grid[hex]?[x] = filtered
            }
        }
    }
    
    func setGrid(newGrid: [String: [Int: [Int]]]) {
        self.grid = newGrid
    }
    
    func getLocations(hex: String) -> [Int: [Int]] {
        guard let colorLocations = grid[hex] else { return [:] }
        return colorLocations
    }
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
    
    func getSubstring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: to - from)
        return String(self[start ..< end])
    }
}
