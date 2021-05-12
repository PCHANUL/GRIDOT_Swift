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
    var canvas: Canvas!
    
    // [] canvas에서 layerImage를 하나씩 그리기
    // [] grid에서 selectedLayer를 업데이트하기
    // [] hide layer 기능
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
        header.labelNum.text = "#\(layerVM.selectedItemIndex + 1)"
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
    func updateGridData() {
        guard let selectedItem = layerVM.selectedItem else { return }
        guard let gridData = selectedItem.layers[layerVM.selectedLayerIndex].gridData else { return }
        print(gridData)
        canvas.changeGrid(index: layerVM.selectedLayerIndex, gridData: gridData)
        canvas.setNeedsDisplay()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        layerVM.selectedLayerIndex = indexPath.row
        let canvasData = layerVM.selectedLayer?.gridData ?? ""
        canvas.changeGrid(index: indexPath.row, gridData: canvasData)
        layerCollection.reloadData()
        updateGridData()
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
