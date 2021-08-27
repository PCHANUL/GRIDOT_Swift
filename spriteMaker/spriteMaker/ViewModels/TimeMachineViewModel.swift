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
    
    var times: [String]
    var maxTime: Int!
    var startIndex: Int!
    var endIndex: Int!
    
    init(_ canvas: Canvas? = nil, _ undoBtn: UIButton? = nil, _ redoBtn: UIButton? = nil) {
        self.canvas = canvas
        self.undoBtn = undoBtn
        self.redoBtn = redoBtn
        
        times = []
        maxTime = 20
        startIndex = 0
        endIndex = 0
    }
    
    var presentTime: Time? {
        return decompressData(
            times[endIndex],
            size: CGSize(width: canvas.lengthOfOneSide, height: canvas.lengthOfOneSide)
        )
    }
    
    func isSameSelectedFrame(index: Int) -> Bool {
        return (String(canvas.panelVC.layerVM.selectedFrameIndex) == times[index].getSubstring(from: 0, to: 1))
    }

    func isSameSelectedLayer(index: Int) -> Bool {
        return (String(canvas.panelVC.layerVM.selectedLayerIndex) == times[index].getSubstring(from: 2, to: 3))
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
        guard let time = decompressData(times[endIndex], size: CGSize(width: canvas.lengthOfOneSide, height: canvas.lengthOfOneSide)) else { return }
        
        layerViewModel!.frames = time.frames
        layerViewModel!.selectedLayerIndex = time.selectedLayer
        layerViewModel!.selectedFrameIndex = time.selectedFrame
        canvas.changeGrid(
            index: time.selectedLayer,
            gridData: time.frames[time.selectedFrame].layers[time.selectedLayer]!.gridData
        )
    }
    
    func compressData() -> String {
        let layerViewModel: LayerListViewModel
        let categoryModel: CategoryListViewModel
        var result: String
        
        func addDataString(_ str: String) {
            result += str
            result += "|"
        }
        
        result = ""
        layerViewModel = canvas.panelVC.layerVM
        categoryModel = canvas.panelVC.animatedPreviewVM.categoryListVM
        
        // set selectedIndex
        addDataString(String(layerViewModel.selectedFrameIndex))
        addDataString(String(layerViewModel.selectedLayerIndex))
        result += "\n"
        
        for frameIndex in 0..<layerViewModel.frames.count {
            let frame = layerViewModel.frames[frameIndex]
            
            // set category number
            addDataString(String(categoryModel.indexOfCategory(name: frame!.category)))
            
            // set layers data
            for layerIndex in 0..<frame!.layers.count {
                let layer = frame!.layers[layerIndex]!
                addDataString(layer.ishidden ? "1" : "0")
        
                if (layerViewModel.selectedFrameIndex == frameIndex && layerViewModel.selectedLayerIndex == layerIndex) {
                    let gridData = matrixToString(grid: canvas.grid.gridLocations)
                    addDataString(gridData != "" ? gridData : "none")
                } else {
                    addDataString(layer.gridData != "" ? layer.gridData : "none")
                }
            }
            if (frameIndex < layerViewModel.frames.count - 1) {
                result += "\n"
            }
        }
        return result
    }
    
    func decompressData(_ data: String, size: CGSize) -> Time? {
        var resultTime: Time
        let frameStrs: [String.SubSequence]
        let selectedIndex: [Substring.SubSequence]
        let renderingManager: RenderingManager
        
        // split by line
        frameStrs = data.split(separator: "\n")
        if (frameStrs.count == 0) { return nil }
        
        // set selected index
        selectedIndex = frameStrs[0].split(separator: "|")
        resultTime = Time(
            frames: [],
            selectedFrame: Int(selectedIndex[0]) ?? 0,
            selectedLayer: Int(selectedIndex[1]) ?? 0
        )
        
        // set Frames
        renderingManager = RenderingManager(size)
        for frameIndex in 1..<frameStrs.count {
            var strArr: [Substring.SubSequence]
            var newFrame: Frame
            var index: Int
            
            // splited [category, ishidden, gridData, ishidden, gridData, ... ]
            strArr = frameStrs[frameIndex].split(separator: "|")
            newFrame = Frame(
                layers: [],
                renderedImage: UIImage(),
                category: CategoryListViewModel().item(at: Int(strArr[0])!).text
            )
            
            // set layers
            index = 1
            while (index < strArr.count) {
                let image: UIImage
                
                if (strArr[index + 1] == "none") {
                    image = UIImage(named: "empty")!
                    strArr[index + 1] = ""
                } else {
                    image = renderingManager.renderLayerImage(stringToMatrix(String(strArr[index + 1])))
                }
                newFrame.layers.append(
                    Layer(
                        gridData: String(strArr[index + 1]),
                        renderedImage: image,
                        ishidden: strArr[index] == "0" ? false : true
                    )
                )
                index += 2
            }
            
            // render frame image
            newFrame.renderedImage = renderingManager.renderFrameImage(newFrame.layers)
            resultTime.frames.append(newFrame)
        }
        return resultTime
    }
    
    func addTime() {
        let data: String
        
        data = compressData()
        if (startIndex == maxTime - 1 || times.count != endIndex) {
            relocateTimes(startIndex, endIndex)
            startIndex = 0
        }
        times.append(data)
        if (times.count > maxTime) {
            startIndex += 1
        }
        endIndex = times.count - 1
        setButtonColor()
        CoreData().updateData(data: data)
    }

    func setButtonColor() {
        // set undo button
        if (endIndex != startIndex) {
            undoBtn.tintColor = UIColor.white
            undoBtn.isEnabled = true
        } else {
            undoBtn.tintColor = UIColor.lightGray
            undoBtn.isEnabled = false
        }
        // set redo button
        if (endIndex != times.count - 1) {
            redoBtn.tintColor = UIColor.white
            redoBtn.isEnabled = true
        } else {
            redoBtn.tintColor = UIColor.lightGray
            redoBtn.isEnabled = false
        }
    }
    
    func relocateTimes(_ startIndex: Int, _ endIndex: Int) {
        var newTimes: [String] = []
        for index in startIndex...endIndex {
            newTimes.append(times[index])
        }
        times = newTimes
    }
}
