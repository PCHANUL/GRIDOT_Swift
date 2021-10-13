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
    
    var drawingToolVM: DrawingToolViewModel!
    var panelCollectionView: UICollectionView!
    var drawingCVC: DrawingCollectionViewCell!
    
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
            UIView.animate(withDuration: 0.5) {
                self.layoutIfNeeded()
            }
        case 1:
            toggleButtonContraint.constant = sender.frame.minY - 9
            UIView.animate(withDuration: 0.5) {
                self.layoutIfNeeded()
            }
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
        } else {
            drawingToolVM.selectedToolIndex = indexPath.row
            drawingCVC.canvas.initCanvasDrawingTools()
            if (drawingCVC.drawingToolVM.selectedTool.name == "Photo") {
                photoBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
                photoBackgroundView.backgroundColor = .black
                photoBackgroundView.alpha = 0.5
                
                let width = self.bounds.width * 0.9
                let height = self.bounds.height * 0.5
                photoButtonView = UIView(
                    frame: CGRect(
                        x: (self.bounds.width / 2) - (width / 2),
                        y: (self.bounds.height / 2) - (height / 2),
                        width: width,
                        height: height
                    )
                )
                
                let button1 = UIButton(
                    frame: CGRect(
                        x: 0,
                        y: 0,
                        width: (photoButtonView.bounds.width / 4 * 3) - 5,
                        height: photoButtonView.bounds.height
                    )
                )
                setSideCorner(target: button1, side: "all", radius: button1.bounds.height / 2)
                setViewShadow(target: button1, radius: 10, opacity: 0.8)
                button1.backgroundColor = .systemBlue
                button1.setImage(
                    UIImage.init(
                        systemName: "square.and.arrow.down.fill",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
                button1.tintColor = .white
                button1.addTarget(self, action: #selector(pressedButtonLibrary), for: .touchDown)
                
                let button2 = UIButton(
                    frame: CGRect(
                        x: (photoButtonView.bounds.width / 4 * 3) + 5,
                        y: 0,
                        width: (photoButtonView.bounds.width / 4) - 5,
                        height: photoButtonView.bounds.height
                    )
                )
                setSideCorner(target: button2, side: "all", radius: button2.bounds.height / 2)
                setViewShadow(target: button2, radius: 10, opacity: 0.8)
                button2.backgroundColor = .systemRed
                button2.setImage(
                    UIImage.init(
                        systemName: "xmark",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
                button2.tintColor = .white
                button2.addTarget(self, action: #selector(pressedButtonCancel), for: .touchDown)
            
                
                photoButtonView.addSubview(button1)
                photoButtonView.addSubview(button2)
                
                self.addSubview(photoBackgroundView)
                self.addSubview(photoButtonView)
            }
        }
        drawingToolCollection.reloadData()
        drawingCVC.canvas.setNeedsDisplay()
    }
    
    
    @objc func pressedButtonLibrary() {
        print("button1")
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        drawingCVC.superViewController.present(imagePicker, animated: true)
    }
    
    @objc func pressedButtonCancel() {
        photoBackgroundView.removeFromSuperview()
        photoButtonView.removeFromSuperview()
    }
    
    @objc func pressedButtonConfirm() {
        print("confirm")
    }
    
    @objc func pressedButtonPreview() {
        print("preview")
    }
    
    @objc func canceledButtonPreview() {
        print("preview canceled")
    }
}

extension DrawingToolCollectionViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if (drawingCVC.canvas.photoTool.selectedPhoto == nil) {
                changePhotoButtonActivated()
            }
            drawingCVC.canvas.photoTool.selectedPhoto = pickedImage
            drawingCVC.canvas.setNeedsDisplay()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func changePhotoButtonActivated() {
        let button = photoButtonView.subviews[0] as! UIButton
        photoButtonView.subviews[0].frame = CGRect(
            x: 0,
            y: 0,
            width: (photoButtonView.bounds.width / 4) - 5,
            height: photoButtonView.bounds.height
        )
        button.backgroundColor = .white
        button.tintColor = .black
        button.setImage(
            UIImage.init(
                systemName: "arrow.triangle.2.circlepath",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal
        )
        
        let previewButton = UIButton(
            frame: CGRect(
                x: (photoButtonView.bounds.width / 4) + 2.5,
                y: 0,
                width: (photoButtonView.bounds.width / 4) - 5,
                height: photoButtonView.bounds.height
            )
        )
        setSideCorner(target: previewButton, side: "all", radius: previewButton.bounds.height / 2)
        setViewShadow(target: previewButton, radius: 10, opacity: 0.8)
        previewButton.backgroundColor = .darkGray
        previewButton.setImage(
            UIImage.init(
                systemName: "eye",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
        previewButton.tintColor = .white
        previewButton.addTarget(self, action: #selector(pressedButtonPreview), for: .touchDown)
        previewButton.addTarget(self, action: #selector(canceledButtonPreview), for: .touchUpOutside)
        previewButton.addTarget(self, action: #selector(canceledButtonPreview), for: .touchUpInside)
        
        let confirmButton = UIButton(
            frame: CGRect(
                x: (photoButtonView.bounds.width / 4 * 2) + 2.5,
                y: 0,
                width: (photoButtonView.bounds.width / 4) - 5,
                height: photoButtonView.bounds.height
            )
        )
        setSideCorner(target: confirmButton, side: "all", radius: confirmButton.bounds.height / 2)
        setViewShadow(target: confirmButton, radius: 10, opacity: 0.8)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.setImage(
            UIImage.init(
                systemName: "checkmark",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)), for: .normal)
        confirmButton.tintColor = .white
        confirmButton.addTarget(self, action: #selector(pressedButtonConfirm), for: .touchDown)
        
        
        photoButtonView.addSubview(previewButton)
        photoButtonView.addSubview(confirmButton)
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
