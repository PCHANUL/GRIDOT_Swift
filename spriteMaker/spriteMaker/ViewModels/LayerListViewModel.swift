//
//  LayerListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/07.
//

import UIKit

class LayerListViewModel {
    var frames: [Frame?] = []
    var selectedFrameIndex: Int = 0
    var selectedLayerIndex: Int = 0
    var previewAndLayerCVC: PreviewAndLayerCollectionViewCell?
    
    // frame methods
    var selectedItem: Frame? {
        if (frames.count == 0) { return nil }
        return frames[selectedFrameIndex]
    }
    
    func changeselectedFrameIndex(index: Int) {
        selectedFrameIndex = index
    }
    
    func reloadLayerList() {
        guard let layerCell = previewAndLayerCVC else { return }
        guard let collection = layerCell.layerListCell.layerCollection else { return }
        collection.reloadData()
    }
    
    func reloadPreviewList() {
        guard let viewController = previewAndLayerCVC else { return }
        viewController.previewVM.reloadRemovedList()
        viewController.canvas.setNeedsDisplay()
    }
    
    func addEmptyItem(isInit: Bool) {
        let layer: Layer
        let frame: Frame
        
        layer = Layer(
            gridData: "",
            layerImage: UIImage(named: "empty")!,
            ishidden: false
        )
        frame = Frame(
            layers: [layer],
            frameImage: UIImage(named: "empty")!,
            category: "Default"
        )
        if isInit {
            frames.append(frame)
            reloadLayerList()
        } else {
            insertItem(at: selectedFrameIndex + 1, frame)
        }
    }
    
    func copyPreItem() {
        frames.insert(selectedItem!, at: selectedFrameIndex)
        selectedFrameIndex += 1
        reloadLayerList()
    }
    
    func reorderItem(dst: Int, src: Int) {
        let item = frames.remove(at: src)
        frames.insert(item, at: dst)
        selectedFrameIndex = dst
        selectedLayerIndex = 0
        reloadLayerList()
    }
    
    func insertItem(at index: Int, _ item: Frame) {
        frames.insert(item, at: index)
        selectedFrameIndex += 1
        reloadLayerList()
    }
    
    // layer methods
    var numsOfLayer: Int {
        if selectedItem != nil {
            return selectedItem!.layers.count
        } else {
            return 0
        }
    }
    
    var selectedLayer: Layer? {
        if selectedItem != nil {
            return selectedItem!.layers[selectedLayerIndex]
        }
        return nil
    }
    
    var isSelectedHiddenLayer: Bool {
        guard let layer = selectedLayer else { return false }
        return layer.ishidden
    }
    
    func isExistedFrameAndLayer(frameIndex: Int, layerIndex: Int) -> Bool {
        guard let frame = frames[frameIndex] else { return false }
        return (frame.layers[layerIndex] != nil)
    }
    
    func reorderLayer(dst: Int, src: Int) {
        guard var frame = frames[selectedFrameIndex] else { return }
        guard let layer = frame.layers.remove(at: src) else { return }
        
        frame.layers.insert(layer, at: dst)
        frames[selectedFrameIndex] = frame
        selectedLayerIndex = dst
        reloadPreviewList()
        reloadLayerList()
    }
    
    func getLayer(index: Int) -> Layer? {
        if (selectedItem?.layers.count)! <= index { return nil }
        return selectedItem?.layers[index] ?? nil
    }
    
    func getVisibleLayerImages() -> [UIImage?] {
        guard let selectedItem = self.selectedItem else { return [] }
        return selectedItem.layers.map { layer in
            if (layer!.ishidden) { return nil }
            return layer!.layerImage
        }
    }
    
    func updateSelectedLayer(layerImage: UIImage, gridData: String) {
        frames[selectedFrameIndex].layers[selectedLayerIndex].layerImage = layerImage
        frames[selectedFrameIndex].layers[selectedLayerIndex].gridData = gridData
        reloadLayerList()
    }
    
    func addNewLayer(layer: Layer) {
        selectedLayerIndex = frames[selectedFrameIndex].layers.count - 1
        frames[selectedFrameIndex].layers.insert(layer, at: selectedLayerIndex + 1)
        reloadLayerList()
    }
    
    func deleteSelectedLayer() {
        if frames[selectedFrameIndex].layers.count > 1 {
            frames[selectedFrameIndex].layers.remove(at: selectedLayerIndex)
            selectedLayerIndex -= 1
        } else {
            frames[selectedFrameIndex].layers[0] = Layer(
                gridData: "",
                layerImage: UIImage(named: "empty")!,
                ishidden: false
            )
        }
        reloadPreviewList()
        reloadLayerList()
    }
    
    func toggleVisibilitySelectedLayer() {
        let ishidden = frames[selectedFrameIndex].layers[selectedLayerIndex].ishidden
        frames[selectedFrameIndex].layers[selectedLayerIndex].ishidden = !ishidden
        reloadPreviewList()
        reloadLayerList()
    }
}
