//
//  LayerListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/07.
//

import UIKit

class LayerListViewModel {
    var items: [CompositionLayer] = []
    var selectedItemIndex: Int = 0
    var selectedLayerIndex: Int = 0
    var previewAndLayerCVC: PreviewAndLayerCollectionViewCell!
    
    init(_ cell: PreviewAndLayerCollectionViewCell?) {
        previewAndLayerCVC = cell
    }
    
    // item methods
    var selectedItem: CompositionLayer? {
        if (items.count == 0) { return nil }
        return items[selectedItemIndex]
    }
    
    func changeselectedItemIndex(index: Int) {
        selectedItemIndex = index
    }
    
    func reloadLayerList() {
        guard let layerCell = previewAndLayerCVC else { return }
        guard let collection = layerCell.layerListCell.layerCollection else { return }
        collection.reloadData()
    }
    
    func addEmptyItem(isInit: Bool) {
        guard let image = UIImage(named: "empty") else { return }
        let item = CompositionLayer(layers: [ Layer(layerImage: image, gridData: "", ishidden: false) ])
        if isInit {
            items.append(item)
            reloadLayerList()
        } else {
            insertItem(at: selectedItemIndex + 1, item)
        }
    }
    
    func copyPreItem() {
        items.insert(selectedItem!, at: selectedItemIndex)
        selectedItemIndex += 1
        reloadLayerList()
    }
    
    func reorderItem(dst: Int, src: Int) {
        let item = items.remove(at: src)
        items.insert(item, at: dst)
        selectedItemIndex = dst
        selectedLayerIndex = 0
        reloadLayerList()
    }
    
    func insertItem(at index: Int, _ item: CompositionLayer) {
        items.insert(item, at: index)
        selectedItemIndex += 1
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
    
    func isExistLayer(index: Int) -> Bool {
        if selectedItem != nil {
            return selectedItem!.layers.count >= index
        } else {
            return false
        }
    }
    
    func reorderLayer(dst: Int, src: Int) {
        let layer = items[selectedItemIndex].layers.remove(at: src)
        items[selectedItemIndex].layers.insert(layer, at: dst)
        selectedLayerIndex = dst
        previewAndLayerCVC.previewVM.reloadRemovedList()
        previewAndLayerCVC.canvas.setNeedsDisplay()
        reloadLayerList()
    }
    
    func getLayer(index: Int) -> Layer? {
        if (selectedItem?.layers.count)! <= index { return nil }
        return selectedItem?.layers[index] ?? nil
    }
    
    func getVisibleLayerImages() -> [UIImage?] {
        guard let selectedItem = self.selectedItem else { return [] }
        return selectedItem.layers.map { layer in
            if (layer.ishidden) { return nil }
            return layer.layerImage
        }
    }
    
    func updateSelectedLayer(layerImage: UIImage, gridData: String) {
        items[selectedItemIndex].layers[selectedLayerIndex].layerImage = layerImage
        items[selectedItemIndex].layers[selectedLayerIndex].gridData = gridData
        reloadLayerList()
    }
    
    func addNewLayer(layer: Layer) {
        selectedLayerIndex = items[selectedItemIndex].layers.count - 1
        items[selectedItemIndex].layers.insert(layer, at: selectedLayerIndex + 1)
        reloadLayerList()
    }
    
    func deleteSelectedLayer() {
        if items[selectedItemIndex].layers.count > 1 {
            items[selectedItemIndex].layers.remove(at: selectedLayerIndex)
            selectedLayerIndex -= 1
        } else {
            guard let image = UIImage(named: "empty") else { return }
            items[selectedItemIndex].layers[0] = Layer(layerImage: image, gridData: "", ishidden: false)
        }
        previewAndLayerCVC.previewVM.reloadRemovedList()
        previewAndLayerCVC.canvas.setNeedsDisplay()
        reloadLayerList()
    }
    
    func toggleVisibilitySelectedLayer() {
        let ishidden = items[selectedItemIndex].layers[selectedLayerIndex].ishidden
        items[selectedItemIndex].layers[selectedLayerIndex].ishidden = !ishidden
        previewAndLayerCVC.previewVM.reloadRemovedList()
        previewAndLayerCVC.canvas.setNeedsDisplay()
        reloadLayerList()
    }
}

struct CompositionLayer {
    var layers: [Layer]
}

struct Layer {
    var layerImage: UIImage
    var gridData: String
    var ishidden: Bool
}
