//
//  ColorPaletteCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/05.
//

import UIKit
import CoreData
import RxSwift

class ColorPaletteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var currentColor: UIImageView!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var colorPickerLabel: UILabel!
    @IBOutlet weak var colorCollectionList: UICollectionView!
    @IBOutlet weak var sliderView: GradientSliderView!
    var viewController: UIViewController!
    var panelCollectionView: UICollectionView!
    
    var canvas: Canvas!
    var selectedColor: UIColor!
    var selectedColorIndex: Int!
    var isInited: Bool = false
    var pickerColor: String? = nil
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setViewShadow(target: currentColor, radius: 4, opacity: 0.2)

        // add gesture reorder colors
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        colorCollectionList.addGestureRecognizer(gesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if (isInited == false) {
            initColorPaletteCVC()
            isInited = true
        }
        colorPickerLabel.textColor = getColorBasedOnColorBrightness(currentColor.tintColor)
    }

    func initColorPaletteCVC() {
        selectedColor = currentColor.tintColor
        canvas.selectedColor = selectedColor
        colorPickerLabel.text = selectedColor.hexa
        sliderView.changeSliderGradientColor(selectedColor)
        updateColorBasedCanvasForThreeSection(true)
        
        CoreData.shared.paletteIndexObservable
            .subscribe { [weak self] _ in
                self?.pickerColor = nil
                self?.updateColorBasedCanvasForThreeSection(true)
                self?.sliderView.slider.setValue(0, animated: true)
            }.disposed(by: disposeBag)
        
        CoreData.shared.colorIndexObservable
            .subscribe { [weak self] value in
                if let color = CoreData.shared.selectedColor?.uicolor {
                    self?.canvas.selectedColor = color
                }
                self?.pickerColor = nil
                self?.updateColorBasedCanvasForThreeSection(true)
                self?.sliderView.slider.setValue(0, animated: true)
                self?.canvas.setNeedsDisplay()
                self?.setNeedsDisplay()
            }.disposed(by: disposeBag)
        
        sliderView.slider.rx
            .controlEvent([.touchDown, .touchDragInside])
            .subscribe { [weak self] _ in
                if let color = self?.sliderView.sliderColor {
                    self?.canvas.selectedColor = color
                    self?.canvas.setNeedsDisplay()
                }
                self?.updateColorBasedCanvasForThreeSection(false)
            }.disposed(by: disposeBag)
    }
    
    // 선택된 색을 기준으로 원, 리스트, 슬라이더, 캔버스 업데이트
    func updateColorBasedCanvasForThreeSection(_ initSlider: Bool) {
        let color = canvas.selectedColor
        if (initSlider) {
            sliderView.changeSliderGradientColor(color)
            selectedColor = color
        }
        currentColor.tintColor = color
        colorCollectionList.reloadData()
        colorPickerLabel.text = canvas.selectedColor.hexa
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        colorCollectionList.reloadData()
    }
    
    // 길게 눌러서 색상순서 변경
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
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
        viewController.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addColorButton(_ sender: Any) {
        guard let color = currentColor.tintColor.hexa else { return }
        CoreData.shared.addColor(color: color)
        CoreData.shared.selectedColorIndex += 1;
        colorCollectionList.reloadData()
    }
    
    @IBAction func openColorList(_ sender: Any) {
        guard let paletteListPopupVC = UIStoryboard(name: "ColorPaletteListPopup", bundle: nil).instantiateViewController(identifier: "ColorPaletteListPopupViewController") as? ColorPaletteListPopupViewController else { return }
        paletteListPopupVC.positionY = self.frame.maxY - self.frame.height + 10 - panelCollectionView.contentOffset.y
        paletteListPopupVC.modalPresentationStyle = .overFullScreen
        paletteListPopupVC.colorCollectionList = colorCollectionList
        self.window?.rootViewController?.present(paletteListPopupVC, animated: false, completion: nil)
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
            popupAlertMessage(
                targetVC: viewController,
                title: "색 제거",
                message: "선택되어있는 색을 제거하시겠습니까?"
            ) { [self] in
                CoreData.shared.removeColor(index: indexPath.row)
                CoreData.shared.selectedColorIndex = indexPath.row
                colorCollectionList.reloadData()
                popupErrorMessage(targetVC: viewController, title: "제거 완료", message: "제거되었습니다")
            }
        } else if (CoreData.shared.selectedColorIndex == indexPath.row) {
            cell.image.image = UIImage(systemName: "trash.fill")
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false)
            { (Timer) in
                cell.image.image = UIImage(systemName: "checkmark")
                Timer.invalidate()
            }
        } else {
            CoreData.shared.selectedColorIndex = indexPath.row
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
        updateColorBasedCanvasForThreeSection(true)
    }
}

extension ColorPaletteCollectionViewCell: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        canvas.selectedColor = selectedColor
        setPickerColor(selectedColor)
        updateColorBasedCanvasForThreeSection(true)
        sliderView.slider.value = 0
        canvas.setNeedsDisplay()
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
