//
//  PreviewListViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/22.
//

import UIKit
import ImageIO
import Foundation
import MobileCoreServices

class PreviewListViewController: UIViewController {
    
    @IBOutlet weak var animatedPreview: UIImageView!
    @IBOutlet weak var previewCollectionView: UICollectionView!
    
    let viewModel = PreviewListViewModel()
    var previewListRect: UIView!
    var canvas: Canvas!
    var selectedCell = 0
    var cellWidth: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.superClass = previewCollectionView
        viewModel.reload = {
            self.changeSelectedCell(index: self.selectedCell - 1)
            self.reloadPreviewListItems()
        }
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        previewCollectionView.addGestureRecognizer(gesture)
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let collectionView = previewCollectionView
        
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
        let lastIndex = viewModel.numsOfItems - 1
        let lastItem = viewModel.item(at: lastIndex)
        viewModel.addItem(image: lastItem.image, item: lastItem.imageCanvasData)
        selectedCell = viewModel.numsOfItems - 1
        previewCollectionView.contentOffset.x = CGFloat(viewModel.numsOfItems) * cellWidth
        reloadPreviewListItems()
    }
    
    func changeSelectedCell(index: Int) {
        selectedCell = index < 0 ? 0 : index
    }
    
    func reloadPreviewListItems() {
        // reload all data
        previewCollectionView.reloadData()
        updateCanvasData()
        canvas.setNeedsDisplay()
    }
    
    func changeAnimatedPreview() {
        let images = viewModel.getAllImages()
        animatedPreview.animationImages = images
        animatedPreview.animationDuration = TimeInterval(images.count)
        animatedPreview.startAnimating()
    }
    
    func updateCanvasData() {
        let canvasData = viewModel.item(at: selectedCell).imageCanvasData
        canvas.changeCanvas(index: selectedCell, canvasData: canvasData)
    }
}

extension PreviewListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numsOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }
        
        let preview = viewModel.item(at: indexPath.item)
        cell.updatePreview(item: preview, index: indexPath.item)
        
        if  indexPath.item == selectedCell {
            cell.contentView.layer.borderWidth = 2
            cell.contentView.layer.borderColor = UIColor.white.cgColor
        } else {
            cell.contentView.layer.borderWidth = 0
        }
        
        cellWidth = cell.bounds.width
        cell.index = indexPath.item
        return cell
    }
}

extension PreviewListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // [] 셀을 클릭하면 캔버스 화면이 변경된다.
        // - [x] 만약에 이전에 선택한 셀과 같은 셀을 선택한다면 선택 옵션팝업을 띄운다.
        // - [] 셀 생성 (배경화면,
        // - [] 셀 제거
        
        let rect = previewCollectionView.cellForItem(at: indexPath)!.frame
        let scroll = rect.minX - previewCollectionView.contentOffset.x
        
        if indexPath.row == selectedCell {
            let popupVC = UIStoryboard(name: "PreviewPopup", bundle: nil).instantiateViewController(identifier: "PreviewOptionPopupViewController") as! PreviewOptionPopupViewController
            let margin = (UIScreen.main.bounds.size.width - previewListRect.frame.width) / 2
            popupVC.popupArrorX = animatedPreview.bounds.maxX + margin + scroll + cellWidth / 2
            popupVC.popupRectY = previewListRect.bounds.height + previewListRect.bounds.height * 0.4
            popupVC.modalPresentationStyle = .overFullScreen
            
            popupVC.selectedCell = self.selectedCell
            popupVC.viewModel = self.viewModel
            present(popupVC, animated: true, completion: nil)
        }
        
        selectedCell = indexPath.item
        updateCanvasData()
    }
}

extension PreviewListViewController: UICollectionViewDelegateFlowLayout {
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
        changeAnimatedPreview()
    }
}

class PreviewListViewModel {
    private var items: [PreviewImage] = []
    var superClass: UICollectionView!
    var reload: () -> ()
    init() {
        reload = { return }
    }
    
    var numsOfItems: Int {
        return items.count
    }
    
    func checkExist(at index: Int) -> Bool {
        return index + 1 <= self.numsOfItems
    }
    
    func addItem(image item: UIImage, item imageCanvasData: String) {
        items.append(PreviewImage(image: item, imageCanvasData: imageCanvasData))
        superClass.reloadData()
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
    
    func updateItem(at index: Int, image item: UIImage, item imageCanvasData: String) {
        items[index] = PreviewImage(image: item, imageCanvasData: imageCanvasData)
        superClass.reloadData()
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
    let imageCanvasData: String
}


