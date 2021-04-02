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
    
    // values
    var isInit: Bool = true
    var orderOfTools: [Int] = [0, 1]
    
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
        default:
            return UICollectionViewCell()
        }
    }
    
    func pushPreviewReloadMethodsToViewModel() {
        guard let cell = previewImageToolBar else { return }
        let reloadPreviewList = cell.previewImageCollection.reloadData
        let reloadCanvas = cell.updateCanvasData
        let subtractSelectedCell = { cell.changeSelectedCell(index: cell.selectedCell - 1) }
        
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

class ColorPickerCell: UICollectionViewCell {
    
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

class PreviewListViewModel {
    private var items: [PreviewImage] = []
    var reloadPreviewList: () -> ()
    var reloadRemovedList: () -> ()
    
    init(reloadCanvas: @escaping () -> (), reloadPreviewList: @escaping () -> (), subtractSelectedCell: @escaping () -> ()) {
        self.reloadPreviewList = reloadPreviewList
        self.reloadRemovedList = {
            subtractSelectedCell()
            reloadCanvas()
            reloadPreviewList()
        }
    }
    
    var numsOfItems: Int {
        return items.count
    }
    
    func checkExist(at index: Int) -> Bool {
        return index + 1 <= self.numsOfItems
    }
    
    func addItem(previewImage: PreviewImage, selectedIndex: Int) {
        items.insert(previewImage, at: selectedIndex)
        reloadPreviewList()
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
        reloadPreviewList()
    }
    
    func removeItem(at index: Int) -> PreviewImage {
        if numsOfItems == 1 { return item(at: 0) }
        let item = items.remove(at: index)
        reloadRemovedList()
        return item
    }
}

class AnimatedPreviewViewModel {
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
            targetImageView.layer.backgroundColor = UIColor.white.cgColor
        } else {
            images = viewModel.getCategoryImages(category: curCategory)
            targetImageView.layer.backgroundColor = categoryList.getCategoryColor(category: curCategory).cgColor
        }
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(images.count)
        targetImageView.startAnimating()
    }
}

