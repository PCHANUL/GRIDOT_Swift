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
    
    private var times: [Time]
    var maxTime: Int!
    var startIndex: Int!
    var endIndex: Int!
    
    init(_ canvas: Canvas, _ undoBtn: UIButton, _ redoBtn: UIButton) {
        self.canvas = canvas
        self.undoBtn = undoBtn
        self.redoBtn = redoBtn
        
        times = []
        maxTime = 20
        startIndex = 0
        endIndex = 0
    }
    
    func undo() {
        if (endIndex != startIndex) {
            endIndex -= 1
            setTime()
        }
        setButtonColor()
    }
    
    func redo() {
        if (endIndex != times.count - 1) {
            endIndex += 1
            setTime()
        }
        setButtonColor()
    }
    
    func setTime() {
        let layerViewModel = canvas.panelVC.layerVM
        let time = times[endIndex]
        
        layerViewModel!.frames = time.frames
        layerViewModel!.selectedLayerIndex = time.selectedLayer
        layerViewModel!.selectedFrameIndex = time.selectedFrame
        canvas.changeGrid(
            index: time.selectedLayer,
            gridData: time.frames[time.selectedFrame].layers[time.selectedLayer]!.gridData
        )
    }
    
    func addTime() {
        let layerViewModel = canvas.panelVC.layerVM
        let frames = layerViewModel?.frames
        var time = Time(frames: [], selectedFrame: layerViewModel!.selectedFrameIndex, selectedLayer: layerViewModel!.selectedLayerIndex)
        
        for frame in frames! {
            let frameImage: UIImage
            var newFrame: Frame
                
            frameImage = time.frames.count == time.selectedFrame
                ? canvas.renderLayerImage()
                : frame!.renderedImage
            newFrame = Frame(
                layers: [],
                renderedImage: frameImage,
                category: frame!.category
            )
            for layer in frame!.layers {
                let layerImage: UIImage
                let newLayer: Layer
                let newGrid: String
                
                newGrid = newFrame.layers.count == time.selectedLayer
                    ? matrixToString(grid: canvas.grid.gridLocations)
                    : layer!.gridData
                layerImage = newFrame.layers.count == time.selectedLayer
                    ? canvas.renderLayerImage()
                    : layer!.renderedImage
                newLayer = Layer(
                    gridData: newGrid,
                    renderedImage: layerImage,
                    ishidden: layer!.ishidden
                )
                newFrame.layers.append(newLayer)
            }
            time.frames.append(newFrame)
        }
        if (startIndex == maxTime - 1 || times.count != endIndex) {
            relocateTimes(startIndex, endIndex)
            startIndex = 0
        }
        times.append(time)
        if (times.count > maxTime) {
            startIndex += 1
        }
        endIndex = times.count - 1
        setButtonColor()
    }
    
    
    
    func setButtonColor() {
        undoBtn.tintColor = endIndex != startIndex ? UIColor.white : UIColor.lightGray
        redoBtn.tintColor = endIndex != times.count - 1 ? UIColor.white : UIColor.lightGray
    }
    
    func relocateTimes(_ startIndex: Int, _ endIndex: Int) {
        var newTimes: [Time] = []
        for index in startIndex...endIndex {
            newTimes.append(times[index])
        }
        times = newTimes
    }
}
