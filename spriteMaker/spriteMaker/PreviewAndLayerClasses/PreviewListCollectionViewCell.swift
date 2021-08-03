//
//  PreviewListCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/06.
//

import UIKit

class PreviewListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var previewImageCollection: UICollectionView!
    
    var canvas: Canvas!
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var layerVM: LayerListViewModel!
    var panelCollectionView: UICollectionView!
    var animatedPreview: UIImageView!
    var previewAndLayerCVC: PreviewAndLayerCollectionViewCell!
    
    let categoryListVM = CategoryListViewModel()
    var cellWidth: CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add gesture
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        previewImageCollection.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let collectionView = previewImageCollection

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
            updateCanvasData()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
    
    func reloadPreviewListItems() {
        self.previewImageCollection.reloadData()
        updateCanvasData()
    }
    
    func updateCanvasData() {
        guard let layer = layerVM.selectedLayer else { return }
        let gridData = layer.gridData
        canvas.changeGrid(index: layerVM.selectedLayerIndex, gridData: gridData)
        canvas.setNeedsDisplay()
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layerVM.numsOfFrames + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case layerVM.numsOfFrames:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddFrameCell", for: indexPath) as? AddFrameCell else {
                return UICollectionViewCell()
            }
            cell.previewListCVC = self
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
                return UICollectionViewCell()
            }
            guard let previewItem = layerVM.getFrame(at: indexPath.row) else { return UICollectionViewCell() }
            cell.updatePreview(frame: previewItem, index: indexPath.row)

            let categoryIndex = categoryListVM.indexOfCategory(name: previewItem.category)
            cell.categoryColor.layer.backgroundColor = categoryListVM.item(at: categoryIndex).color.cgColor
            cell.previewImage.layer.borderWidth = indexPath.item == layerVM.selectedFrameIndex ? 1 : 0
            cell.previewImage.layer.borderColor = UIColor.white.cgColor
            
            cellWidth = cell.bounds.width
            cell.index = indexPath.item
            return cell
        }
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rect = self.previewImageCollection.cellForItem(at: indexPath)!.frame
        let scroll = rect.minX - self.previewImageCollection.contentOffset.x
        
        let selectedIndex = layerVM.selectedFrameIndex
        if indexPath.row == selectedIndex {
            let previewOptionPopupVC = UIStoryboard(name: "PreviewPopup", bundle: nil).instantiateViewController(identifier: "PreviewOptionPopupViewController") as! PreviewOptionPopupViewController
            let windowWidth: CGFloat = UIScreen.main.bounds.size.width
            let panelContainerViewController = windowWidth * 0.9
            let margin = (windowWidth - panelContainerViewController) / 2
            
            previewOptionPopupVC.previewListCVC = self
            previewOptionPopupVC.viewModel = self.layerVM
            previewOptionPopupVC.animatedPreviewVM = self.animatedPreviewVM
            previewOptionPopupVC.popupArrowX = animatedPreview.bounds.maxX + margin + scroll + cellWidth / 2
            previewOptionPopupVC.popupPositionY = previewAndLayerCVC.frame.minY - 10 - panelCollectionView.contentOffset.y
            previewOptionPopupVC.modalPresentationStyle = .overFullScreen
            self.window?.rootViewController?.present(previewOptionPopupVC, animated: false, completion: nil)
        } else if (indexPath.row < layerVM.numsOfFrames) {
            layerVM.selectedFrameIndex = indexPath.item
            layerVM.selectedLayerIndex = 0
            layerVM.reloadLayerList()
            updateCanvasData()
        }
        previewImageCollection.reloadData()
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = previewImageCollection.bounds.height - 2
        return CGSize(width: sideLength - 5, height: sideLength)
    }
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if (layerVM.reorderFrame(dst: destinationIndexPath.row, src: sourceIndexPath.row)) {
            animatedPreviewVM.changeAnimatedPreview()
            previewImageCollection.setNeedsDisplay()
        }
    }
}

class PreviewCell: UICollectionViewCell {
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var categoryColor: UIView!
    @IBOutlet weak var previewCell: UIView!
    var isSelectedCell: Bool = false
    var index: Int!
    
    override func awakeFromNib() {
        setViewShadow(target: self, radius: 2, opacity: 0.5)
    }
    
    func updatePreview(frame: Frame, index: Int) {
        previewImage.image = frame.renderedImage
        self.index = index
    }
}

class AddFrameCell: UICollectionViewCell {
    var previewListCVC: PreviewListCollectionViewCell!
    
    override func layoutSubviews() {
        setOneSideCorner(target: self, side: "all", radius: self.frame.width / 7)
        setViewShadow(target: self, radius: 2, opacity: 0.4)
    }
    
    @IBAction func tappedAdd(_ sender: Any) {
        previewListCVC.layerVM.addEmptyFrameNextToSelectedFrame()
        previewListCVC.layerVM.selectedLayerIndex = 0;
        
        let contentX = CGFloat(previewListCVC.layerVM.selectedFrameIndex) * previewListCVC.cellWidth
        previewListCVC.previewImageCollection.contentOffset.x = contentX
        previewListCVC.reloadPreviewListItems()
        previewListCVC.canvas.timeMachineVM.addTime()
    }
}
