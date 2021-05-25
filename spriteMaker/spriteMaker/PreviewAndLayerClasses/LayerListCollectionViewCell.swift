//
//  LayerListCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/06.
//

import UIKit

class LayerListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var layerCollection: UICollectionView!
    
    
    var panelCollectionView: UICollectionView!
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
            addBtnCell.canvas = canvas
            drawShadow(targetCell: addBtnCell)
            return addBtnCell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayerCell", for: indexPath) as! LayerCell
            guard let layer = layerVM.getLayer(index: indexPath.row) else { return cell }
            cell.layerImage.image = layer.layerImage
            if (layerVM.selectedLayerIndex == indexPath.row) {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.white.cgColor
            } else {
                cell.layer.borderWidth = 0
            }
            
            cell.ishiddenView.isHidden = !layer.ishidden
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
        let gridData = selectedItem.layers[layerVM.selectedLayerIndex].gridData
        canvas.changeGrid(index: layerVM.selectedLayerIndex, gridData: gridData)
        canvas.setNeedsDisplay()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == layerVM.selectedLayerIndex {
            let layerOptionVC = UIStoryboard(name: "LayerOptionPopup", bundle: nil).instantiateViewController(identifier: "LayerOptionPopup") as! LayerOptionPopupViewController
            layerOptionVC.modalPresentationStyle = .overFullScreen
            layerOptionVC.layerListVM = layerVM
            layerOptionVC.popupPositionY = self.frame.minY - self.frame.height + 10 - panelCollectionView.contentOffset.y
            let eyeImage = layerVM.selectedLayer!.ishidden ? "eye" : "eye.slash"
            self.window?.rootViewController?.present(layerOptionVC, animated: false, completion: nil)
            layerOptionVC.ishiddenBtn.setImage(UIImage.init(systemName: eyeImage), for: .normal)
        } else {
            layerVM.selectedLayerIndex = indexPath.row
            let canvasData = layerVM.selectedLayer?.gridData ?? ""
            canvas.changeGrid(index: indexPath.row, gridData: canvasData)
            layerCollection.reloadData()
            updateGridData()
        }
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
    @IBOutlet weak var ishiddenView: UIView!
}

class LayerHeaderCell: UICollectionReusableView {
    @IBOutlet weak var labelNum: UILabel!
}

class AddLayerCell: UICollectionViewCell {
    var layerVM: LayerListViewModel!
    var canvas: Canvas!
    
    @IBAction func addLayer(_ sender: Any) {
        guard let viewModel = layerVM else { return }
        guard let image = UIImage(named: "empty") else { return }
        viewModel.addNewLayer(layer: Layer(layerImage: image, gridData: "", ishidden: false))
        viewModel.selectedLayerIndex += 1
        canvas.changeGrid(index: viewModel.selectedLayerIndex, gridData: "")
        canvas.setNeedsDisplay()
    }
}
