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
    
    init(_ cell: PreviewAndLayerCollectionViewCell) {
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
        let layerCell = previewAndLayerCVC.layerListCell
        layerCell.layerCollection.reloadData()
    }
    
    func initItem(comLayer: CompositionLayer) {
        items.insert(comLayer, at: 0)
        reloadLayerList()
    }
    
    func insertItem(item: CompositionLayer) {
        items.insert(item, at:selectedItemIndex)
        selectedItemIndex += 1
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
            return nil
        }
        return selectedItem!.Layers[selectedLayerIndex]
    }
    
    func updateSelectedLayer(layerImage: UIImage, gridData: String) {
        items[selectedItemIndex].Layers[selectedLayerIndex].layerImage = layerImage
        items[selectedItemIndex].Layers[selectedLayerIndex].gridData = gridData
    }
    
    func addNewLayer(layerImage: UIImage, gridData: String) {
        let newLayer = Layer(layerImage: layerImage, gridData: gridData)
        items[selectedItemIndex].Layers.insert(newLayer, at: selectedLayerIndex + 1)
    }
}

struct CompositionLayer {
    var Layers: [Layer]
}

struct Layer {
    var layerImage: UIImage
    var gridData: String
}
