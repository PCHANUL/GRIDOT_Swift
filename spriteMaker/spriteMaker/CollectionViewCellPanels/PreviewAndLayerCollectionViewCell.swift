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
    var previewVM: PreviewListViewModel!
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var panelCollectionView: UICollectionView!
    
    @IBOutlet weak var PreviewAndLayerCVC: UICollectionView!
    @IBOutlet weak var animatedPreviewUIView: UIView!
    @IBOutlet weak var animatedPreview: UIImageView!
    
    // cells
    var previewListCell = PreviewListCollectionViewCell()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animatedPreview.layer.shadowColor = UIColor.black.cgColor
        animatedPreview.layer.masksToBounds = false
        animatedPreview.layer.shadowOffset = CGSize(width: 0, height: 4)
        animatedPreview.layer.shadowRadius = 5
        animatedPreview.layer.shadowOpacity = 0.3
    }
    
    @IBAction func tappedAnimate(_ sender: Any) {
        let categoryPopupVC = UIStoryboard(name: "AnimatedPreviewPopupViewController", bundle: nil).instantiateViewController(identifier: "AnimatedPreviewPopupViewController") as! AnimatedPreviewPopupViewController
        categoryPopupVC.modalPresentationStyle = .overFullScreen
        categoryPopupVC.categorys = previewVM.getCategorys()
        categoryPopupVC.animatedPreviewViewModel = animatedPreviewVM
        categoryPopupVC.positionY = self.frame.maxY - animatedPreview.frame.maxY - 10 - panelCollectionView.contentOffset.y
        self.window?.rootViewController?.present(categoryPopupVC, animated: true, completion: nil)
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
            cell.animatedPreviewViewModel = animatedPreviewVM
            cell.panelCollectionView = panelCollectionView
            cell.animatedPreview = animatedPreview
            cell.previewAndLayerCVC = self
            previewListCell = cell
            
            if previewVM.numsOfItems == 0 { canvas.convertCanvasToImage(0) }
            animatedPreviewVM.changeAnimatedPreview(isReset: true)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayerListCollectionViewCell", for: indexPath) as! LayerListCollectionViewCell
            cell.layerCollection.layer.borderWidth = 0.5
            cell.layerCollection.layer.borderColor = UIColor.white.cgColor
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension PreviewAndLayerCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = PreviewAndLayerCVC.bounds.width
        let height = width / 3.5
        return CGSize(width: width, height: height)
    }
}
