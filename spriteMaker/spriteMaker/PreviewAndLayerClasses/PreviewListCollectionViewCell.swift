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
    var previewVM: PreviewListViewModel!
    var animatedPreviewViewModel: AnimatedPreviewViewModel!
    var panelCollectionView: UICollectionView!
    var animatedPreview: UIImageView!
    var previewAndLayerCVC: UICollectionViewCell!
    
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
    
    @IBAction func tappedAdd(_ sender: Any) {
        canvas.uploadGridDataToPreviewList()
        previewVM.addItem()
        let selectedIndex = previewVM.selectedPreview
        previewImageCollection.contentOffset.x = CGFloat(selectedIndex) * cellWidth
        reloadPreviewListItems()
    }
    
    func reloadPreviewListItems() {
        self.previewImageCollection.reloadData()
        updateCanvasData()
    }
    
    func updateCanvasData() {
        let selectedIndex = previewVM.selectedPreview
        let canvasData = previewVM.selectedCellItem.imageCanvasData
        canvas.changeCanvas(index: selectedIndex, canvasData: canvasData)
        canvas.setNeedsDisplay()
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previewVM.numsOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }
        let previewItem = previewVM.item(at: indexPath.row)
        cell.updatePreview(item: previewItem, index: indexPath.row)

        let categoryIndex = categoryListVM.indexOfCategory(name: previewItem.category)
        cell.categoryColor.layer.backgroundColor = categoryListVM.item(at: categoryIndex).color.cgColor
        cell.previewImage.layer.borderWidth = indexPath.item == previewVM.selectedPreview ? 2 : 0
        cell.previewImage.layer.borderColor = UIColor.white.cgColor

        cellWidth = cell.bounds.width
        cell.index = indexPath.item
        return cell
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rect = self.previewImageCollection.cellForItem(at: indexPath)!.frame
        let scroll = rect.minX - self.previewImageCollection.contentOffset.x
        
        let selectedIndex = previewVM.selectedPreview
        if indexPath.row == selectedIndex {
            let previewOptionPopupVC = UIStoryboard(name: "PreviewPopup", bundle: nil).instantiateViewController(identifier: "PreviewOptionPopupViewController") as! PreviewOptionPopupViewController
            let windowWidth: CGFloat = UIScreen.main.bounds.size.width
            let panelContainerViewController = windowWidth * 0.9
            let margin = (windowWidth - panelContainerViewController) / 2
            
            previewOptionPopupVC.viewModel = self.previewVM
            previewOptionPopupVC.animatedPreviewViewModel = self.animatedPreviewViewModel
            previewOptionPopupVC.popupArrowX = animatedPreview.bounds.maxX + margin + scroll + cellWidth / 2
            previewOptionPopupVC.popupPositionY = previewAndLayerCVC.frame.minY - 10 - panelCollectionView.contentOffset.y
            previewOptionPopupVC.modalPresentationStyle = .overFullScreen
            self.window?.rootViewController?.present(previewOptionPopupVC, animated: true, completion: nil)
        }
        previewVM.selectedPreview = indexPath.item
        updateCanvasData()
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = previewImageCollection.bounds.height
        return CGSize(width: sideLength - 5, height: sideLength)
    }
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = previewVM.removeItem(at: sourceIndexPath.row)
        previewVM.insertItem(at: destinationIndexPath.row, item)
        previewVM.selectedPreview = destinationIndexPath.row
        animatedPreviewViewModel.changeAnimatedPreview(isReset: false)
        previewImageCollection.setNeedsDisplay()
    }
}

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var categoryColor: UIView!
    @IBOutlet weak var previewCell: UIView!
    
    var index: Int!
    var isSelectedCell: Bool = false
    
    func updatePreview(item: PreviewImage, index: Int) {
        previewImage.image = item.image
        self.index = index
    }
}
