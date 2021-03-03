//
//  Grid.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit

class Grid {
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
