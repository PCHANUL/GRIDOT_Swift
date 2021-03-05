//
//  ToolBoxViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/03.
//

import UIKit

class ToolBoxViewController: UIViewController {
    @IBOutlet weak var toolCollectionView: UICollectionView!
    
    var previewImageToolBar: PreviewListCollectionViewCell!
    var colorPickerToolBar: ColorPickerCollectionViewCell!
    
    var viewModel = PreviewListViewModel()
    var orderOfTools: [Int] = [0, 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        toolCollectionView.addGestureRecognizer(gesture)
    }

    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let collectionView = toolCollectionView
        
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

extension ToolBoxViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case orderOfTools[0]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewListCollectionViewCell", for: indexPath) as! PreviewListCollectionViewCell
            previewImageToolBar = cell
            previewImageToolBar.viewModel = viewModel
            return previewImageToolBar
        case orderOfTools[1]:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPickerCell", for: indexPath) as! ColorPickerCell
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

class ColorPickerCell: UICollectionViewCell {
    @IBOutlet weak var superView: UIView!
    
}

extension ToolBoxViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = toolCollectionView.bounds.width
        let height: CGFloat = toolCollectionView.bounds.width * 0.3
        return CGSize(width: width, height: height)
    }
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // 아이템 배열 정리
        
        let item = orderOfTools.remove(at: sourceIndexPath.row)
        orderOfTools.insert(item, at: destinationIndexPath.row)
        print(destinationIndexPath.row, orderOfTools)
        toolCollectionView.reloadData()
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

