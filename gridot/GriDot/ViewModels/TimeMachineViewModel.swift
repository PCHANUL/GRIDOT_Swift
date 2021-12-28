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
    var drawingVC: DrawingViewController!
    
    var times: [String]
    var maxTime: Int!
    var startIndex: Int!
    var endIndex: Int!
    
    init(_ canvas: Canvas? = nil, _ drawingVC: DrawingViewController? = nil) {
        self.canvas = canvas
        self.drawingVC = drawingVC
        
        times = []
        maxTime = 20
        startIndex = 0
        endIndex = 0
    }
    
    var canUndo: Bool {
        return endIndex != startIndex
    }
    
    var canRedo: Bool {
        if (times.count == 0) { return false }
        return endIndex != times.count - 1
    }
    
    var presentTime: Time? {
        return decompressData(
            times[endIndex],
            size: CGSize(width: canvas.lengthOfOneSide, height: canvas.lengthOfOneSide)
        )
    }
    
    func isSameSelectedFrameIndex(timeIndex: Int) -> Bool {
        if (timeIndex < 0 || timeIndex >= times.count) { return false }
        let inputIndex = times[timeIndex].getSubstring(from: 0, to: 1)
        let selectedIndex = String(canvas.drawingVC.layerVM.selectedFrameIndex)
        
        return (selectedIndex == inputIndex)
    }

    func isSameSelectedLayerIndex(timeIndex: Int) -> Bool {
        if (timeIndex < 0 || timeIndex >= times.count) { return false }
        let inputIndex = times[timeIndex].getSubstring(from: 2, to: 3)
        let selectedIndex = String(canvas.drawingVC.layerVM.selectedLayerIndex)
        
        return (selectedIndex == inputIndex)
    }
    
    func undo() {
        if (canUndo) {
            endIndex -= 1
            setTimeToLayerVM()
        }
    }
    
    func redo() {
        if (canRedo) {
            endIndex += 1
            setTimeToLayerVM()
        }
    }
    
    func setTimeToLayerVM() {
        let layerViewModel = canvas.drawingVC.layerVM
        guard let time = decompressData(times[endIndex], size: CGSize(width: canvas.lengthOfOneSide, height: canvas.lengthOfOneSide)) else { return }
        
        layerViewModel!.frames = time.frames
        layerViewModel!.selectedLayerIndex = time.selectedLayer
        layerViewModel!.selectedFrameIndex = time.selectedFrame
        canvas.changeGrid(
            index: time.selectedLayer,
            gridData: time.frames[time.selectedFrame].layers[time.selectedLayer]!.gridData
        )

        CoreData.shared.updateAssetSelected(data: times[endIndex])
        CoreData.shared.updateThumbnailSelected(thumbnail: (time.frames[0].renderedImage.pngData())!)
    }
    
    func compressData(frames: [Frame], selectedFrame: Int, selectedLayer: Int) -> String {
        let categoryModel: CategoryListViewModel
        var result: String

        func addDataString(_ str: String) {
            result += str
            result += "|"
        }

        result = ""
        categoryModel = CategoryListViewModel()

        // set selectedIndex
        addDataString(String(selectedFrame))
        addDataString(String(selectedLayer))
        result += "\n"

        for frameIndex in 0..<frames.count {
            let frame = frames[frameIndex]

            // set category number
            addDataString(String(categoryModel.indexOfCategory(name: frame.category)))

            // set layers data
            for layerIndex in 0..<frame.layers.count {
                let layer = frame.layers[layerIndex]!
                addDataString(layer.ishidden ? "1" : "0")

                if (canvas != nil && selectedFrame == frameIndex && selectedLayer == layerIndex) {
                    let gridData = matrixToString(grid: canvas.grid.gridLocations)
                    addDataString(gridData != "" ? gridData : "none")
                } else {
                    addDataString(layer.gridData != "" ? layer.gridData : "none")
                }
            }
            if (frameIndex < frames.count - 1) {
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
        
        resultTime = Time(frames: [], selectedFrame: 0, selectedLayer: 0)
        
        // split by line
        frameStrs = data.split(separator: "\n")
        if (frameStrs.count == 0) { return nil }
        
        // set selected index
        selectedIndex = frameStrs[0].split(separator: "|")
        if (selectedIndex.count != 2) { return resultTime }
        resultTime.selectedFrame = Int(selectedIndex[0])!
        resultTime.selectedLayer = Int(selectedIndex[1])!
        
        // set Frames
        renderingManager = RenderingManager(size, false)
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
        
        guard let layerVM = canvas.drawingVC.layerVM else { return }
        data = compressData(
            frames: layerVM.frames,
            selectedFrame: layerVM.selectedFrameIndex,
            selectedLayer: layerVM.selectedLayerIndex
        )
        if (startIndex == maxTime - 1 || times.count != endIndex) {
            relocateTimes(startIndex, endIndex)
            startIndex = 0
        }
        times.append(data)
        if (times.count > maxTime) {
            startIndex += 1
        }
        endIndex = times.count - 1
        if (drawingVC.drawingToolBar != nil) {
            drawingVC.drawingToolBar.drawingToolCollection.reloadData()
        }
        
        CoreData.shared.updateAssetSelected(data: data)
        CoreData.shared.updateThumbnailSelected(thumbnail: (layerVM.frames[0].renderedImage.pngData())!)
    }
    
    func relocateTimes(_ startIndex: Int, _ endIndex: Int) {
        var newTimes: [String] = []
        for index in startIndex...endIndex {
            newTimes.append(times[index])
        }
        times = newTimes
    }
}
