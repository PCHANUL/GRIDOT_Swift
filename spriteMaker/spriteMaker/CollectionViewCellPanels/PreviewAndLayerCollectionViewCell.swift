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
    @IBOutlet weak var goDownBtn: UIButton!
    @IBOutlet weak var superView: UIView!
    
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
    
    // value
    var isScroll: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // set view style
        setViewShadow(target: animatedPreview, radius: 5, opacity: 0.3)
        setOneSideCorner(target: goDownBtn, side: "top")
        setViewShadow(target: goDownBtn, radius: 3, opacity: 0.4)
        
        // set contraints
        downAnchor = goDownBtn.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0)
        upAnchor = goDownBtn.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0)
        downAnchor.priority = UILayoutPriority(500)
        upAnchor.priority = UILayoutPriority(500)
    }
    
    override func layoutSubviews() {
        isScroll = false
        panelCollectionView = panelContainerVC.panelCollectionView
        
        // init preview image
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
    
    @IBAction func scrollDown(_ sender: Any) {
        goDownView.isHidden = true
        setContentOffset()
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
            cell.layerCollection.layer.borderWidth = 0.5
            cell.layerCollection.layer.borderColor = UIColor.white.cgColor
            layerListCell = cell
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

extension PreviewAndLayerCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = previewAndLayerCVC.bounds.width
        let height = previewAndLayerCVC.bounds.height * 0.8
        return CGSize(width: width, height: height)
    }
}

extension PreviewAndLayerCollectionViewCell: UICollectionViewDelegate {
    
    // set scroll position
    func setContentOffset() {
        let maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        if previewAndLayerCVC.contentOffset.y < maxYoffset / 3 {
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
        } else {
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // change UI
    func setArrowImage() {
        if previewAndLayerCVC.contentOffset.y == 0 {
            goDownBtn.imageView!.image = UIImage(systemName: "arrow.down")
            goDownBtn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            downAnchor.isActive = true
            upAnchor.isActive = false
        } else {
            goDownBtn.imageView!.image = UIImage(systemName: "arrow.up")
            goDownBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            downAnchor.isActive = false
            upAnchor.isActive = true
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        goDownView.isHidden = true
        isScroll = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        setContentOffset()
        isScroll = false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if !isScroll {
            setArrowImage()
            goDownView.isHidden = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setArrowImage()
        goDownView.isHidden = false
        isScroll = false
    }
}
