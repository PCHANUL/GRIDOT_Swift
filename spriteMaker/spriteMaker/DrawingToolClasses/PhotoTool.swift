//
//  PhotoTool.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/12.
//

import UIKit

class PhotoTool {
    var canvas: Canvas!
    var grid: Grid!
    
    init(_ canvas: Canvas) {
        self.canvas = canvas
        self.grid = canvas.grid
    }
    
    
}

extension PhotoTool {
    func touchesBegan(_ pixelPosition: [String: Int]) {
    }
    
    func touchesBeganOnDraw(_ context: CGContext) {
    }
    
    func touchesMoved(_ context: CGContext) {
    }
    
    func touchesEnded(_ context: CGContext) {
    }
}
