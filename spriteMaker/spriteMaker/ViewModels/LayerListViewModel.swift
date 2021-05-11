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
    
    // Item
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
    
    func initItem(comLayer: CompositionLayer) {
        items.insert(comLayer, at: 0)
        reloadLayerList()
    }
    
    func copyPreItem()
    {
        items.insert(selectedItem!, at: selectedItemIndex)
        selectedItemIndex += 1
        reloadLayerList()
    }
    
    func insertItem(item: CompositionLayer) {
        items.insert(item, at:selectedItemIndex)
        selectedItemIndex += 1
        print(items)
        reloadLayerList()
    }
    
    // layer
    var numsOfLayer: Int {
        if selectedItem != nil {
            return selectedItem!.Layers.count
        } else {
            return 0
        }
    }
    
    var selectedLayer: Layer? {
        if selectedItem != nil {
            return selectedItem!.Layers[selectedLayerIndex]
        }
        return nil
    }
    
    func isExistLayer(index: Int) -> Bool {
        if selectedItem != nil {
            return selectedItem!.Layers.count >= index
        } else {
            return false
        }
    }
    
    func getLayer(index: Int) -> Layer? {
        return selectedItem?.Layers[index] ?? nil
    }
    
    func getAllLayerImages() -> [UIImage?] {
        let layers = self.selectedItem!.Layers
        return layers.map { layer in
            return layer.layerImage ?? nil
        }
    }
    
    func updateSelectedLayer(layerImage: UIImage, gridData: String) {
        items[selectedItemIndex].Layers[selectedLayerIndex].layerImage = layerImage
        items[selectedItemIndex].Layers[selectedLayerIndex].gridData = gridData
        reloadLayerList()
    }
    
    func addNewLayer(layer: Layer) {
        items[selectedItemIndex].Layers.insert(layer, at: selectedLayerIndex + 1)
        reloadLayerList()
    }
}

struct CompositionLayer {
    var Layers: [Layer]
}

struct Layer {
    var layerImage: UIImage?
    var gridData: String?
}
