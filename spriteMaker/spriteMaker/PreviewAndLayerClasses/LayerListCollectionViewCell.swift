//
//  LayerListCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/06.
//

import UIKit

class LayerListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var layerCollection: UICollectionView!
    
}

extension LayerListCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 4:
            let addBtnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddLayerCell", for: indexPath) as! AddLayerCell
            drawShadow(targetCell: addBtnCell)
            return addBtnCell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayerCell", for: indexPath) as! LayerCell
            drawShadow(targetCell: cell)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LayerHeaderCell", for: indexPath) as! LayerHeaderCell
        header.labelNum.text = "#1"
        
        return header
    }
    
    func drawShadow(targetCell: UICollectionViewCell) {
        targetCell.layer.shadowColor = UIColor.black.cgColor
        targetCell.layer.masksToBounds = false
        targetCell.layer.shadowOffset = CGSize(width: 0, height: 0)
        targetCell.layer.shadowRadius = 5
        targetCell.layer.shadowOpacity = 0.3
    }
}

extension LayerListCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let oneSideLen = layerCollection.layer.bounds.height * 0.8
        return CGSize(width: oneSideLen, height: oneSideLen)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let oneSideLen = layerCollection.layer.bounds.height
        return CGSize(width: oneSideLen * 0.7, height: oneSideLen)
    }
}

class LayerCell: UICollectionViewCell {
    @IBOutlet weak var layerImage: UIImageView!
}

class LayerHeaderCell: UICollectionReusableView {
    @IBOutlet weak var labelNum: UILabel!
}

class AddLayerCell: UICollectionViewCell {
    @IBOutlet weak var AddBtn: UIButton!
}
