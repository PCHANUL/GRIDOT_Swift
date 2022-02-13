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
    
    var timeData: [[Int32]]
    var selectedData: [[String: [Int32]]]
    var maxTime: Int!
    var startIndex: Int!
    var endIndex: Int!
    
    init(_ canvas: Canvas? = nil, _ drawingVC: DrawingViewController? = nil) {
        self.canvas = canvas
        self.drawingVC = drawingVC
        
        timeData = []
        selectedData = []
        maxTime = 20
        startIndex = 0
        endIndex = 0
    }
    
    var canUndo: Bool {
        return endIndex != startIndex
    }
    
    var canRedo: Bool {
        if (timeData.count == 0) { return false }
        return endIndex != (timeData.count - 1)
    }
    
    var presentTime: Time? {
        let size = CGSize(width: canvas.lengthOfOneSide, height: canvas.lengthOfOneSide)
        
        return decompressDataInt32(timeData[endIndex], size)
    }
    
    func isSameSelectedFrameIndex(timeIndex: Int) -> Bool {
        if (timeIndex < 0 || timeIndex >= timeData.count) { return false }
        let selectedIndex = Int32(canvas.drawingVC.layerVM.selectedFrameIndex)
        
        return (selectedIndex == timeData[timeIndex][0])
    }

    func isSameSelectedLayerIndex(timeIndex: Int) -> Bool {
        if (timeIndex < 0 || timeIndex >= timeData.count) { return false }
        let selectedIndex = Int32(canvas.drawingVC.layerVM.selectedLayerIndex)
        
        return (selectedIndex == timeData[timeIndex][1])
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
    
    func setTimeToLayerVMIntData() {
        let layerViewModel = canvas.drawingVC.layerVM
        let canvasSize = CGSize(width: canvas.lengthOfOneSide, height: canvas.lengthOfOneSide)
        guard let time = decompressDataInt32(timeData[endIndex], canvasSize) else { return }
        
        layerViewModel!.frames = time.frames
        layerViewModel!.selectedLayerIndex = time.selectedLayer
        layerViewModel!.selectedFrameIndex = time.selectedFrame
        canvas.changeGrid(
            index: time.selectedLayer,
            gridData: time.frames[time.selectedFrame].layers[time.selectedLayer].data
        )
        updateCoreDataImageAndData(time.frames[0].renderedImage, timeData[endIndex])
        
        if (selectedData[endIndex].count != 0) {
            canvas.selectedArea.intGrid = selectedData[endIndex]
            canvas.selectedArea.initSelectedAreaToStart()
            canvas.selectedArea.setSelectedPixelWithIntGrid()
        } else if (canvas.selectedArea.drawOutlineInterval?.isValid ?? false) {
            canvas.selectedArea.drawOutlineInterval?.invalidate()
            canvas.updateLayerImage(canvas.targetLayerIndex)
            canvas.drawingVC.drawingToolBar.cancelButton.removeFromSuperview()
            canvas.drawingVC.drawingToolBar.drawingToolCVTrailing.constant = 5
            canvas.selectedArea.selectedPixels = Array(repeating: 0, count: 16)
            canvas.selectedArea.initGrid()
            canvas.setNeedsDisplay()
        }
    }
}

extension TimeMachineViewModel {
    func addTime() {
        guard let layerVM = canvas.drawingVC.layerVM else { return }
        canvas.updateLayerImage(layerVM.selectedLayerIndex)
        
        let data = compressDataInt32(
            frames: layerVM.frames,
            selectedFrame: layerVM.selectedFrameIndex,
            selectedLayer: layerVM.selectedLayerIndex
        )
        
        let dataWithSelectedArea = compressDataInt32WithSelectedArea(
            frames: layerVM.frames,
            selectedFrame: layerVM.selectedFrameIndex,
            selectedLayer: layerVM.selectedLayerIndex,
            selectedData: canvas.selectedArea.intGrid
        )
        
        var newIntGrid: [String: [Int32]] = [:]
        canvas.selectedArea.mapIntGridDic { hex, pos in
            if (newIntGrid[hex] == nil) {
                newIntGrid[hex] = Array(repeating: 0, count: 16)
            }
            newIntGrid[hex]![Int(pos.y)].setBitOn(Int(pos.x))
        }
        
        manageTimeDataArr(data, newIntGrid)
        updateCoreDataImageAndData(layerVM.frames[0].renderedImage, dataWithSelectedArea)
        if (drawingVC.drawingToolBar != nil) {
            drawingVC.drawingToolBar.drawingToolCollection.reloadData()
        }
    }
    
    private func manageTimeDataArr(_ data: [Int32], _ selectData: [String: [Int32]]) {
        // 배열 요소 개수가 maxTime을 넘어간 경우, 배열 요소를 제거하는 대신에 startIndex로 표시한다.
        if (timeData.count > maxTime) {
            startIndex += 1
        }
        // startIndex가 max이거나, endIndex가 마지막이 아닌 경우(undo한 상태에서 addTime하는 경우) 배열 재구성
        if (timeData.count != 0 && (startIndex == (maxTime - 1) || endIndex != (timeData.count - 1))) {
            timeData = Array(timeData[startIndex...endIndex])
            selectedData = Array(selectedData[startIndex...endIndex])
            startIndex = 0
        }
        timeData.append(data)
        selectedData.append(selectData)
        endIndex = timeData.count - 1
    }
    
    private func updateCoreDataImageAndData(_ image: UIImage, _ data: [Int32]) {
        guard let png = image.pngData() else { return }
        CoreData.shared.updateThumbnailSelected(thumbnail: png)
        CoreData.shared.updateAssetSelectedDataInt(data: data)
    }
}
