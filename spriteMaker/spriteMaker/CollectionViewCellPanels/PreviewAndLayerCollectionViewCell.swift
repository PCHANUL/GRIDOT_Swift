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
    @IBOutlet weak var frameBtn: UIButton!
    @IBOutlet weak var layerBtn: UIButton!
    @IBOutlet weak var frameBtnLabel: UILabel!
    @IBOutlet weak var layerBtnLabel: UILabel!
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
        
        setOneSideCorner(target: layerBtn, side: "top", radius: layerBtn.bounds.height / 3)
        setOneSideCorner(target: frameBtn, side: "top", radius: frameBtn.bounds.height / 3)
        setViewShadow(target: frameBtn, radius: 3, opacity: 0.4)
    }
    
    @IBAction func tappedAnimate(_ sender: Any) {
        let categoryPopupVC = UIStoryboard(name: "AnimatedPreviewPopupViewController", bundle: nil).instantiateViewController(identifier: "AnimatedPreviewPopupViewController") as! AnimatedPreviewPopupViewController
        categoryPopupVC.categorys = previewVM.getCategorys()
        categoryPopupVC.animatedPreviewVM = animatedPreviewVM
        categoryPopupVC.positionY = self.frame.maxY - animatedPreview.frame.maxY - 10 - panelCollectionView.contentOffset.y
        categoryPopupVC.modalPresentationStyle = .overFullScreen
        self.window?.rootViewController?.present(categoryPopupVC, animated: false, completion: nil)
    }
    
    @IBAction func tappedFrameBtn(_ sender: UIButton) {
        let maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        switch sender {
        case frameBtn:
            changeSelectedBtn("Frame")
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        case layerBtn:
            changeSelectedBtn("Layer")
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
        default:
            return
        }
    }
    
    func changeSelectedBtn(_ btnTitle: String) {
        switch btnTitle {
        case "Frame":
            frameBtnLabel.textColor = UIColor.white
            layerBtnLabel.textColor = UIColor.gray
            setViewShadow(target: frameBtn, radius: 3, opacity: 0.4)
            setViewShadow(target: layerBtn, radius: 3, opacity: 0)
        case "Layer":
            frameBtnLabel.textColor = UIColor.gray
            layerBtnLabel.textColor = UIColor.white
            setViewShadow(target: layerBtn, radius: 3, opacity: 0.4)
            setViewShadow(target: frameBtn, radius: 3, opacity: 0)
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
        let width: CGFloat = panelCVWidth - animatedImageWidth - 12
        let height = previewAndLayerCVC.frame.height * 0.9
        return CGSize(width: width, height: height)
    }
}

extension PreviewAndLayerCollectionViewCell: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        if previewAndLayerCVC.contentOffset.y < maxYoffset / 3 {
            changeSelectedBtn("Frame")
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else {
            changeSelectedBtn("Layer")
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        if previewAndLayerCVC.contentOffset.y < maxYoffset / 3 {
            changeSelectedBtn("Frame")
        } else {
            changeSelectedBtn("Layer")
        }
    }
}
