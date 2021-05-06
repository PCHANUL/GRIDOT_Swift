//
//  LayerListViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/07.
//

import UIKit

class LayerListViewModel {
    var comLayers: [CompositionLayer] = []
    var selectedLayer: Int = 0
    var previewAndLayerCVC: PreviewAndLayerCollectionViewCell!
    
    init(_ cell: PreviewAndLayerCollectionViewCell) {
        previewAndLayerCVC = cell
    }
    
    
    var selectedLayerItem: CompositionLayer {
        return comLayers[selectedLayer]
    }
    
    func changeSelectedLayer(index: Int) {
        selectedLayer = index
    }
    
    func reloadLayerList() {
        let layerCell = previewAndLayerCVC.layerListCell
        layerCell.layerCollection.reloadData()
    }
    
    func initItem(comLayer: CompositionLayer) {
        comLayers.insert(comLayer, at: 0)
        reloadLayerList()
    }
    
    func insertComLayer() {
        comLayers.insert(selectedLayerItem, at:selectedLayer)
        selectedLayer += 1
        reloadLayerList()
    }
    
}

struct CompositionLayer {
    let Layers: [Layer]
}

struct Layer {
    let layerImage: UIImage
    let canvasData: String
}
