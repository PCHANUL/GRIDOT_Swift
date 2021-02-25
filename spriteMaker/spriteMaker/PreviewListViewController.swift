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
    var canvas: Canvas!
    var selectedCell = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        case .changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView?.endInteractiveMovement()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
    
    @IBAction func tappedAdd(_ sender: Any) {
        let lastIndex = viewModel.numsOfItems - 1
        let lastItem = viewModel.item(at: lastIndex)
        viewModel.addItem(image: lastItem.image, item: lastItem.imageCanvasData)
        canvas.setNeedsDisplay()
        previewCollectionView.reloadData()
    }
    
    func changeAnimatedPreview() {
        let images = viewModel.getAllImages()
        animatedPreview.animationImages = images
        animatedPreview.animationDuration = 2
        animatedPreview.startAnimating()
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
        
        cell.index = indexPath.item
        return cell
    }
}

extension PreviewListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // [] 셀을 클릭하면 캔버스 화면이 변경된다.
        // - [] 만약에 이전에 선택한 셀과 같은 셀을 선택한다면 선택 옵션팝업을 띄운다.
        // - [] 셀 생성 (배경화면,
        // - [] 셀 제거
        
        // [] 셀을 길게 누르면 순서를 바꿀 수 있도록 활성화된다.
        
        selectedCell = indexPath.item
        let canvasData = viewModel.item(at: indexPath.item).imageCanvasData
        canvas.changeCanvas(index: indexPath.item, canvasData: canvasData)
        
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
    }
}

class PreviewListViewModel {
    private var items: [PreviewImage] = []
    
    var numsOfItems: Int {
        return items.count
    }
    
    func checkExist(at index: Int) -> Bool {
        return index + 1 <= self.numsOfItems
    }
    
    func addItem(image item: UIImage, item imageCanvasData: String) {
        items.append(PreviewImage(image: item, imageCanvasData: imageCanvasData))
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
    }
    
    func removeItem(at index: Int) -> PreviewImage {
        return items.remove(at: index)
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
