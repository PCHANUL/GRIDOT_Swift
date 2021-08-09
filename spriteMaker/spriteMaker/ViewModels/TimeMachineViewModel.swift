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
    
    func isSameSelectedFrame(index: Int) -> Bool {
        return (canvas.panelVC.layerVM.selectedFrameIndex == times[index].selectedFrame)
    }
    
    func isSameSelectedLayer(index: Int) -> Bool {
        return (canvas.panelVC.layerVM.selectedLayerIndex == times[index].selectedLayer)
    }
    
    func undo() {
        if (endIndex != startIndex) {
            endIndex -= 1
            setTimeToLayerVM()
        }
        setButtonColor()
    }
    
    func redo() {
        if (endIndex != times.count - 1) {
            endIndex += 1
            setTimeToLayerVM()
        }
        setButtonColor()
    }
    
    func setTimeToLayerVM() {
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
    
    func compactData() -> String {
        let layerViewModel: LayerListViewModel
        let categoryModel: CategoryListViewModel
        var result: String
        
        func addDataString(_ str: String) {
            result += str
            result += "|"
        }
        
        layerViewModel = canvas.panelVC.layerVM
        categoryModel = canvas.panelVC.animatedPreviewVM.categoryListVM
        result = ""
        for frame in layerViewModel.frames {
            // get category number
            addDataString(String(categoryModel.indexOfCategory(name: frame!.category)))
            
            // get layers data
            for layer in frame!.layers {
                addDataString(layer!.ishidden ? "1" : "0")
                addDataString(layer!.gridData)
            }
            result += "\n"
        }
        return result
    }
    
    func addTime() {
        let newTime: Time
        
        newTime = getNewTime()
        if (startIndex == maxTime - 1 || times.count != endIndex) {
            relocateTimes(startIndex, endIndex)
            startIndex = 0
        }
        print(newTime)
        
        compactData()
        
        times.append(newTime)
        if (times.count > maxTime) {
            startIndex += 1
        }
        endIndex = times.count - 1
        setButtonColor()
    }
    
    // getNewTime -> getNewTimeFrame -> getNewTimeLayer
    func getNewTime() -> Time {
        let layerViewModel = canvas.panelVC.layerVM
        var isSelectedFrame: Bool
        var newTime: Time
        
        newTime = Time(
            frames: [],
            selectedFrame: layerViewModel!.selectedFrameIndex,
            selectedLayer: layerViewModel!.selectedLayerIndex
        )
        for frame in layerViewModel!.frames {
            isSelectedFrame = layerViewModel!.selectedFrameIndex == newTime.frames.count
            newTime.frames.append(
                getNewTimeFrame(frame: frame!, isSelectedFrame: isSelectedFrame)
            )
        }
        return newTime
    }
    
    func getNewTimeFrame(frame: Frame, isSelectedFrame: Bool) -> Frame {
        let layerViewModel = canvas.panelVC.layerVM
        let frameImage: UIImage
        var newFrame: Frame
        var isSelectedLayer: Bool
        
        if (isSelectedFrame) {
            frameImage = canvas.renderLayerImage()
        } else {
            frameImage = frame.renderedImage
        }
        newFrame = Frame(
            layers: [],
            renderedImage: frameImage,
            category: frame.category
        )
        for layer in frame.layers {
            isSelectedLayer = layerViewModel!.selectedLayerIndex == newFrame.layers.count
            newFrame.layers.append(
                getNewTimeLayer(
                    layer: layer!,
                    isSelectedLayer: (isSelectedFrame && isSelectedLayer)
                )
            )
        }
        return newFrame
    }
    
    func getNewTimeLayer(layer: Layer, isSelectedLayer: Bool) -> Layer {
        let layerImage: UIImage
        let newLayer: Layer
        let newGrid: String
        
        if (isSelectedLayer) {
            newGrid = matrixToString(grid: canvas.grid.gridLocations)
            layerImage = canvas.renderLayerImage()
        } else {
            newGrid = layer.gridData
            layerImage = layer.renderedImage
        }
        newLayer = Layer(
            gridData: newGrid,
            renderedImage: layerImage,
            ishidden: layer.ishidden
        )
        return newLayer
    }
    
    func setButtonColor() {
        if (endIndex != startIndex) {
            undoBtn.tintColor = UIColor.white
            undoBtn.isEnabled = true
        } else {
            undoBtn.tintColor = UIColor.lightGray
            undoBtn.isEnabled = false
        }
        
        if (endIndex != times.count - 1) {
            redoBtn.tintColor = UIColor.white
            redoBtn.isEnabled = true
        } else {
            redoBtn.tintColor = UIColor.lightGray
            redoBtn.isEnabled = false
        }
    }
    
    func relocateTimes(_ startIndex: Int, _ endIndex: Int) {
        var newTimes: [Time] = []
        for index in startIndex...endIndex {
            newTimes.append(times[index])
        }
        times = newTimes
    }
}
