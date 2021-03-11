//
//  Grid.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit

class Grid {
    // grid [color: [x: [y]]]
    private var grid: [String: [Int: [Int]]] = [:]
    var colors: [String] = []
    
    var gridLocations: [String: [Int: [Int]]] {
        return grid
    }
    
    func isColored(hex: String) -> Bool {
        guard let _ = grid[hex] else { return false }
        return true
    }
    
    func isSelected(hex: String, x: Int, y: Int) -> Bool {
        guard let colorLocations = grid[hex] else { return false }
        guard let location = colorLocations[x] else { return false }
        if location.firstIndex(of: y) == nil { return false }
        else { return true }
    }
    
    func addColor(hex: String, x: Int, y: Int) {
        for color in colors {
            if color != hex { removeLocation(hex: color, x: x, y: y) }
        }
        grid[hex] = [Int(x): [y]]
        colors.append(hex)
    }
    
    func addLocation(hex: String, x: Int, y: Int) {
        for color in colors {
            if color != hex { removeLocation(hex: color, x: x, y: y) }
        }
        if isSelected(hex: hex, x: x, y: y) == false {
            if var locations = grid[hex]![x] {
                locations.append(y)
                grid[hex]![x] = locations
            } else {
                grid[hex]![x] = [y]
            }
        }
    }
    
    func removeLocation(hex: String, x: Int, y: Int) {
        if isSelected(hex: hex, x: x, y: y) {
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
    
    func changeGrid(newGrid: [String: [Int: [Int]]]) {
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
