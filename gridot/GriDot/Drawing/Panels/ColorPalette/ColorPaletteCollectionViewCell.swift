//
//  ColorPaletteCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/05.
//

import UIKit
import CoreData
import RxSwift
import RxGesture

class ColorPaletteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var currentColor: UIImageView!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var colorPickerLabel: UILabel!
    @IBOutlet weak var colorCollectionList: UICollectionView!
    @IBOutlet weak var sliderView: GradientSliderView!
    var drawingVC: DrawingViewController!
    var canvas: Canvas!
    var selectedColor: UIColor!
    var selectedColorIndex: Int!
    var pickerColor: String? = nil
    
    var isInited: Bool = false
    let disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (isInited == false) {
            setViewShadow(target: currentColor, radius: 4, opacity: 0.2)
            canvas = drawingVC.canvas
            initColorPaletteCVC()
            isInited = true
        }
    }

    func initColorPaletteCVC() {
        selectedColor = currentColor.tintColor
        canvas.selectedColor = selectedColor
        sliderView.changeSliderGradientColor(selectedColor)
        
        sliderView.slider.rx
            .controlEvent([.touchDown, .touchDragInside])
            .subscribe { [weak self] _ in
                if let color = self?.sliderView.sliderColor {
                    self?.canvas.selectedColor = color
                }
            }.disposed(by: disposeBag)
        
        CoreData.shared.paletteIndexObservable
            .subscribe { [weak self] _ in
                self?.pickerColor = nil
                self?.initSliderColor()
            }.disposed(by: disposeBag)
        
        CoreData.shared.colorIndexObservable
            .subscribe { [weak self] value in
                if let color = CoreData.shared.selectedColor?.uicolor {
                    self?.canvas.selectedColor = color
                }
                self?.pickerColor = nil
                self?.initSliderColor()
                self?.setNeedsDisplay()
            }.disposed(by: disposeBag)
        
        canvas.canvasColorObservable
            .subscribe { [weak self] uiColor in
                if let color = uiColor.element {
                    self?.colorPickerLabel.text = color.hexa
                    self?.colorPickerLabel.textColor = getColorBasedOnColorBrightness(color)
                    self?.currentColor.tintColor = color
                }
                self?.colorCollectionList.reloadData()
            }.disposed(by: disposeBag)
        
        colorCollectionList.rx
            .longPressGesture()
            .subscribe(onNext: handleLongPressGesture)
            .disposed(by: disposeBag)
    }
    
    func initSliderColor() {
        selectedColor = canvas.selectedColor
        sliderView.slider.setValue(0, animated: true)
        sliderView.changeSliderGradientColor(selectedColor)
    }
    
    func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        let collectionView = colorCollectionList
        
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
    
    @IBAction func tappedCurrentColor(_ sender: Any) {
        let picker = UIColorPickerViewController()
        picker.delegate = self
        picker.supportsAlpha = false
        picker.selectedColor = currentColor.tintColor
        drawingVC.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addColorButton(_ sender: Any) {
        guard let color = currentColor.tintColor.hexa else { return }
        CoreData.shared.addColor(color: color)
        CoreData.shared.selectedColorIndex += 1;
        colorCollectionList.reloadData()
    }
    
    @IBAction func openColorList(_ sender: Any) {
        guard let paletteListPopupVC = UIStoryboard(name: "ColorPaletteListPopup", bundle: nil).instantiateViewController(identifier: "ColorPaletteListPopupViewController") as? ColorPaletteListPopupViewController else { return }
        paletteListPopupVC.positionY = getPopupPosition().y
        paletteListPopupVC.modalPresentationStyle = .overFullScreen
        self.window?.rootViewController?.present(paletteListPopupVC, animated: false, completion: nil)
    }
    
    private func getPopupPosition() -> CGPoint {
        var pos = CGPoint(x: 0, y: 0)
        
        pos.y += self.frame.minY + 10
        pos.y += drawingVC.navigationController?.navigationBar.frame.height ?? 0
        pos.y -= drawingVC.panelCollectionView.contentOffset.y
        
        return pos
    }
}

extension ColorPaletteCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreData.shared.selectedColorArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else { return UICollectionViewCell() }
        guard let palette = CoreData.shared.selectedPalette else { return cell }
        guard let cellColor = palette.colors![indexPath.row].uicolor else { return cell }
        let isSelectedCell = CoreData.shared.selectedColorIndex == indexPath.row
        
        cell.image.isHidden = !isSelectedCell
        cell.image.tintColor = getColorBasedOnColorBrightness(cellColor)
        cell.color.layer.backgroundColor = cellColor.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ColorPickerHeader", for: indexPath) as? ColorPickerHeader else { return UICollectionReusableView() }
        header.colorAddButton.backgroundColor = canvas.selectedColor
        header.colorAddButton.tintColor = getColorBasedOnColorBrightness(currentColor.tintColor)
        return header
    }
}

extension ColorPaletteCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = colorCollectionList.cellForItem(at: indexPath) as? ColorCell else { return }
        
        if (cell.image.image == UIImage(systemName: "trash.fill")) {
            popupRemoveColorAlert(index: indexPath.row)
        } else if (CoreData.shared.selectedColorIndex == indexPath.row) {
            changeColorCellIcon(cell: cell)
        } else {
            CoreData.shared.selectedColorIndex = indexPath.row
        }
    }
    
    func popupRemoveColorAlert(index: Int) {
        popupAlertMessage(
            targetVC: drawingVC,
            title: "색 제거",
            message: "선택되어있는 색을 제거하시겠습니까?"
        ) { [self] in
            CoreData.shared.removeColor(index: index)
            CoreData.shared.selectedColorIndex = index
            colorCollectionList.reloadData()
            popupErrorMessage(targetVC: drawingVC, title: "제거 완료", message: "제거되었습니다")
        }
    }
    
    func changeColorCellIcon(cell: ColorCell) {
        cell.image.image = UIImage(systemName: "trash.fill")
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false)
        { (Timer) in
            cell.image.image = UIImage(systemName: "checkmark")
            Timer.invalidate()
        }
    }
}

extension ColorPaletteCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = (colorCollectionList.frame.height / 2) - 1
        
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sideLength = colorCollectionList.frame.height / 2
        
        return CGSize(width: sideLength + 20, height: sideLength * 2)
    }
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let dst = destinationIndexPath.row
        let src = sourceIndexPath.row
        let selectedIndex = getSelectedIndexInReorderedContents(CoreData.shared.selectedColorIndex, src, dst)
        
        CoreData.shared.reorderFunc(itemAt: src, to: dst) { a, b in
            CoreData.shared.swapColorOfSelectedPalette(a, b)
        }
        CoreData.shared.selectedColorIndex = selectedIndex
        CoreData.shared.saveData(entity: .palette)
        initSliderColor()
    }
}

extension ColorPaletteCollectionViewCell: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        canvas.selectedColor = selectedColor
        initSliderColor()
        setPickerColor(selectedColor)
    }
    
    func setPickerColor(_ color: UIColor) {
        pickerColor = color.hexa
        selectedColorIndex = -1
    }
}

class ColorPickerHeader: UICollectionReusableView {
    @IBOutlet weak var colorAddButton: UIButton!
    @IBOutlet weak var colorListButton: UIButton!
    
    override func layoutSubviews() {
        setSideCorner(target: colorAddButton, side: "top", radius: colorAddButton.bounds.width / 5)
        setSideCorner(target: colorListButton, side: "bottom", radius: colorListButton.bounds.width / 5)
        setViewShadow(target: self, radius: 3, opacity: 0.2)
    }
}

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var color: UIView!
    var isInited: Bool = false
    
    override func layoutSubviews() {
        if (isInited == false) {
            isInited = true
            setSideCorner(target: color, side: "all", radius: color.frame.width / 5)
        }
    }
}
