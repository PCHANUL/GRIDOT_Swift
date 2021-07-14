//
//  TimeMachineViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/07/12.
//

import UIKit

class TimeMachineViewModel: NSObject {
    var canvas: Canvas!
    private var timeGrid: [String]!
    var maxTime: Int!
    var startIndex: Int!
    var endIndex: Int!
    
    init(_ initCanvas: Canvas) {
        canvas = initCanvas
        timeGrid = [""]
        maxTime = 10
        startIndex = 0
        endIndex = 0
    }
    
    func undo() {
        print(timeGrid)
        if (endIndex != startIndex) {
            endIndex -= 1
        }
        let selectedLayer = canvas.panelVC.layerVM.selectedLayerIndex
        canvas.changeGrid(index: selectedLayer, gridData: timeGrid[endIndex])
    }
    
    func redo() {
        if (endIndex != timeGrid.count) {
            endIndex += 1
        }
        let selectedLayer = canvas.panelVC.layerVM.selectedLayerIndex
        canvas.changeGrid(index: selectedLayer, gridData: timeGrid[endIndex])
    }
    
    func addTime() {
        let gridData = matrixToString(grid: canvas.grid.gridLocations)
        if (startIndex == maxTime - 1 || timeGrid.count != endIndex) {
            relocateTimes(startIndex, endIndex)
            startIndex = 0
        }
        timeGrid.append(gridData)
        if (timeGrid.count > maxTime) {
            startIndex += 1
        }
        endIndex = timeGrid.count - 1
    }
    
    func relocateTimes(_ startIndex: Int, _ endIndex: Int) {
        var newTimeGrid: [String] = []
        for index in startIndex...endIndex {
            newTimeGrid.append(timeGrid[index])
        }
        timeGrid = newTimeGrid
    }
    
}

