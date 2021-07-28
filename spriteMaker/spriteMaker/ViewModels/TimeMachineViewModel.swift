//
//  TimeMachineViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/07/12.
//

import UIKit

class TimeMachineViewModel: NSObject {
    var canvas: Canvas!
    var undoBtn: UIButton!
    var redoBtn: UIButton!
    
    private var timeGrid: [String]!
    var maxTime: Int!
    var startIndex: Int!
    var endIndex: Int!
    
    init(_ canvas: Canvas, _ undoBtn: UIButton, _ redoBtn: UIButton) {
        self.canvas = canvas
        self.undoBtn = undoBtn
        self.redoBtn = redoBtn
        
        timeGrid = [""]
        maxTime = 10
        startIndex = 0
        endIndex = 0
    }
    
    func undo() {
        if (endIndex != startIndex) {
            endIndex -= 1
            let selectedLayer = canvas.panelVC.layerVM.selectedLayerIndex
            canvas.changeGrid(index: selectedLayer, gridData: timeGrid[endIndex])
        }
        setButtonColor()
    }
    
    func redo() {
        if (endIndex != timeGrid.count - 1) {
            endIndex += 1
            let selectedLayer = canvas.panelVC.layerVM.selectedLayerIndex
            canvas.changeGrid(index: selectedLayer, gridData: timeGrid[endIndex])
        }
        setButtonColor()
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
        setButtonColor()
    }
    
    func setButtonColor() {
        undoBtn.tintColor = endIndex != startIndex ? UIColor.white : UIColor.lightGray
        redoBtn.tintColor = endIndex != timeGrid.count - 1 ? UIColor.white : UIColor.lightGray
    }
    
    func relocateTimes(_ startIndex: Int, _ endIndex: Int) {
        var newTimeGrid: [String] = []
        for index in startIndex...endIndex {
            newTimeGrid.append(timeGrid[index])
        }
        timeGrid = newTimeGrid
    }
}

//    struct Time {
//        var frames: [Frame]
//        var selectedFrame: Int
//        var selectedLayer: Int
//    }
//
//    struct Frame {
//        var layers: [Layer]
//    }
//
//    struct Layer {
//        var gridData: String
//        var ishidden: Bool
//    }
