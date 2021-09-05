//
//  ExportCategoryPanelCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/26.
//

import UIKit

class ExportCategoryPanelCVC: UICollectionViewCell {
    @IBOutlet weak var categoryCV: UICollectionView!
    
    weak var superCollectionView: ExportViewController!
    var categorys: [String]!
    var categoryNums: [Int]!
    var categoryVM = CategoryListViewModel()
    var frameOneSideLen: CGFloat!
    
}

extension ExportCategoryPanelCVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExportCategoryItemCVC", for: indexPath) as! ExportCategoryItemCVC
        let category = categorys[indexPath.row]
        cell.categoryLabel.text = category
        cell.backgroundColor = categoryVM.getCategoryColor(category: category)
        setSideCorner(target: cell, side: "all", radius: cell.frame.height / 2)
        return cell
    }
}

extension ExportCategoryPanelCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = frameOneSideLen! + ((frameOneSideLen! + 5) * CGFloat(categoryNums[indexPath.row]) - 1)
        return CGSize(width: width, height: self.frame.height - 10)
    }
}

extension ExportCategoryPanelCVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var count = 0
        
        for index in 0..<indexPath.row {
            count += superCollectionView.categoryDataNums[index] + 1
        }
        
        for newItem in 0..<superCollectionView.categoryDataNums[indexPath.row] + 1 {
            if (superCollectionView.frameDataArr[count + newItem].isSelected == false) {
                superCollectionView.selectedFrameCount += 1
            }
            superCollectionView.frameDataArr[count + newItem].isSelected = true
        }
        superCollectionView.checkSelectedFrameStatus()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        superCollectionView.exportFramePanelCVC.frameCV.contentOffset.x = scrollView.contentOffset.x
    }
}
