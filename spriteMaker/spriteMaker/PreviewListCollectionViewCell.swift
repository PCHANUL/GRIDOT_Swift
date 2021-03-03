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
    
    var view: UIView!
    
    @IBOutlet weak var animatedPreview: UIImageView!
    @IBOutlet weak var previewImageCollection: UICollectionView!
    
    let viewModel = PreviewListViewModel()
    let categoryList = CategoryList()
    var previewListRect: UIView!
    var canvas: Canvas!
    var selectedCell = 0
    var cellWidth: CGFloat!
    
    var animatedPreviewClass = AnimatedPreviewClass()
    
//    init() {
//        self.animatedPreviewClass = AnimatedPreviewClass(getCategoryImages: viewModel.getCategoryImages, getAllImages: viewModel.getAllImages)
//        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    func viewDidLoad() {
        animatedPreviewClass.viewModel = viewModel
        animatedPreviewClass.targetImageView = animatedPreview
        viewModel.superClassReload = {
            self.previewImageCollection.reloadData()
        }
        viewModel.reload = {
            self.changeSelectedCell(index: self.selectedCell - 1)
            self.reloadPreviewListItems()
        }
//        animatedPreviewClass = .init(targetImageView: animatedPreview, getCategoryImages: viewModel.getCategoryImages, getAllImages: viewModel.getAllImages)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        previewImageCollection.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let collectionView = previewImageCollection
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
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
        let popupVC = UIStoryboard(name: "AnimatedPreviewPopupViewController", bundle: nil).instantiateViewController(identifier: "AnimatedPreviewPopupViewController") as! AnimatedPreviewPopupViewController
        
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.categorys = viewModel.getCategorys()
        popupVC.animatedPreviewClass = animatedPreviewClass
        self.window?.rootViewController?.present(popupVC, animated: true, completion: nil)
    }
    
    func changeSelectedCell(index: Int) {
        selectedCell = index < 0 ? 0 : index
    }
    
    func reloadPreviewListItems() {
        // reload all data
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
        print(viewModel.numsOfItems)
        return viewModel.numsOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }
        
        let preview = viewModel.item(at: indexPath.item)
        cell.updatePreview(item: preview, index: indexPath.item)
        
        let categoryIndex = categoryList.indexOfCategory(name: preview.category)
        cell.contentView.backgroundColor = categoryList.item(at: categoryIndex).color
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
            let popupVC = UIStoryboard(name: "PreviewPopup", bundle: nil).instantiateViewController(identifier: "PreviewOptionPopupViewController") as! PreviewOptionPopupViewController
            let margin = (UIScreen.main.bounds.size.width - previewListRect.frame.width) / 2
            popupVC.popupArrorX = animatedPreview.bounds.maxX + margin + scroll + cellWidth / 2
            popupVC.popupRectY = previewListRect.bounds.height + previewListRect.bounds.height * 0.4
            popupVC.modalPresentationStyle = .overFullScreen
            
            popupVC.selectedCell = self.selectedCell
            popupVC.viewModel = self.viewModel
            popupVC.animatedPreviewClass = self.animatedPreviewClass
            self.window?.rootViewController?.present(popupVC, animated: true, completion: nil)
        }
        selectedCell = indexPath.item
        updateCanvasData()
    }
}

extension PreviewListCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = view.bounds.height
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
        animatedPreviewClass.changeSelectedCategory(category: item.category)
        animatedPreviewClass.changeAnimatedPreview(isReset: false)
    }
}

class AnimatedPreviewClass {
    var targetImageView = UIImageView()
//    var getCategoryImages: (_ category: String) -> [UIImage]
//    var getAllImages: () -> [UIImage]
    
    let categoryList = CategoryList()
    var curCategory: String = ""
    var viewModel = PreviewListViewModel()
    
//    init(getCategoryImages: @escaping (_ category: String) -> [UIImage], getAllImages: @escaping () -> [UIImage]) {
//        self.getCategoryImages = getCategoryImages
//        self.getAllImages = getAllImages
//    }
    
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

class PreviewListViewModel {
    private var items: [PreviewImage] = []
    var superClassReload: () -> ()
    var reload: () -> ()
    init() {
        superClassReload = { return }
        reload = { return }
    }
    
    var numsOfItems: Int {
        return items.count
    }
    
    func checkExist(at index: Int) -> Bool {
        return index + 1 <= self.numsOfItems
    }
    
    func addItem(previewImage: PreviewImage, selectedIndex: Int) {
        items.insert(previewImage, at: selectedIndex)
        superClassReload()
    }
    
    func insertItem(at index: Int, _ item: PreviewImage) {
        items.insert(item, at: index)
    }
    
    func item(at index: Int) -> PreviewImage {
        return items[index]
    }
    
    func getAllImages() -> [UIImage] {
        let images = items.map { item in
            return item.image
        }
        return images
    }
    
    func getCategorys() -> [String] {
        var categorys: [String] = []
        for item in items {
            if categorys.contains(where: { $0 == item.category }) == false {
                categorys.append(item.category)
            }
        }
        return categorys
    }
    
    func getCategoryImages(category: String) -> [UIImage] {
        var categoryImages: [UIImage] = []
        for item in items {
            if item.category == category {
                categoryImages.append(item.image)
            }
        }
        return categoryImages
    }
    
    func updateItem(at index: Int, previewImage: PreviewImage) {
        items[index] = previewImage
        superClassReload()
    }
    
    func removeItem(at index: Int) -> PreviewImage {
        if numsOfItems == 1 { return item(at: 0) }
        let item = items.remove(at: index)
        reload()
        return item
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

