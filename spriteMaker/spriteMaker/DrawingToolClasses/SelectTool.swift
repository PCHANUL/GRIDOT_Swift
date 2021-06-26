//
//  SelectTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/26.
//

import UIKit

class SelectTool {
    var canvas: Canvas!
    var grid: Grid!
    var pixelLen: CGFloat!
    var selectedPositions: [String: [Int: [Int]]] = [:]
    var outlineTerm: CGFloat!
    var outlineToggle: Bool!
    var drawOutlineInterval: Timer?

    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
        self.pixelLen = canvas.onePixelLength
        self.outlineTerm = self.pixelLen / 4
    }
    
    
}
