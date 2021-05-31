//
//  ToolBoxViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/03.
//

import UIKit

class PanelContainerViewController: UIViewController {
    @IBOutlet weak var panelCollectionView: UICollectionView!
    
    var canvas: Canvas!
    var orderOfTools: [Int] = [0, 1, 2]
    
    // view models
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var previewVM: PreviewListViewModel!
    var layerVM: LayerListViewModel!
    var colorPaletteVM: ColorPaletteListViewModel!
    var drawingToolVM: DrawingToolViewModel!
    
    // view cells
    var previewImageToolBar: PreviewAndLayerCollectionViewCell!
    var colorPickerToolBar: ColorPaletteCollectionViewCell!
    var drawingToolBar: DrawingToolCollectionViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawingToolVM = DrawingToolViewModel()
        previewVM = PreviewListViewModel()
        layerVM = LayerListViewModel()
        animatedPreviewVM = AnimatedPreviewViewModel()
    }
}

extension PanelContainerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderOfTools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case orderOfTools[0]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewAndLayerCollectionViewCell", for: indexPath) as! PreviewAndLayerCollectionViewCell
            
            // init viewModels
            previewVM.previewAndLayerCVC = cell
            layerVM.previewAndLayerCVC = cell
            animatedPreviewVM.targetView = cell.animatedPreviewUIView
            animatedPreviewVM.viewModel = previewVM
            
            previewImageToolBar = cell
            previewImageToolBar.canvas = canvas
            previewImageToolBar.layerVM = layerVM
            previewImageToolBar.previewVM = previewVM
            previewImageToolBar.animatedPreviewVM = animatedPreviewVM
            previewImageToolBar.panelContainerVC = self
            return previewImageToolBar
            
        case orderOfTools[1]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPaletteCollectionViewCell", for: indexPath) as! ColorPaletteCollectionViewCell
            
            // init viewModel
            colorPaletteVM = colorPickerToolBar.colorPaletteViewModel
            
            colorPickerToolBar = cell
            colorPickerToolBar.canvas = canvas
            colorPickerToolBar.viewController = self
            colorPickerToolBar.panelCollectionView = panelCollectionView
            return colorPickerToolBar
            
        case orderOfTools[2]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCollectionViewCell", for: indexPath) as! DrawingToolCollectionViewCell
            
            drawingToolBar = cell
            drawingToolBar.drawingToolViewModel = drawingToolVM
            drawingToolBar.panelCollectionView = panelCollectionView
            return drawingToolBar
            
        default:
            return UICollectionViewCell()
        }
    }
}

extension PanelContainerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = panelCollectionView.bounds.width
        let height: CGFloat = panelCollectionView.bounds.width * 0.3
        return CGSize(width: width, height: height)
    }
}
