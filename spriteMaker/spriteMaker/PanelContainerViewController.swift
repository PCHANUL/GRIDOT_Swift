//
//  ToolBoxViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/03.
//

import UIKit

class PanelContainerViewController: UIViewController {
    @IBOutlet weak var panelCollectionView: UICollectionView!
    
    // view models
    var viewModel: PreviewListViewModel!
    var animatedPreviewViewModel: AnimatedPreviewViewModel!
    
    // props
    var canvas: Canvas!
    var previewListRect: UIView!
    
    // tool cells
    var previewImageToolBar: PreviewListCollectionViewCell!
    var colorPickerToolBar: ColorPickerCollectionViewCell!
    var drawingToolBar: DrawingToolCollectionViewCell!
    
    // values
    var isInit: Bool = true
    var orderOfTools: [Int] = [0, 1, 2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 순서 변경을 위한 제스쳐
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        panelCollectionView.addGestureRecognizer(gesture)
    }

    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let collectionView = panelCollectionView
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            collectionView?.beginInteractiveMovementForItem(at: targetIndexPath)
            collectionView?.cellForItem(at: targetIndexPath)?.alpha = 0.5
        case .changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView?.endInteractiveMovement()
            collectionView?.reloadData()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
}

extension PanelContainerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderOfTools.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case orderOfTools[0]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewListCollectionViewCell", for: indexPath) as! PreviewListCollectionViewCell
            
            previewImageToolBar = cell
            pushPreviewReloadMethodsToViewModel()
            
            previewImageToolBar.canvas = canvas
            previewImageToolBar.viewModel = viewModel
            previewImageToolBar.animatedPreviewViewModel = animatedPreviewViewModel
            
            animatedPreviewViewModel.changeAnimatedPreview(isReset: true)
            return previewImageToolBar
        case orderOfTools[1]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPickerCollectionViewCell", for: indexPath) as! ColorPickerCollectionViewCell
            
            cell.canvas = canvas
            cell.viewController = self
            return cell
        case orderOfTools[2]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCollectionViewCell", for: indexPath) as! DrawingToolCollectionViewCell
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func pushPreviewReloadMethodsToViewModel() {
        guard let cell = previewImageToolBar else { return }
        let subtractSelectedCell = { cell.changeSelectedCell(index: cell.selectedCell - 1) }
        let reloadPreviewList = cell.previewImageCollection.reloadData
        let reloadCanvas = cell.updateCanvasData
        
        if isInit {
            viewModel = PreviewListViewModel(reloadCanvas: reloadCanvas, reloadPreviewList: reloadPreviewList, subtractSelectedCell: subtractSelectedCell)
        } else {
            viewModel.reloadPreviewList = reloadPreviewList
            viewModel.reloadRemovedList = {
                subtractSelectedCell()
                reloadCanvas()
                reloadPreviewList()
            }
        }
        animatedPreviewViewModel = AnimatedPreviewViewModel(viewModel: viewModel, targetImageView: previewImageToolBar.animatedPreview)
        isInit = false
    }
}

extension PanelContainerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = panelCollectionView.bounds.width
        let height: CGFloat = panelCollectionView.bounds.width * 0.3
        return CGSize(width: width, height: height)
    }
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let item = orderOfTools.remove(at: sourceIndexPath.row)
        orderOfTools.insert(item, at: destinationIndexPath.row)
        panelCollectionView.reloadData()
    }
}





