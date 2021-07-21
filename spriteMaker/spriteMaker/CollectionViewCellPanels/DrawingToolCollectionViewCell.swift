//
//  DrawingToolCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/03.
//

import UIKit

class DrawingToolCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var drawingToolCollection: UICollectionView!
    var headerCell: DrawingToolHeader!
    
    var drawingToolVM: DrawingToolViewModel!
    var panelCollectionView: UICollectionView!
    var panelCVC: PanelContainerViewController!
    
    override func layoutSubviews() {
        panelCollectionView = panelCVC.panelCollectionView
    }
    
    func checkExtToolExist(_ index: Int) -> Bool {
        return (drawingToolVM.getItem(index: index).extTools != nil)
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drawingToolVM.numsOfTool
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let drawingTool: DrawingTool!
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCell", for: indexPath) as? DrawingToolCell else {
            return UICollectionViewCell()
        }
        drawingTool = drawingToolVM.getItem(index: indexPath.row)
        cell.toolImage.image = UIImage(named: drawingTool.name)
        if indexPath.row == drawingToolVM.selectedToolIndex {
            cell.cellBG.backgroundColor = UIColor.black
        } else {
            cell.cellBG.backgroundColor = UIColor.clear
        }
        cell.cellHeight = cell.bounds.height
        cell.isExtToolExist = checkExtToolExist(indexPath.row)
        cell.cellIndex = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DrawingToolHeader", for: indexPath) as! DrawingToolHeader
        headerCell = header
        headerCell.drawingToolCollectionViewCell = self
        setOneSideCorner(target: headerCell, side: "all", radius: headerCell.bounds.width / 5)
        setOneSideCorner(target: headerCell.penBtn, side: "all", radius: headerCell.penBtn.bounds.width / 9)
        setOneSideCorner(target: headerCell.touchBtn, side: "all", radius: headerCell.touchBtn.bounds.width / 9)
        headerCell.penBtn.tag = 0
        headerCell.touchBtn.tag = 1
        return headerCell
    }
}
    
class DrawingToolHeader: UICollectionReusableView {
    @IBOutlet weak var penBtn: UIButton!
    @IBOutlet weak var touchBtn: UIButton!
    var drawingToolCollectionViewCell: DrawingToolCollectionViewCell!
    var panelCVC: PanelContainerViewController!
    
    override func layoutSubviews() {
        panelCVC = drawingToolCollectionViewCell.panelCVC
    }
    
    @IBAction func tappedTouchBtn(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            penBtn.layer.backgroundColor = UIColor.darkGray.cgColor
            touchBtn.layer.backgroundColor = UIColor.clear.cgColor
            panelCVC.canvas.selectedDrawingMode = "pen"
            drawingToolCollectionViewCell.drawingToolVM.changeDrawingMode()
            panelCVC.canvas.setNeedsDisplay()
        case 1:
            touchBtn.layer.backgroundColor = UIColor.darkGray.cgColor
            penBtn.layer.backgroundColor = UIColor.clear.cgColor
            panelCVC.canvas.selectedDrawingMode = "touch"
            drawingToolCollectionViewCell.drawingToolVM.changeDrawingMode()
            panelCVC.canvas.setNeedsDisplay()
            panelCVC.canvas.setCenterTouchPosition()
            panelCVC.canvas.touchDrawingMode.setInitPosition()
        default:
            return
        }
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = drawingToolCollection.bounds.height / 2.2
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sideLength = drawingToolCollection.bounds.height / 2
        return CGSize(width: sideLength, height: sideLength)
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == drawingToolVM.selectedToolIndex && checkExtToolExist(indexPath.row) {
            let drawingToolPopupVC = UIStoryboard(name: "DrawingToolPopup", bundle: nil).instantiateViewController(identifier: "DrawingToolPopupViewController") as! DrawingToolPopupViewController
            let selectedCellFrame = collectionView.cellForItem(at: indexPath)!.frame
            let positionY = (self.frame.minY - panelCollectionView.contentOffset.y) + selectedCellFrame.minY
            drawingToolPopupVC.popupPositionY = positionY
            drawingToolPopupVC.popupPositionX = selectedCellFrame.minX
            drawingToolPopupVC.drawingToolVM = drawingToolVM
            drawingToolPopupVC.modalPresentationStyle = .overFullScreen
            drawingToolPopupVC.drawingToolCollection = drawingToolCollection
            self.window?.rootViewController?.present(drawingToolPopupVC, animated: false, completion: nil)
        }
        drawingToolVM.selectedToolIndex = indexPath.row
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
