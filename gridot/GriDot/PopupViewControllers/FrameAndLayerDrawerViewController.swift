//
//  FrameAndLayerDrawerViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/24.
//

import UIKit

class FrameAndLayerDrawerViewController: UIViewController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var drawerCV: UICollectionView!
    @IBOutlet weak var drawerView: UIView!
    var selectedSegment: String!
    var itemHeight: CGFloat!
    var itemNums: Int!
    
    var layerVM: LayerListViewModel!
    var categoryVM = CategoryListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var selectedIndexPath = IndexPath(row: 0, section: 0)
        itemNums = selectedSegment == "Frame" ? layerVM.numsOfFrames : layerVM.numsOfLayer
        if (selectedSegment == "Frame") {
            itemNums = layerVM.numsOfFrames
            selectedIndexPath.row = layerVM.selectedFrameIndex
        } else {
            itemNums = layerVM.numsOfLayer
            selectedIndexPath.row = layerVM.selectedLayerIndex
        }
        DispatchQueue.main.async {
            self.drawerCV.scrollToItem(at: selectedIndexPath, at: .top, animated: true)
        }
        setSideCorner(target: drawerView, side: "all", radius: drawerView.frame.width / 20)
        setPopupViewShadow(drawerView)
        heightConstraint.constant = 70
        switch itemNums! {
        case 1...4:
            heightConstraint.constant += itemHeight
        case 5...8:
            heightConstraint.constant += itemHeight * 2
            heightConstraint.constant += selectedSegment == "Frame" ? 10 : 0
        default:
            heightConstraint.constant += itemHeight * 2.5
        }
    }
    
    @IBAction func tappedBackGround(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

extension FrameAndLayerDrawerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemNums
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawerCell", for: indexPath) as? DrawerCell else { return UICollectionViewCell() }
        setViewShadow(target: cell, radius: 4, opacity: 0.2)
        switch selectedSegment {
        case "Frame":
            let frame = layerVM.getFrame(at: indexPath.row)
            cell.imageView.image = frame?.renderedImage
            cell.categoryLabel.backgroundColor = categoryVM.getCategoryColor(category: frame!.category)
            setSelectedViewOutline(cell, layerVM.selectedFrameIndex == indexPath.row)
        case "Layer":
            let layer = layerVM.getLayer(index: indexPath.row)
            cell.imageView.image = layer?.renderedImage
            setSelectedViewOutline(cell, layerVM.selectedLayerIndex == indexPath.row)
        default:
            return cell
        }
        return cell
    }
}

extension FrameAndLayerDrawerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = itemHeight!
        height += selectedSegment == "Frame" ? 5 : 0
        return CGSize(width: itemHeight, height: height)
    }
}

extension FrameAndLayerDrawerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch selectedSegment {
        case "Frame":
            layerVM.setSelectedFrameIndex(index: indexPath.row)
            layerVM.previewAndLayerCVC?.setOffsetForSelectedFrame()
        case "Layer":
            layerVM.setSelectedLayerIndex(index: indexPath.row)
            layerVM.previewAndLayerCVC?.setOffsetForSelectedLayer()
        default:
            return
        }
        dismiss(animated: false, completion: nil)
    }
}

class DrawerCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryLabel: UIView!
}
