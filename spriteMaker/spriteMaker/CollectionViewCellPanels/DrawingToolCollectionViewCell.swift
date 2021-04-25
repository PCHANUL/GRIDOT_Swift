//
//  DrawingToolCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/03.
//

import UIKit

class DrawingToolCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var drawingToolCollection: UICollectionView!
    
    var drawingToolViewModel: DrawingToolViewModel!
    var panelCollectionView : UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func checkExtToolExist(_ index: Int) -> Bool {
        return (drawingToolViewModel.getItem(index: index).extTools != nil)
    }
    
}

extension DrawingToolCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drawingToolViewModel.numsOfTool
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCell", for: indexPath) as? DrawingToolCell else {
            return UICollectionViewCell()
        }
        let drawingTool = drawingToolViewModel.getItem(index: indexPath.row)
        cell.toolImage.image = UIImage(named: drawingTool.name)
        if indexPath.row == drawingToolViewModel.selectedToolIndex {
            cell.cellBG.backgroundColor = UIColor.black
        } else {
            cell.cellBG.backgroundColor = UIColor.clear
        }
        cell.cellHeight = cell.bounds.height
        cell.isExtToolExist = checkExtToolExist(indexPath.row)
        cell.cellIndex = indexPath.row
        return cell
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = drawingToolCollection.bounds.height / 2.2
        return CGSize(width: sideLength, height: sideLength)
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == drawingToolViewModel.selectedToolIndex && checkExtToolExist(indexPath.row) {
            print("open options")
            let drawingToolPopupVC = UIStoryboard(name: "DrawingToolPopup", bundle: nil).instantiateViewController(identifier: "DrawingToolPopupViewController") as! DrawingToolPopupViewController
            
            let selectedCellFrame = collectionView.cellForItem(at: indexPath)!.frame
            let positionY = (self.frame.minY - panelCollectionView.contentOffset.y) + selectedCellFrame.minY
            drawingToolPopupVC.popupPositionY = positionY
            drawingToolPopupVC.popupPositionX = selectedCellFrame.minX
            drawingToolPopupVC.drawingTool = drawingToolViewModel.currentItem()
            drawingToolPopupVC.modalPresentationStyle = .overFullScreen
            self.window?.rootViewController?.present(drawingToolPopupVC, animated: false, completion: nil)
        }
        drawingToolViewModel.selectedToolIndex = indexPath.row
        drawingToolCollection.reloadData()
    }
}

class DrawingToolCell: UICollectionViewCell {
    @IBOutlet weak var toolImage: UIImageView!
    @IBOutlet weak var cellBG: UIView!
    var cellHeight: CGFloat!
    var isExtToolExist: Bool!
    var cellIndex: Int!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellBG.layer.cornerRadius = cellHeight / 7
        if isExtToolExist {
            let triangle = TriangleCornerView(frame: CGRect(x: 0, y: 0, width: cellHeight, height: cellHeight))
            triangle.backgroundColor = .clear
            self.addSubview(triangle)
        } else {
            for subview in self.subviews where subview is TriangleCornerView {
                subview.removeFromSuperview()
            }
        }
    }
}




