//
//  LayerListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/07.
//

import UIKit

class LayerListViewModel {
    var frames: [Frame?] = []
    var selectedFrameIndex: Int = -1
    var selectedLayerIndex: Int = 0
    var previewAndLayerCVC: PreviewAndLayerCollectionViewCell?
    
    func updateSelectedLayerAndFrame(_ frameImage: UIImage, _ layerImage: UIImage, gridData: String) {
        guard var targetFrame = selectedFrame else { return }
        guard var targetLayer = targetFrame.layers[selectedLayerIndex] else { return }

        targetFrame.renderedImage = frameImage
        targetLayer.renderedImage = layerImage
        targetLayer.gridData = gridData
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
        return frames.map { frame in
            return frame!.renderedImage
        }
    }
    
    func getVisibleLayerImages() -> [UIImage?] {
        guard let selectedFrame = self.selectedFrame else { return [] }
        
        return selectedFrame.layers.map { layer in
            if (layer!.ishidden) { return nil }
            return layer!.renderedImage
        }
    }
    
    // ---- frame methods ----
    // Create
    func addEmptyFrameNextToSelectedFrame() {
        let layer: Layer
        let frame: Frame
        
        layer = Layer(
            gridData: "",
            renderedImage: UIImage(named: "empty")!,
            ishidden: false
        )
        frame = Frame(
            layers: [layer],
            renderedImage: UIImage(named: "empty")!,
            category: "Default"
        )
        selectedFrameIndex += 1
        insertFrame(at: selectedFrameIndex, frame)
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
        if (frames.count == 0) { return nil }
        guard let frame = frames[selectedFrameIndex] else { return nil }
        
        return frame
    }
    
    func getFrame(at: Int) -> Frame? {
        return frames[at] ?? nil
    }
    
    func getCategorys() -> [String] {
        var categorys: [String]
        
        categorys = []
        for frame in frames {
            if categorys.contains(where: { $0 == frame!.category }) == false {
                categorys.append(frame!.category)
            }
        }
        return categorys
    }
    
    func getCategoryImages(category: String) -> [UIImage] {
        var categoryImages: [UIImage]
        
        categoryImages = []
        for frame in frames {
            if frame!.category == category {
                categoryImages.append(frame!.renderedImage)
            }
        }
        return categoryImages
    }
    
    // Update
    func reorderFrame(dst: Int, src: Int) {
        guard let frame = frames.remove(at: src) else { return }
        
        frames.insert(frame, at: dst)
        selectedFrameIndex = dst
        selectedLayerIndex = 0
        reloadPreviewList()
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
        if numsOfFrames == 1 { return frames[0]! }
        let frame = frames.remove(at: index)!
        if (selectedFrameIndex != 0) {
            selectedFrameIndex -= 1
        }
        reloadRemovedList()
        return frame
    }
    
    // ---- layer methods ----
    // Create
    func addNewLayer(layer: Layer) {
        guard let frame = selectedFrame else { return }
        
        selectedLayerIndex = frame.layers.count - 1
        frames[selectedFrameIndex]!.layers.insert(layer, at: selectedLayerIndex + 1)
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
        if (selectedFrame == nil) { return nil }
        guard let layer = selectedFrame!.layers[selectedLayerIndex] else { return nil }
        return layer
    }
    
    var isHiddenSelectedLayer: Bool {
        guard let layer = selectedLayer else { return false }
        return layer.ishidden
    }
    
    func getLayer(index: Int) -> Layer? {
        if (selectedFrame?.layers.count)! <= index { return nil }
        return selectedFrame?.layers[index] ?? nil
    }
    
    func isExistedFrameAndLayer(_ frameIndex: Int, _ layerIndex: Int) -> Bool {
        guard let frame = frames[frameIndex] else { return false }
        return (frame.layers[layerIndex] != nil)
    }
    
    // Update
    func reorderLayer(dst: Int, src: Int) {
        guard var frame = frames[selectedFrameIndex] else { return }
        guard let layer = frame.layers.remove(at: src) else { return }
        
        frame.layers.insert(layer, at: dst)
        frames[selectedFrameIndex] = frame
        selectedLayerIndex = dst
        reloadPreviewList()
        reloadLayerList()
    }
    
    func toggleVisibilitySelectedLayer() {
        guard let layer = selectedLayer else { return }
        let ishidden = layer.ishidden
        frames[selectedFrameIndex]!.layers[selectedLayerIndex]?.ishidden = !ishidden
        reloadPreviewList()
        reloadLayerList()
    }
    
    // Delete
    func deleteSelectedLayer() {
        guard let frame = selectedFrame else { return }
        if frame.layers.count > 1 {
            frames[selectedFrameIndex]!.layers.remove(at: selectedLayerIndex)
            selectedLayerIndex -= 1
        } else {
            frames[selectedFrameIndex]!.layers[0] = Layer(
                gridData: "",
                renderedImage: UIImage(named: "empty")!,
                ishidden: false
            )
        }
        reloadPreviewList()
        reloadLayerList()
    }
}
