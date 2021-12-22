//
//  DrawingToolCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/03.
//

import UIKit
import PhotosUI

class DrawingToolCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var drawingModeToggleView: UIView!
    @IBOutlet weak var penDrawingModeButton: UIButton!
    @IBOutlet weak var touchDrawingModeButton: UIButton!
    @IBOutlet weak var toggleButtonView: UIView!
    @IBOutlet weak var toggleButtonContraint: NSLayoutConstraint!
    @IBOutlet weak var drawingToolCollection: UICollectionView!
    
    var panelCollectionView: UICollectionView!
    var drawingVC: DrawingViewController!
    var drawingToolVM: DrawingToolViewModel!
    var timeMachineVM: TimeMachineViewModel!
    var photoBackgroundView: UIView!
    var photoButtonView: UIView!
    var isInited: Bool = false
   
    override func layoutSubviews() {
        if (isInited == false) {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
            drawingToolCollection.addGestureRecognizer(gesture)
            
            let rect = CGRect(x: 0, y: 0, width: (self.bounds.height - 10) * 0.67, height: self.bounds.height - 10)
            addInnerShadow(drawingModeToggleView, rect: rect, radius: drawingModeToggleView.bounds.width / 3)
            setSideCorner(target: drawingModeToggleView, side: "all", radius: drawingModeToggleView.bounds.width / 3)
            setSideCorner(target: toggleButtonView, side: "all", radius: toggleButtonView.bounds.width / 3)
            isInited = true
        }
    }
    
    // 길게 눌러서 색상순서 변경
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let collectionView = drawingToolCollection
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            collectionView?.beginInteractiveMovementForItem(at: targetIndexPath)
            collectionView?.cellForItem(at: targetIndexPath)?.alpha = 0.5
        case .changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView?.endInteractiveMovement()
            collectionView?.reloadData()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
    
    @IBAction func tappedTouchBtn(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        
        if (defaults.value(forKey: "drawingMode") as! Int == sender.tag) { return }
        else { defaults.setValue(sender.tag, forKey: "drawingMode") }
        
        switch sender.tag {
        case 0:
            toggleButtonContraint.constant = sender.frame.minY - 9
            UIView.animate(withDuration: 0.5) { self.layoutIfNeeded() }
            setVisibleSidButtonView(isHidden: true)
        case 1:
            toggleButtonContraint.constant = sender.frame.minY - 9
            UIView.animate(withDuration: 0.5) { self.layoutIfNeeded() }
            setVisibleSidButtonView(isHidden: false)
            
            drawingVC.canvas.setCenterTouchPosition()
            drawingVC.canvas.touchDrawingMode.setInitPosition()
        default:
            return
        }
        
        setDrawingModeValue(selectedMode: sender.tag)
        drawingVC.changeDrawingMode(selectedMode: sender.tag)
        drawingVC.canvas.updateAnimatedPreview()
        drawingVC.canvas.setNeedsDisplay()
    }
    
    func setDrawingModeValue(selectedMode: Int) {
        guard let toolName = drawingVC.canvas.selectedDrawingTool else { return }
        let antiTouchModeTools = ["Picker", "Photo"]
        
        if (antiTouchModeTools.firstIndex(of: toolName) != nil) {
            drawingVC.canvas.selectedDrawingMode = "pen"
        } else {
            drawingVC.canvas.selectedDrawingMode = selectedMode == 0 ? "pen" : "touch"
        }
    }
   
    func setVisibleSidButtonView(isHidden: Bool) {
        guard let sideButtonGroup = self.drawingVC.sideButtonViewGroup else { return }
        
        if (isHidden) {
            sideButtonGroup.isHidden = true
        } else {
            UIView.transition(with: sideButtonGroup, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                sideButtonGroup.isHidden = false
            })
        }
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreData.shared.numsOfTools
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let drawingTool: Tool!
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingToolCell", for: indexPath) as? DrawingToolCell else {
            return UICollectionViewCell()
        }
        drawingTool = CoreData.shared.getTool(index: indexPath.row)
        if (drawingTool.main == "Undo") {
            cell.toolImage.alpha = timeMachineVM.canUndo ? 1 : 0.2
        } else if (drawingTool.main == "Redo") {
            cell.toolImage.alpha = timeMachineVM.canRedo ? 1 : 0.2
        } else {
            cell.toolImage.alpha = 1
        }
        
        cell.toolImage.image = UIImage(named: drawingTool.main!)
        if indexPath.row == CoreData.shared.selectedToolIndex {
            cell.cellBG.backgroundColor = UIColor.init(named: "Color_select")
        } else {
            cell.cellBG.backgroundColor = UIColor.clear
        }
        
        cell.cellHeight = cell.bounds.height
        cell.cellIndex = indexPath.row
        cell.isExtToolExist = drawingTool.ext!.count > 0
        return cell
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = drawingToolCollection.bounds.height / 2.2
        return CGSize(width: sideLength, height: sideLength)
    }
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        CoreData.shared.reorderFunc(itemAt: sourceIndexPath.row, to: destinationIndexPath.row) { a, b in
            CoreData.shared.swapTool(a, b)
        } completion: { [self] in
            CoreData.shared.selectedToolIndex = destinationIndexPath.row
            CoreData.shared.saveData(entity: .tool)
            drawingVC.canvas.switchToolsInitSetting()
            drawingVC.setButtonImage()
            drawingVC.canvas.selectedDrawingTool = CoreData.shared.selectedMainTool
            drawingVC.canvas.setNeedsDisplay()
        }
        drawingToolCollection.reloadData()
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.row == CoreData.shared.selectedToolIndex) {
            setDrawingToolPopupVC(collectionView, indexPath)
        } else {
            drawingVC.canvas.switchToolsSetUnused()
            switch CoreData.shared.getTool(index: indexPath.row).main {
            case "Photo":
                setPhotoToolButtons()
                CoreData.shared.selectedToolIndex = indexPath.row
                drawingVC.canvas.selectedDrawingMode = "pen"
            case "Undo":
                drawingVC.checkSelectedFrameAndScroll(index: timeMachineVM.endIndex - 1)
                timeMachineVM.undo()
                drawingToolCollection.reloadData()
            case "Redo":
                drawingVC.checkSelectedFrameAndScroll(index: timeMachineVM.endIndex + 1)
                timeMachineVM.redo()
                drawingToolCollection.reloadData()
            case "Light":
                let lightMode = self.window?.overrideUserInterfaceStyle
                self.window?.overrideUserInterfaceStyle = lightMode == .dark ? .light : .dark
            case "Picker":
                drawingVC.canvas.selectedDrawingMode = "pen"
                CoreData.shared.selectedToolIndex = indexPath.row
            default:
                let drawingMode = UserDefaults.standard.value(forKey: "drawingMode") as! Int
                if (drawingMode == 1) { drawingVC.canvas.selectedDrawingMode = "touch" }
                CoreData.shared.selectedToolIndex = indexPath.row
                break
            }
            drawingVC.canvas.switchToolsInitSetting()
            drawingVC.canvas.selectedDrawingTool = CoreData.shared.selectedMainTool
        }
        drawingVC.setButtonImage()
        drawingToolCollection.reloadData()
        drawingVC.canvas.setNeedsDisplay()
    }
}

extension DrawingToolCollectionViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if (drawingVC.canvas.photoTool.selectedPhoto == nil) {
                changePhotoButtonActivated()
            }
            guard let selectedPhoto = flipImageVertically(originalImage: pickedImage).cgImage else { return }
            drawingVC.canvas.photoTool.selectedPhoto = selectedPhoto
            drawingVC.canvas.photoTool.initPhotoRects()
            drawingVC.canvas.setNeedsDisplay()
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
        
        topPosition += drawingVC.panelCollectionView.frame.minY
        topPosition += self.frame.minY - panelCollectionView.contentOffset.y
        topPosition += drawingToolCollection.frame.minY
        topPosition += selectedCellFrame.maxY + 7
        leadingPosition += drawingVC.panelCollectionView.frame.minX
        leadingPosition += self.frame.minX - panelCollectionView.contentOffset.x
        leadingPosition += drawingToolCollection.frame.minX
        leadingPosition -= drawingToolCollection.contentOffset.x
        leadingPosition += selectedCellFrame.minX
        
        drawingToolPopupVC.modalPresentationStyle = .overFullScreen
        drawingToolPopupVC.drawingToolCollection = drawingToolCollection
        drawingToolPopupVC.changeMainToExt = { [self] index in
            CoreData.shared.changeMainToExt(extIndex: index)
            drawingVC.canvas.selectedDrawingTool = CoreData.shared.selectedMainTool
            drawingVC.setButtonImage()
        }
        
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
        setPopupViewShadow(button)
        button.backgroundColor = bgColor
        button.tintColor = .white
        button.setImage(UIImage.init(systemName: imageName, withConfiguration: imageConfig), for: .normal)
        return button
    }
    
    func setPhotoToolButtons() {
        // set backgroundView
        photoBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        photoBackgroundView.backgroundColor = UIColor.init(named: "Color_gridLine")
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
        drawingVC.canvas.photoTool.isAnchorHidden = false
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
        drawingVC.present(imagePicker, animated: true)
    }
    
    @objc func pressedButtonCancel() {
       cancelPhotoTool()
    }
    
    @objc func pressedButtonConfirm() {
        drawingVC.canvas.photoTool.addNewLayer()
        drawingVC.canvas.photoTool.createPixelPhoto()
        cancelPhotoTool()
    }
    
    @objc func pressedButtonPreview() {
        drawingVC.canvas.photoTool.previewPixel()
    }
    
    @objc func canceledButtonPreview() {
        initPreview()
    }
    
    func initPreview() {
        drawingVC.canvas.photoTool.isPreview = false
        drawingVC.canvas.photoTool.previewArr = []
        drawingVC.canvas.setNeedsDisplay()
    }
    
    func cancelPhotoTool() {
        photoBackgroundView.removeFromSuperview()
        photoButtonView.removeFromSuperview()
        drawingVC.canvas.photoTool.selectedPhoto = nil
        drawingVC.canvas.photoTool.isAnchorHidden = true
        drawingVC.canvas.setNeedsDisplay()
    }
}
