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

class PreviewAndLayerCollectionViewCell: UICollectionViewCell {
    var canvas: Canvas!
    var panelContainerVC: PanelContainerViewController!
    var panelCollectionView: UICollectionView!
    
    @IBOutlet weak var previewAndLayerCVC: UICollectionView!
    @IBOutlet weak var animatedPreviewUIView: UIView!
    @IBOutlet weak var animatedPreview: UIImageView!
    @IBOutlet weak var goDownView: UIView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var changeStatusToggle: UISegmentedControl!
    
    // cells
    var previewListCell = PreviewListCollectionViewCell()
    var layerListCell = LayerListCollectionViewCell()
    
    // viewModels
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var previewVM: PreviewListViewModel!
    var layerVM: LayerListViewModel!
    
    // constraints
    var downAnchor: NSLayoutConstraint!
    var upAnchor: NSLayoutConstraint!
    
    // values
    var isScroll: Bool!
    var selectedBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setViewShadow(target: animatedPreview, radius: 5, opacity: 0.3)
    }
    
    override func layoutSubviews() {
        isScroll = false
        panelCollectionView = panelContainerVC.panelCollectionView
        
        if previewVM.numsOfItems == 0 && layerVM.numsOfLayer == 0 {
            canvas.updateViewModelImages(0, isInit: true)
        }
    }
    
    @IBAction func tappedAnimate(_ sender: Any) {
        let categoryPopupVC = UIStoryboard(name: "AnimatedPreviewPopupViewController", bundle: nil).instantiateViewController(identifier: "AnimatedPreviewPopupViewController") as! AnimatedPreviewPopupViewController
        categoryPopupVC.categorys = previewVM.getCategorys()
        categoryPopupVC.animatedPreviewVM = animatedPreviewVM
        categoryPopupVC.positionY = self.frame.maxY - animatedPreview.frame.maxY - 10 - panelCollectionView.contentOffset.y
        categoryPopupVC.modalPresentationStyle = .overFullScreen
        self.window?.rootViewController?.present(categoryPopupVC, animated: false, completion: nil)
    }
    
    @IBAction func changedToggleStatus(_ sender: Any) {
        let maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        switch changeStatusToggle.selectedSegmentIndex {
        case 0:
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        case 1:
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
        default:
            return
        }
    }
}


extension PreviewAndLayerCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewListCollectionViewCell", for: indexPath) as! PreviewListCollectionViewCell
            cell.canvas = canvas
            cell.previewVM = previewVM
            cell.layerListVM = layerVM
            cell.animatedPreviewVM = animatedPreviewVM
            cell.panelCollectionView = panelCollectionView
            cell.animatedPreview = animatedPreview
            cell.previewAndLayerCVC = self
            previewListCell = cell
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayerListCollectionViewCell", for: indexPath) as! LayerListCollectionViewCell
            cell.canvas = canvas
            cell.layerVM = layerVM
            cell.panelCV = panelContainerVC
            layerListCell = cell
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

extension PreviewAndLayerCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let panelCVWidth = panelContainerVC.superViewController.panelContainerView.frame.width
        let animatedImageWidth = animatedPreview.frame.width
        let width: CGFloat = panelCVWidth - animatedImageWidth - 17
        let height = previewAndLayerCVC.frame.height * 0.9
        return CGSize(width: width, height: height)
    }
}

extension PreviewAndLayerCollectionViewCell: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        if previewAndLayerCVC.contentOffset.y < maxYoffset / 3 {
            changeStatusToggle.selectedSegmentIndex = 0
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else {
            changeStatusToggle.selectedSegmentIndex = 1
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        if previewAndLayerCVC.contentOffset.y < maxYoffset / 3 {
            changeStatusToggle.selectedSegmentIndex = 0
        } else {
            changeStatusToggle.selectedSegmentIndex = 1
        }
    }
}
