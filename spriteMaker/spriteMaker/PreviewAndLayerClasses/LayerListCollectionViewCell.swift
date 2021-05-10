//
//  LayerListCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/06.
//

import UIKit

class LayerListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var layerCollection: UICollectionView!
    
    var layerVM: LayerListViewModel!
    
    // preview에서 선택된 item에서 layer를 가져와야한다.
    // 1. LayerList는 PreviewModel과 연결된다.
    // 2. LayerModel을 따로 만든다.
    
    // layer는 각각 canvas Data와 previewImage를 가진다.
    // canvas는 layer를 하나씩 순서대로 그린다.
    // 만약에 숨긴 상태라면 그리지 않는다.
    // canvas에서 그림을 그릴때 선택된 layer가 무엇인지 확인한다.
    // 선택된 layer의 grid에 픽셀이 선택된다.
    // layer가 변경될때마다 grid가 변경된다.
    // gird가 변경되지만 canvas에 그려지는 그림은 모든 layer이다.
}

extension LayerListCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layerVM.numsOfLayer + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case layerVM.numsOfLayer:
            let addBtnCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddLayerCell", for: indexPath) as! AddLayerCell
            addBtnCell.layerVM = layerVM
            drawShadow(targetCell: addBtnCell)
            return addBtnCell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayerCell", for: indexPath) as! LayerCell
            cell.layerImage.image = layerVM.getLayer(index: indexPath.row)?.layerImage
            if (layerVM.selectedLayerIndex == indexPath.row) {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.white.cgColor
            } else {
                cell.layer.borderWidth = 0
            }
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

extension LayerListCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        layerVM.selectedLayerIndex = indexPath.row
        
        layerCollection.reloadData()
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
    var layerVM: LayerListViewModel!
    
    @IBAction func addLayer(_ sender: Any) {
        guard let viewModel = layerVM else { return }
        viewModel.addNewLayer(layer: Layer())
        viewModel.selectedLayerIndex += 1
        
    }
}
