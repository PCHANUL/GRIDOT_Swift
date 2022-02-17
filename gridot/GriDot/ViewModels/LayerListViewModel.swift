//
//  LayerListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/07.
//

import UIKit

class LayerListViewModel {
    var frames: [Frame] = []
    var selectedFrameIndex: Int = -1
    var selectedLayerIndex: Int = 0
    var previewAndLayerCVC: PreviewAndLayerCollectionViewCell?
    
    func updateSelectedLayerAndFrame(_ frameImage: UIImage, _ layerImage: UIImage, data: [Int]) {
        guard var targetFrame = selectedFrame else { return }
        var targetLayer = targetFrame.layers[selectedLayerIndex]

        targetFrame.renderedImage = frameImage
        targetLayer.renderedImage = layerImage
        targetLayer.data = data
        targetFrame.layers[selectedLayerIndex] = targetLayer
        frames[selectedFrameIndex] = targetFrame
        reloadLayerList()
        reloadPreviewList()
    }
    
    func reloadLayerList() {
        guard let layerCell = previewAndLayerCVC else { return }
        guard let collectionView = layerCell.layerListCell.layerCollection else { return }
        
        collectionView.reloadData()
    }
    
    func reloadPreviewList() {
        guard let previewCell = previewAndLayerCVC else { return }
        guard let collection = previewCell.previewListCell.previewImageCollection else { return }
        
        collection.reloadData()
    }
    
    func reloadRemovedList() {
        guard let viewController = previewAndLayerCVC else { return }
        
        viewController.previewListCell.updateCanvasData()
        viewController.previewListCell.previewImageCollection.reloadData()
        viewController.canvas.setNeedsDisplay()
    }
    
    // ---- Image methods ----
    func getAllImages() -> [UIImage] {
        var result: [UIImage]
        if (frames.count == 0) { return [] }
        result = frames.map { frame in
            return frame.renderedImage
        }
        return result
    }
    
    func getVisibleLayerImages() -> [UIImage?] {
        guard let selectedFrame = self.selectedFrame else { return [] }
        
        return selectedFrame.layers.map { layer in
            if (layer.ishidden) { return nil }
            return layer.renderedImage
        }
    }
    
    // ---- frame methods ----
    // Create
    func addEmptyFrame(index: Int) {
        insertFrame(at: index, Frame())
    }
    
    func copyPreFrame() {
        frames.insert(selectedFrame!, at: selectedFrameIndex)
        selectedFrameIndex += 1
        reloadPreviewList()
    }
    
    // Read
    var numsOfFrames: Int {
        return frames.count
    }
    
    var selectedFrame: Frame? {
        if (frames.count == 0 || frames.count <= selectedFrameIndex) { return nil }
        return frames[selectedFrameIndex]
    }
    
    func getFrame(at: Int) -> Frame? {
        if (numsOfFrames <= at) { return nil }
        return frames[at]
    }
    
    func getCategorys() -> [String] {
        var categorys: [String]
        
        categorys = []
        for frame in frames {
            if categorys.contains(where: { $0 == frame.category }) == false {
                categorys.append(frame.category)
            }
        }
        return categorys
    }
    
    func getCategoryImages(category: String) -> [UIImage] {
        var categoryImages: [UIImage]
        
        categoryImages = []
        for frame in frames {
            if (frame.category == category || category == "All") {
                categoryImages.append(frame.renderedImage)
            }
        }
        return categoryImages
    }
    
    // Update
    func setSelectedFrameIndex(index: Int) {
        if (index > frames.count - 1) { return }
        selectedFrameIndex = index
        selectedLayerIndex = 0
        reloadLayerList()
        previewAndLayerCVC?.previewListCell.updateCanvasData()
        previewAndLayerCVC?.previewListCell.previewImageCollection.reloadData()
    }
    
    func reorderFrame(dst: Int, src: Int) -> Bool {
        if (frames.count <= dst || frames.count == src) { return false }
        let frame = frames.remove(at: src)
        
        frames.insert(frame, at: dst)
        selectedFrameIndex.setSelectedIndex(src, dst)
        reloadPreviewList()
        return true
    }
    
    func insertFrame(at index: Int, _ item: Frame) {
        frames.insert(item, at: index)
        reloadPreviewList()
    }
    
    func updateCurrentFrame(frame: Frame) {
        frames[selectedFrameIndex] = frame
        reloadPreviewList()
    }
    
    // Delete
    func removeCurrentFrame() {
        let _ = removeFrame(at: selectedFrameIndex)
        
    }
    
    func removeFrame(at index: Int) -> Frame {
        if numsOfFrames == 1 { return frames[0] }
        let frame = frames.remove(at: index)
        if (selectedFrameIndex != 0) {
            selectedFrameIndex -= 1
            selectedLayerIndex = 0
        }
        reloadRemovedList()
        return frame
    }
    
    // ---- layer methods ----
    // Create
    func addNewLayer(layer: Layer) {
        guard let frame = selectedFrame else { return }
        
        selectedLayerIndex = frame.layers.count
        frames[selectedFrameIndex].layers.append(layer)
        reloadLayerList()
    }
    
    // Read
    var numsOfLayer: Int {
        if selectedFrame != nil {
            return selectedFrame!.layers.count
        } else {
            return 0
        }
    }
    
    var selectedLayer: Layer? {
        if (selectedFrame == nil || selectedFrame!.layers.count <= selectedLayerIndex) { return nil }
        let layer = selectedFrame!.layers[selectedLayerIndex]
        return layer
    }
    
    var isHiddenSelectedLayer: Bool {
        guard let layer = selectedLayer else { return false }
        return layer.ishidden
    }
    
    func getLayer(index: Int) -> Layer? {
        if (selectedFrame?.layers.count)! <= index { return nil }
        return selectedFrame?.layers[index]
    }
    
    func isExistedFrameAndLayer(_ frameIndex: Int, _ layerIndex: Int) -> Bool {
        if (frames.count == 0 || frames.count <= frameIndex) { return false }
        return (frames[frameIndex].layers[layerIndex] != nil)
    }
    
    // Update
    func setSelectedLayerIndex(index: Int) {
        if (frames.count == 0 || frames.count <= selectedFrameIndex) { return }
        if (index > frames[selectedFrameIndex].layers.count - 1) { return }
        selectedLayerIndex = index
        reloadLayerList()
        previewAndLayerCVC?.previewListCell.previewImageCollection.reloadData()
    }
    
    func reorderLayer(dst: Int, src: Int) -> Bool {
        if (frames.count == 0 || frames.count <= selectedFrameIndex) { return false }
        var frame = frames[selectedFrameIndex]
        if (frame.layers.count <= dst || frame.layers.count == src) { return false }
        let layer = frame.layers.remove(at: src)
        
        frame.layers.insert(layer, at: dst)
        frames[selectedFrameIndex] = frame
        selectedLayerIndex.setSelectedIndex(src, dst)
        reloadRemovedList()
        return true
    }
    
    func toggleVisibilitySelectedLayer() {
        guard let layer = selectedLayer else { return }
        let ishidden: Bool
            
        ishidden = layer.ishidden
        if (frames.count == 0 || frames.count <= selectedFrameIndex) { return }
        frames[selectedFrameIndex].layers[selectedLayerIndex].ishidden = !ishidden
        reloadRemovedList()
    }
    
    // Delete
    func deleteSelectedLayer() {
        guard let frame = selectedFrame else { return }
        if frame.layers.count > 1 {
            frames[selectedFrameIndex].layers.remove(at: selectedLayerIndex)
            if (selectedLayerIndex != 0) {
                selectedLayerIndex -= 1
            }
        } else {
            frames[selectedFrameIndex].layers[0] = Layer()
        }
        reloadRemovedList()
    }
}
