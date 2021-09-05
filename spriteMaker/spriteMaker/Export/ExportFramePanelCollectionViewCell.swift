//
//  ExportFramePanelCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/26.
//

import UIKit

class ExportFramePanelCVC: UICollectionViewCell {
    @IBOutlet weak var frameCV: UICollectionView!
    weak var superCollectionView: ExportViewController!
    var frames: [FrameData]!
    
}

extension ExportFramePanelCVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExportFrameItemCVC", for: indexPath) as! ExportFrameItemCVC
        cell.frameImage.image = frames[indexPath.row].data.renderedImage
        cell.layer.borderColor = UIColor.white.cgColor
        if (superCollectionView.frameDataArr[indexPath.row].isSelected) {
            cell.layer.borderWidth = 2
        } else {
            cell.layer.borderWidth = 0
        }
        return cell
    }
}

extension ExportFramePanelCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.height - 5, height: self.frame.height - 5)
    }
}

extension ExportFramePanelCVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let status = superCollectionView.frameDataArr[indexPath.row].isSelected
        superCollectionView.selectedFrameCount += status ? -1 : 1
        superCollectionView.frameDataArr[indexPath.row].isSelected = !status
        superCollectionView.checkSelectedFrameStatus()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        superCollectionView.exportCategoryPanelCVC.categoryCV.contentOffset.x = scrollView.contentOffset.x
    }
}
