//
//  ColorPalette.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/23.
//

import UIKit

struct ColorPalette {
    var name: String
    var colors: [String]
    
    mutating func addColor(color: String) {
        colors.insert(color, at: 0)
    }
    
    mutating func insertColor(index: Int, color: String) {
        colors.insert(color, at: index)
    }
    
    mutating func updateColor(index: Int, color: String) {
        colors[index] = color
    }
    
    mutating func removeColor(index: Int) -> String {
        return colors.remove(at: index)
    }
    
    mutating func renamePalette(newName: String) {
        name = newName
    }
}
