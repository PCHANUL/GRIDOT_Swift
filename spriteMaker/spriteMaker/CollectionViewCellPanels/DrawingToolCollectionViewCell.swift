//
//  DrawingToolCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/03.
//

import UIKit
import PhotosUI

class DrawingToolCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var drawingToolCollection: UICollectionView!
    @IBOutlet weak var drawingModeToggleView: UIView!
    @IBOutlet weak var penDrawingModeButton: UIButton!
    @IBOutlet weak var touchDrawingModeButton: UIButton!
    @IBOutlet weak var toggleButtonView: UIView!
    @IBOutlet weak var toggleButtonContraint: NSLayoutConstraint!
    
    var panelCollectionView: UICollectionView!
    var drawingCVC: DrawingCollectionViewCell!
    var drawingToolVM: DrawingToolViewModel!
    var timeMachineVM: TimeMachineViewModel!
    
    var photoBackgroundView: UIView!
    var photoButtonView: UIView!
   
    override func layoutSubviews() {
        let rect: CGRect!
        
        rect = CGRect(x: 0, y: 0, width: (self.bounds.height - 10) * 0.67, height: self.bounds.height - 10)
        addInnerShadow(drawingModeToggleView, rect: rect, radius: drawingModeToggleView.bounds.width / 3)
        setSideCorner(target: drawingModeToggleView, side: "all", radius: drawingModeToggleView.bounds.width / 3)
        setSideCorner(target: toggleButtonView, side: "all", radius: toggleButtonView.bounds.width / 3)
        penDrawingModeButton.tag = 0
        touchDrawingModeButton.tag = 1
    }
     
    func checkExtToolExist(_ index: Int) -> Bool {
        return (drawingToolVM.getItem(index: index).extTools != nil)
    }
    
    @IBAction func tappedTouchBtn(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        
        switch sender.tag {
        case 0:
            toggleButtonContraint.constant = sender.frame.minY - 9
            UIView.animate(withDuration: 0.5) { self.layoutIfNeeded() }
        case 1:
            toggleButtonContraint.constant = sender.frame.minY - 9
            UIView.animate(withDuration: 0.5) { self.layoutIfNeeded() }
        default:
            return
        }
        defaults.setValue(sender.tag, forKey: "drawingMode")
        changeDrawingMode()
        drawingCVC.canvas.updateAnimatedPreview()
    }
    
    func changeDrawingMode() {
        let defaults = UserDefaults.standard
        guard let drawingMode = (defaults.object(forKey: "drawingMode") as? Int) else { return }
        guard let sideButtonGroup = self.drawingCVC.sideButtonViewGroup else { return }
        
        switch drawingMode {
        case 0:
            sideButtonGroup.isHidden = true
            drawingCVC.canvas.selectedDrawingMode = "pen"
            drawingToolVM.changeDrawingMode()
            drawingCVC.canvas.setNeedsDisplay()
            drawingCVC.colorPickerToolBar.sliderView.setNeedsLayout()
        case 1:
            drawingCVC.canvas.selectedDrawingMode = "touch"
            drawingToolVM.changeDrawingMode()
            UIView.transition(with: sideButtonGroup, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                sideButtonGroup.isHidden = false
            })
            drawingCVC.canvas.setNeedsDisplay()
            drawingCVC.canvas.setCenterTouchPosition()
            drawingCVC.canvas.touchDrawingMode.setInitPosition()
            drawingCVC.colorPickerToolBar.sliderView.setNeedsLayout()
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
        
        if (drawingTool.name == "Undo") {
            cell.toolImage.alpha = timeMachineVM.canUndo ? 1 : 0.3
        } else if (drawingTool.name == "Redo") {
            cell.toolImage.alpha = timeMachineVM.canRedo ? 1 : 0.3
        } else {
            cell.toolImage.alpha = 1
        }
        
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
            setDrawingToolPopupVC(collectionView, indexPath)
        } else {
            drawingToolVM.selectedToolIndex = indexPath.row
            drawingCVC.canvas.initCanvasDrawingTools()
            
            switch drawingCVC.drawingToolVM.selectedTool.name {
            case "Photo":
                setPhotoToolButtons()
            case "Undo":
                drawingCVC.checkSelectedFrameAndScroll(index: timeMachineVM.endIndex - 1)
                timeMachineVM.undo()
                drawingToolCollection.reloadData()
            case "Redo":
                drawingCVC.checkSelectedFrameAndScroll(index: timeMachineVM.endIndex + 1)
                timeMachineVM.redo()
                drawingToolCollection.reloadData()
            default:
                break
            }
        }
        drawingToolCollection.reloadData()
        drawingCVC.canvas.setNeedsDisplay()
    }
}

extension DrawingToolCollectionViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if (drawingCVC.canvas.photoTool.selectedPhoto == nil) {
                changePhotoButtonActivated()
            }
            guard let selectedPhoto = flipImageVertically(originalImage: pickedImage).cgImage else { return }
            drawingCVC.canvas.photoTool.selectedPhoto = selectedPhoto
            drawingCVC.canvas.photoTool.initPhotoRects()
            drawingCVC.canvas.setNeedsDisplay()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// tool popup view controller
extension DrawingToolCollectionViewCell {
    func setDrawingToolPopupVC(_ collectionView: UICollectionView, _ indexPath: IndexPath) {
        guard let drawingToolPopupVC = UIStoryboard(name: "DrawingToolPopup", bundle: nil).instantiateViewController(identifier: "DrawingToolPopupViewController") as? DrawingToolPopupViewController else { return }
        let selectedCellFrame = collectionView.cellForItem(at: indexPath)!.frame
        var topPosition: CGFloat = 0
        var leadingPosition: CGFloat = 0
        
        topPosition += drawingCVC.panelCollectionView.frame.minY
        topPosition += self.frame.minY - panelCollectionView.contentOffset.y
        topPosition += drawingToolCollection.frame.minY
        topPosition += selectedCellFrame.maxY + 7
        leadingPosition += drawingCVC.panelCollectionView.frame.minX
        leadingPosition += self.frame.minX - panelCollectionView.contentOffset.x
        leadingPosition += drawingToolCollection.frame.minX
        leadingPosition += selectedCellFrame.minX
        
        drawingToolPopupVC.drawingToolVM = drawingToolVM
        drawingToolPopupVC.modalPresentationStyle = .overFullScreen
        drawingToolPopupVC.drawingToolCollection = drawingToolCollection
        
        self.window?.rootViewController?.present(drawingToolPopupVC, animated: false, completion: nil)
        drawingToolPopupVC.listTopContraint.constant = topPosition
        drawingToolPopupVC.listLeadingContraint.constant = leadingPosition
        drawingToolPopupVC.listWidthContraint.constant = selectedCellFrame.width
    }
}

// photoTool functions
extension DrawingToolCollectionViewCell {
    func getPhotoToolButton(xPos: CGFloat, bgColor: UIColor, imageName: String, isImport: Bool = false) -> UIButton {
        let multiSize: CGFloat = isImport ? 3 : 1
        let width = (photoButtonView.bounds.width / 4 * multiSize) - 5
        let height = photoButtonView.bounds.height
        let button = UIButton(frame: CGRect(x: xPos, y: 0, width: width, height: height))
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        
        setSideCorner(target: button, side: "all", radius: button.bounds.height / 2)
        setViewShadow(target: button, radius: 10, opacity: 0.8)
        button.backgroundColor = bgColor
        button.tintColor = .white
        button.setImage(UIImage.init(systemName: imageName, withConfiguration: imageConfig), for: .normal)
        return button
    }
    
    func setPhotoToolButtons() {
        // set backgroundView
        photoBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        photoBackgroundView.backgroundColor = .black
        photoBackgroundView.alpha = 0.5
        
        // set buttonView
        let width = self.bounds.width * 0.9
        let height = self.bounds.height * 0.5
        let x = (self.bounds.width / 2) - (width / 2)
        let y = (self.bounds.height / 2) - (height / 2)
        photoButtonView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        
        // set importButton
        let importButton = getPhotoToolButton(
            xPos: 0,
            bgColor: .systemBlue,
            imageName: "square.and.arrow.down.fill",
            isImport: true
        )
        importButton.addTarget(self, action: #selector(pressedButtonLibrary), for: .touchDown)
        photoButtonView.addSubview(importButton)
        
        // set cancelButton
        let cancelButton = getPhotoToolButton(
            xPos: (photoButtonView.bounds.width / 4 * 3) + 5,
            bgColor: .systemRed,
            imageName: "xmark"
        )
        cancelButton.addTarget(self, action: #selector(pressedButtonCancel), for: .touchDown)
        photoButtonView.addSubview(cancelButton)
        
        self.addSubview(photoBackgroundView)
        self.addSubview(photoButtonView)
        drawingCVC.canvas.photoTool.isAnchorHidden = false
    }
    
    func changePhotoButtonActivated() {
        // set refreshButton
        let refreshButton = getPhotoToolButton(
            xPos: 0,
            bgColor: .white,
            imageName: "arrow.triangle.2.circlepath"
        )
        refreshButton.tintColor = .black
        refreshButton.addTarget(self, action: #selector(pressedButtonLibrary), for: .touchDown)
        photoButtonView.addSubview(refreshButton)
        photoButtonView.subviews[0].removeFromSuperview()
        
        // set previewButton
        let previewButton = getPhotoToolButton(
            xPos: (photoButtonView.bounds.width / 4) + 2.5,
            bgColor: .darkGray,
            imageName: "eye"
        )
        previewButton.addTarget(self, action: #selector(pressedButtonPreview), for: .touchDown)
        previewButton.addTarget(self, action: #selector(canceledButtonPreview), for: .touchUpOutside)
        previewButton.addTarget(self, action: #selector(canceledButtonPreview), for: .touchUpInside)
        photoButtonView.addSubview(previewButton)
        
        // set confirmButton
        let confirmButton = getPhotoToolButton(
            xPos: (photoButtonView.bounds.width / 4 * 2) + 2.5,
            bgColor: .systemBlue,
            imageName: "checkmark"
        )
        confirmButton.addTarget(self, action: #selector(pressedButtonConfirm), for: .touchDown)
        photoButtonView.addSubview(confirmButton)
    }
    
    @objc func pressedButtonLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        drawingCVC.superViewController.present(imagePicker, animated: true)
    }
    
    @objc func pressedButtonCancel() {
       cancelPhotoTool()
    }
    
    @objc func pressedButtonConfirm() {
        drawingCVC.canvas.photoTool.addNewLayer()
        drawingCVC.canvas.photoTool.createPixelPhoto()
        cancelPhotoTool()
    }
    
    @objc func pressedButtonPreview() {
        drawingCVC.canvas.photoTool.previewPixel()
    }
    
    @objc func canceledButtonPreview() {
        initPreview()
    }
    
    func initPreview() {
        drawingCVC.canvas.photoTool.isPreview = false
        drawingCVC.canvas.photoTool.previewArr = []
        drawingCVC.canvas.setNeedsDisplay()
    }
    
    func cancelPhotoTool() {
        photoBackgroundView.removeFromSuperview()
        photoButtonView.removeFromSuperview()
        drawingCVC.canvas.photoTool.selectedPhoto = nil
        drawingCVC.canvas.photoTool.isAnchorHidden = true
        drawingCVC.canvas.setNeedsDisplay()
    }
}
