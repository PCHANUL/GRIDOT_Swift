//
//  DrawingToolCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/03.
//

import UIKit

class DrawingToolCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var drawingToolCollection: UICollectionView!
    @IBOutlet weak var drawingModeToggleView: UIView!
    @IBOutlet weak var penDrawingModeButton: UIButton!
    @IBOutlet weak var touchDrawingModeButton: UIButton!
    @IBOutlet weak var toggleButtonView: UIView!
    @IBOutlet weak var toggleButtonContraint: NSLayoutConstraint!
    
    var drawingToolVM: DrawingToolViewModel!
    var panelCollectionView: UICollectionView!
    var panelCVC: PanelContainerViewController!
   
    override func layoutSubviews() {
        let rect: CGRect!
        
        rect = CGRect(x: 0, y: 0, width: (self.bounds.height - 10) * 0.67, height: self.bounds.height - 10)
        setSideCorner(target: drawingModeToggleView, side: "all", radius: drawingModeToggleView.bounds.width / 3)
        setSideCorner(target: toggleButtonView, side: "all", radius: toggleButtonView.bounds.width / 3)
        addInnerShadow(drawingModeToggleView, rect: rect, radius: drawingModeToggleView.bounds.width / 3)
        penDrawingModeButton.tag = 0
        touchDrawingModeButton.tag = 1
        panelCollectionView = panelCVC.panelCollectionView
    }
    
    func checkExtToolExist(_ index: Int) -> Bool {
        return (drawingToolVM.getItem(index: index).extTools != nil)
    }
    
    @IBAction func tappedTouchBtn(_ sender: UIButton) {
        guard let sideButtonGroup = self.panelCVC.superViewController.sideButtonViewGroup else { return }
        switch sender.tag {
        case 0:
            UIView.transition(with: sideButtonGroup, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                sideButtonGroup.isHidden = true
            })
            toggleButtonContraint.constant = sender.frame.minY - 9
            UIView.animate(withDuration: 0.5) {
                self.layoutIfNeeded()
            }
            panelCVC.canvas.selectedDrawingMode = "pen"
            drawingToolVM.changeDrawingMode()
            panelCVC.canvas.setNeedsDisplay()
            panelCVC.colorPickerToolBar.sliderView.setNeedsLayout()
        case 1:
            toggleButtonContraint.constant = sender.frame.minY - 9
            UIView.animate(withDuration: 0.5) {
                self.layoutIfNeeded()
            }
            panelCVC.canvas.selectedDrawingMode = "touch"
            drawingToolVM.changeDrawingMode()
            UIView.transition(with: sideButtonGroup, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                sideButtonGroup.isHidden = false
            })
            panelCVC.canvas.setNeedsDisplay()
            panelCVC.canvas.setCenterTouchPosition()
            panelCVC.canvas.touchDrawingMode.setInitPosition()
            panelCVC.colorPickerToolBar.sliderView.setNeedsLayout()
        default:
            return
        }
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
            cell.cellBG.backgroundColor = UIColor.init(white: 0.2, alpha: 1)
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
        panelCVC.canvas.setNeedsDisplay()
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
