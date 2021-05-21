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
    var panelCollectionView: UICollectionView!
    
    @IBOutlet weak var previewAndLayerCVC: UICollectionView!
    @IBOutlet weak var animatedPreviewUIView: UIView!
    @IBOutlet weak var animatedPreview: UIImageView!
    @IBOutlet weak var goDownView: UIView!
    @IBOutlet weak var goDownBtn: UIButton!
    
    // cells
    var previewListCell = PreviewListCollectionViewCell()
    var layerListCell = LayerListCollectionViewCell()
    
    // viewModels
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var previewVM: PreviewListViewModel!
    var layerVM: LayerListViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animatedPreview.layer.shadowColor = UIColor.black.cgColor
        animatedPreview.layer.masksToBounds = false
        animatedPreview.layer.shadowOffset = CGSize(width: 0, height: 4)
        animatedPreview.layer.shadowRadius = 5
        animatedPreview.layer.shadowOpacity = 0.3
        
        goDownBtn.clipsToBounds = true
        goDownBtn.layer.cornerRadius = goDownBtn.bounds.height / 3
        goDownBtn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        
    }
    
    override func layoutSubviews() {
        if previewVM.numsOfItems == 0 && layerVM.numsOfLayer == 0 {
            canvas.updateViewModelImages(0, isInit: true)
        }
    }
    
    @IBAction func tappedAnimate(_ sender: Any) {
        let categoryPopupVC = UIStoryboard(name: "AnimatedPreviewPopupViewController", bundle: nil).instantiateViewController(identifier: "AnimatedPreviewPopupViewController") as! AnimatedPreviewPopupViewController
        categoryPopupVC.modalPresentationStyle = .overFullScreen
        categoryPopupVC.categorys = previewVM.getCategorys()
        categoryPopupVC.animatedPreviewVM = animatedPreviewVM
        categoryPopupVC.positionY = self.frame.maxY - animatedPreview.frame.maxY - 10 - panelCollectionView.contentOffset.y
        self.window?.rootViewController?.present(categoryPopupVC, animated: true, completion: nil)
    }
    
    @IBAction func scrollDown(_ sender: Any) {
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
            cell.animatedPreviewVM = animatedPreviewVM
            cell.previewVM = previewVM
            cell.layerListVM = layerVM
            cell.panelCollectionView = panelCollectionView
            cell.animatedPreview = animatedPreview
            cell.previewAndLayerCVC = self
            previewListCell = cell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayerListCollectionViewCell", for: indexPath) as! LayerListCollectionViewCell
            cell.layerVM = layerVM
            cell.canvas = canvas
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let width = previewAndLayerCVC.bounds.width
        let height = previewAndLayerCVC.bounds.height * 0.2
        return CGSize(width: width, height: height)
    }
}

// 스크롤이 종료되면 위치를 받아서 스크롤 방향을 정한다.
extension PreviewAndLayerCollectionViewCell: UICollectionViewDelegate {
    func setContentOffset() {
        let maxYoffset = previewAndLayerCVC.contentSize.height - previewAndLayerCVC.frame.size.height
        if previewAndLayerCVC.contentOffset.y < maxYoffset / 3 {
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: maxYoffset), animated: true)
        } else {
            previewAndLayerCVC.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    func setArrowImage() {
        let imageName = previewAndLayerCVC.contentOffset.y == 0 ? "arrow.up" : "arrow.down"
        goDownBtn.imageView?.image = UIImage(systemName: imageName)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        setContentOffset()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setArrowImage()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setArrowImage()
    }
}
