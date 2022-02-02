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
    
//    var times: [String]
    var timesInt: [[Int32]]
    var maxTime: Int!
    var startIndex: Int!
    var endIndex: Int!
    
    init(_ canvas: Canvas? = nil, _ drawingVC: DrawingViewController? = nil) {
        self.canvas = canvas
        self.drawingVC = drawingVC
        
//        times = []
        timesInt = []
        maxTime = 20
        startIndex = 0
        endIndex = 0
    }
    
    var canUndo: Bool {
        return endIndex != startIndex
    }
    
    var canRedo: Bool {
        if (timesInt.count == 0) { return false }
        return endIndex != (timesInt.count - 1)
    }
    
    var presentTime: Time? {
        return decompressDataInt32(
            timesInt[endIndex],
            size: CGSize(width: canvas.lengthOfOneSide, height: canvas.lengthOfOneSide)
        )
    }
    
    func isSameSelectedFrameIndex(timeIndex: Int) -> Bool {
        if (timeIndex < 0 || timeIndex >= timesInt.count) { return false }
        let selectedIndex = Int32(canvas.drawingVC.layerVM.selectedFrameIndex)
        
        return (selectedIndex == timesInt[timeIndex][0])
    }

    func isSameSelectedLayerIndex(timeIndex: Int) -> Bool {
        if (timeIndex < 0 || timeIndex >= timesInt.count) { return false }
        let selectedIndex = Int32(canvas.drawingVC.layerVM.selectedLayerIndex)
        
        return (selectedIndex == timesInt[timeIndex][1])
    }
    
    func undo() {
        if (canUndo) {
            endIndex -= 1
            setTimeToLayerVMIntData()
        }
    }
    
    func redo() {
        if (canRedo) {
            endIndex += 1
            setTimeToLayerVMIntData()
        }
    }
    
//    func setTimeToLayerVM() {
//        let layerViewModel = canvas.drawingVC.layerVM
//        guard let time = decompressData(times[endIndex], size: CGSize(width: canvas.lengthOfOneSide, height: canvas.lengthOfOneSide)) else { return }
//
//        layerViewModel!.frames = time.frames
//        layerViewModel!.selectedLayerIndex = time.selectedLayer
//        layerViewModel!.selectedFrameIndex = time.selectedFrame
//        canvas.changeGrid(
//            index: time.selectedLayer,
//            gridData: time.frames[time.selectedFrame].layers[time.selectedLayer].gridData
//        )
//        if (canvas.selectedArea.isDrawing) { canvas.selectedArea.setSelectedGrid() }
//
//        CoreData.shared.updateAssetSelected(data: times[endIndex])
//        CoreData.shared.updateThumbnailSelected(thumbnail: (time.frames[0].renderedImage.pngData())!)
//    }
    
    func setTimeToLayerVMIntData() {
        let layerViewModel = canvas.drawingVC.layerVM
        let canvasSize = CGSize(width: canvas.lengthOfOneSide, height: canvas.lengthOfOneSide)
        guard let time = decompressDataInt32(timesInt[endIndex], size: canvasSize) else { return }
        
        layerViewModel!.frames = time.frames
        layerViewModel!.selectedLayerIndex = time.selectedLayer
        layerViewModel!.selectedFrameIndex = time.selectedFrame
        canvas.changeGridIntData(
            index: time.selectedLayer,
            gridData: time.frames[time.selectedFrame].layers[time.selectedLayer].data
        )
        if (canvas.selectedArea.isDrawing) { canvas.selectedArea.setSelectedGrid() }
        CoreData.shared.updateAssetSelectedDataInt(data: timesInt[endIndex])
        
        guard let pngData = time.frames[0].renderedImage.pngData() else { return }
        CoreData.shared.updateThumbnailSelected(thumbnail: pngData)
    }
    
    // selectedFrame, selectedLayer, frame category, layer isHidden, layer data
    func compressDataInt32(frames: [Frame], selectedFrame: Int, selectedLayer: Int) -> [Int32] {
        var result: [Int32] = []
        let categoryModel = CategoryListViewModel()
        
        result.append(contentsOf: [Int32(selectedFrame), Int32(selectedLayer)])
        for frame in frames {
            result.append(contentsOf: [-3, Int32(categoryModel.indexOfCategory(name: frame.category))])
            for layer in frame.layers {
                result.append(contentsOf: [-2, layer.ishidden ? 1 : 0])
                for (hex, layerGrid) in layer.data {
                    let (r, g, b) = hex.rgb32!
                    result.append(-1)
                    result.append(contentsOf: [r, g, b])
                    result.append(-16)
                    result.append(contentsOf: layerGrid)
                }
            }
        }
        return result
    }
    
//    func compressData(frames: [Frame], selectedFrame: Int, selectedLayer: Int) -> String {
//        let categoryModel: CategoryListViewModel
//        var result: String
//
//        func addDataString(_ str: String) {
//            result += str
//            result += "|"
//        }
//
//        result = ""
//        categoryModel = CategoryListViewModel()
//
//        // set selectedIndex
//        addDataString(String(selectedFrame))
//        addDataString(String(selectedLayer))
//        result += "\n"
//
//        for frameIndex in 0..<frames.count {
//            let frame = frames[frameIndex]
//
//            // set category number
//            addDataString(String(categoryModel.indexOfCategory(name: frame.category)))
//
//            // set layers data
//            for layerIndex in 0..<frame.layers.count {
//                let layer = frame.layers[layerIndex]
//
//                addDataString(layer.ishidden ? "1" : "0")
//                addDataString(layer.gridData != "" ? layer.gridData : "none")
//            }
//            if (frameIndex < frames.count - 1) {
//                result += "\n"
//            }
//        }
//        return result
//    }
    
    func decompressDataInt32(_ data: [Int32], size: CGSize) -> Time? {
        let renderingManager = RenderingManager(size, false)
        var time = Time(frames: [], selectedFrame: Int(data[0]), selectedLayer: Int(data[1]))
        var idx = 2
        var idx_frame = -1
        var idx_layer = -1
        var hex: String?
        
        while (idx < data.count) {
            switch data[idx] {
            case -3:
                // category
                idx_frame += 1
                time.frames.append(Frame(
                    layers: [], renderedImage: UIImage(),
                    category: CategoryListViewModel().item(at: Int(data[idx + 1])).text
                ))
                idx += 2
            case -2:
                // isHidden
                idx_layer += 1
                time.frames[idx_frame].layers.append(Layer(
                    data: [:], renderedImage: UIImage(),
                    ishidden: data[idx + 1] == 0 ? false : true
                ))
                idx += 2
            case -1:
                // hex
                hex = UIColor(
                    red: CGFloat(data[idx + 1]) / 255,
                    green: CGFloat(data[idx + 2]) / 255,
                    blue: CGFloat(data[idx + 3]) / 255,
                    alpha: 1
                ).hexa
                idx += 4
            case -16:
                // grid
                if (hex == nil) { continue }
                var arr: [Int32] = []
                while (idx < data.count && data[idx] != -2 && data[idx] != -3) {
                    arr.append(data[idx])
                    idx += 1
                }
                time.frames[idx_frame].layers[idx_layer].data[hex!] = arr
                let image = renderingManager.renderLayerImageInt32(
                    data: time.frames[idx_frame].layers[idx_layer].data
                )
                time.frames[idx_frame].layers[idx_layer].renderedImage = image
            default:
                break
            }
        }
        return time
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
                        data: [:],
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
        guard let layerVM = canvas.drawingVC.layerVM else { return }
        canvas.updateViewModelImageIntData(layerVM.selectedLayerIndex)
<<<<<<< HEAD
=======
        let data = compressData(
            frames: layerVM.frames,
            selectedFrame: layerVM.selectedFrameIndex,
            selectedLayer: layerVM.selectedLayerIndex
        )
        
>>>>>>> a88a778 (Fixing grid function)
        let dataInt32 = compressDataInt32(
            frames: layerVM.frames,
            selectedFrame: layerVM.selectedFrameIndex,
            selectedLayer: layerVM.selectedLayerIndex
        )
        
        if (startIndex == maxTime - 1 || timesInt.count != endIndex) {
            relocateTimes(startIndex, endIndex)
            startIndex = 0
        }
        
        timesInt.append(dataInt32)
        if (timesInt.count > maxTime) {
            startIndex += 1
        }
        endIndex = timesInt.count - 1
        if (drawingVC.drawingToolBar != nil) {
            drawingVC.drawingToolBar.drawingToolCollection.reloadData()
        }
        let image = layerVM.frames[0].renderedImage
        CoreData.shared.updateThumbnailSelected(thumbnail: (image.pngData())!)
        CoreData.shared.updateAssetSelectedDataInt(data: dataInt32)
    }
    
    func relocateTimes(_ startIndex: Int, _ endIndex: Int) {
        var newTimes: [[Int32]] = []
        for index in startIndex...endIndex {
            newTimes.append(timesInt[index])
        }
        timesInt = newTimes
    }
}
