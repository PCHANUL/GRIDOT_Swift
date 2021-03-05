//
//  PreviewListCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/04.
//

import UIKit
import ImageIO
import Foundation
import MobileCoreServices

class PreviewListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var animatedPreview: UIImageView!
    @IBOutlet weak var previewImageCollection: UICollectionView!
    
    var canvas: Canvas!
    var previewListRect: UIView!
    
    let categoryList = CategoryList()
    var viewModel: PreviewListViewModel!
    var animatedPreviewClass: AnimatedPreviewClass!
    
    var selectedCell = 0
    var cellWidth: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("preview subviews")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        viewModel.superClassReload = {
//            self.previewImageCollection.reloadData()
//        }
//        viewModel.reload = {
//            self.changeSelectedCell(index: self.selectedCell - 1)
//            self.reloadPreviewListItems()
//        }
        print("preview awake")
        
        
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
        let selectedItem = viewModel.item(at: selectedCell)
        viewModel.addItem(previewImage: selectedItem, selectedIndex: selectedCell)
        selectedCell = selectedCell + 1
        previewImageCollection.contentOffset.x = CGFloat(selectedCell) * cellWidth
        reloadPreviewListItems()
    }
    
    @IBAction func tappedAnimate(_ sender: Any) {
        let categoryPopupVC = UIStoryboard(name: "AnimatedPreviewPopupViewController", bundle: nil).instantiateViewController(identifier: "AnimatedPreviewPopupViewController") as! AnimatedPreviewPopupViewController
        categoryPopupVC.modalPresentationStyle = .overFullScreen
        categoryPopupVC.categorys = viewModel.getCategorys()
        categoryPopupVC.animatedPreviewClass = animatedPreviewClass
        categoryPopupVC.positionY = self.frame.maxY - animatedPreview.frame.maxY
        self.window?.rootViewController?.present(categoryPopupVC, animated: true, completion: nil)
    }
    
    func changeSelectedCell(index: Int) {
        selectedCell = index < 0 ? 0 : index
    }
    
    func reloadPreviewListItems() {
        // reload all data
        print("reload")
        self.previewImageCollection.reloadData()
        updateCanvasData()
        canvas.setNeedsDisplay()
    }
    
    func updateCanvasData() {
        let canvasData = viewModel.item(at: selectedCell).imageCanvasData
        canvas.changeCanvas(index: selectedCell, canvasData: canvasData)
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("previewCell", viewModel.numsOfItems)
        return viewModel.numsOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }

        let preview = viewModel.item(at: indexPath.item)
        cell.updatePreview(item: preview, index: indexPath.item)
        
        let categoryIndex = categoryList.indexOfCategory(name: preview.category)
        cell.contentView.layer.backgroundColor = categoryList.item(at: categoryIndex).color.cgColor
        cell.contentView.layer.borderWidth = indexPath.item == selectedCell ? 2 : 0
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        
        cellWidth = cell.bounds.width
        cell.index = indexPath.item
        return cell
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rect = self.previewImageCollection.cellForItem(at: indexPath)!.frame
        let scroll = rect.minX - self.previewImageCollection.contentOffset.x
        
        if indexPath.row == selectedCell {
            let previewOptionPopupVC = UIStoryboard(name: "PreviewPopup", bundle: nil).instantiateViewController(identifier: "PreviewOptionPopupViewController") as! PreviewOptionPopupViewController
            let margin = (UIScreen.main.bounds.size.width - previewListRect.frame.width) / 2
            
            previewOptionPopupVC.popupArrowX = animatedPreview.bounds.maxX + margin + scroll + cellWidth / 2
            previewOptionPopupVC.selectedCell = self.selectedCell
            previewOptionPopupVC.viewModel = self.viewModel
            previewOptionPopupVC.animatedPreviewClass = self.animatedPreviewClass
            previewOptionPopupVC.popupPositionY = self.frame.maxY - animatedPreview.frame.maxY
            previewOptionPopupVC.modalPresentationStyle = .overFullScreen
            self.window?.rootViewController?.present(previewOptionPopupVC, animated: true, completion: nil)
        }
        selectedCell = indexPath.item
        updateCanvasData()
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = animatedPreview.bounds.height
        return CGSize(width: sideLength, height: sideLength)
    }
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = viewModel.removeItem(at: sourceIndexPath.row)
        viewModel.insertItem(at: destinationIndexPath.row, item)
        selectedCell = destinationIndexPath.row
        animatedPreviewClass.changeAnimatedPreview(isReset: false)
    }
}

class AnimatedPreviewClass {
    var targetImageView: UIImageView!
    let categoryList = CategoryList()
    var curCategory: String = ""
    var viewModel: PreviewListViewModel!
    
    init(viewModel: PreviewListViewModel, targetImageView: UIImageView) {
        self.viewModel = viewModel
        self.targetImageView = targetImageView
    }
    
    func changeSelectedCategory(category: String) {
        curCategory = category
    }
    
    func changeAnimatedPreview(isReset: Bool) {
        let images: [UIImage]
        if isReset { curCategory = "" }
        if curCategory == "" {
            images = viewModel.getAllImages()
            targetImageView.layer.backgroundColor = UIColor.lightGray.cgColor
        } else {
            images = viewModel.getCategoryImages(category: curCategory)
            targetImageView.layer.backgroundColor = categoryList.getCategoryColor(category: curCategory).cgColor
        }
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(images.count)
        targetImageView.startAnimating()
    }
}

class PreviewCell: UICollectionViewCell {
    @IBOutlet weak var previewCell: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    
    var index: Int!
    var isSelectedCell: Bool = false
    
    func updatePreview(item: PreviewImage, index: Int) {
        previewImage.image = item.image
        self.index = index
    }
}

struct PreviewImage {
    let image: UIImage
    let category: String
    let imageCanvasData: String
}

