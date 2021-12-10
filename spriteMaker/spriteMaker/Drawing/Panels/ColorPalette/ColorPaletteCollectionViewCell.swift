//
//  ColorPaletteCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/05.
//

import UIKit
import CoreData

class ColorPaletteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var currentColor: UIImageView!
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var colorPickerLabel: UILabel!
    @IBOutlet weak var colorCollectionList: UICollectionView!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderView: UIView!
    var viewController: UIViewController!
    var panelCollectionView: UICollectionView!
    
    var canvas: Canvas!
    var colorPaletteViewModel: ColorPaletteListViewModel!
    var sliderGradient: Gradient!
    var BGGradient: CAGradientLayer!
    var selectedColor: UIColor!
    var selectedColorIndex: Int!
    var isInited: Bool = false
    var pickerColor: String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let sliderThumbImage = thumbImage()
        slider.setThumbImage(sliderThumbImage, for: .normal)
        slider.setThumbImage(sliderThumbImage, for: .highlighted)
        slider.addTarget(self, action: #selector(onSliderValChanged), for: .valueChanged)
        setViewShadow(target: currentColor, radius: 4, opacity: 0.2)
        
        // add gesture slider tap
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        self.slider.addGestureRecognizer(tapGestureRecognizer)
        
        // add gesture reorder colors
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        colorCollectionList.addGestureRecognizer(gesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectedColor = currentColor.tintColor
        
        sliderView.clipsToBounds = true
        canvas.selectedColor = selectedColor
        colorPickerLabel.text = selectedColor.hexa
        colorPickerLabel.textColor = getColorBasedOnColorBrightness(selectedColor)
        changeSliderGradientColor(selectedColor)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        colorCollectionList.reloadData()
    }
    
    // get thumbView image
    func thumbImage() -> UIImage {
        let width = sliderView.bounds.height
        let thumb = UIView(frame: CGRect(x: 0, y: 0, width: width / 4, height: width))
        let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: width * 2, height: width))
        
        setViewShadow(target: thumb, radius: 3, opacity: 0.5)
        thumb.backgroundColor = .white
        thumb.center = CGPoint(x: thumbView.frame.size.width  / 2, y: thumbView.frame.size.height / 2)
        thumbView.addSubview(thumb)
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { context in
            thumbView.layer.render(in: context.cgContext)
        }
    }
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint
        let widthOfSlider: CGFloat
        let newValue: CGFloat
        
        pointTapped = gestureRecognizer.location(in: self.sliderView)
        widthOfSlider = slider.frame.size.width
        newValue = ((pointTapped.x - sliderView.frame.size.width / 2) * (CGFloat(slider.maximumValue) * 2) / widthOfSlider)
        slider.setValue(Float(newValue), animated: true)
        canvas.selectedColor = changeBasedOnSliderValue()
        updateColorBasedCanvasForThreeSection(false)
        canvas.setNeedsDisplay()
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .moved:
                canvas.selectedColor = changeBasedOnSliderValue()
                updateColorBasedCanvasForThreeSection(false)
                canvas.setNeedsDisplay()
            case .ended:
                break
            default:
                break
            }
        }
    }
    
    func changeBasedOnSliderValue() -> UIColor {
        var hue: CGFloat
        var sat: CGFloat
        var bri: CGFloat
        var alpha: CGFloat
        let sValue: CGFloat
        let vSat: CGFloat
        let vBri: CGFloat
        let newColor: UIColor
        
        hue = 0
        sat = 0
        bri = 0
        alpha = 0
        selectedColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        
        sValue = CGFloat(slider.value)
        vSat = (sat / 2) * sValue
        vBri = (bri / 2) * sValue
        newColor = UIColor.init(hue: hue, saturation: min(sat + vSat, 1), brightness: min(bri + vBri, 1), alpha: alpha)
        return newColor
    }
    
    func changeSliderGradientColor(_ selectedColor: UIColor) {
        let subLayers = sliderView.layer.sublayers!
        if subLayers.count == 1 {
            self.sliderGradient = Gradient(color: selectedColor)
            self.BGGradient = sliderGradient.gl
            sliderView.layer.insertSublayer(BGGradient, at: 0)
            BGGradient.frame = sliderView.bounds
        } else {
            let oldLayer = subLayers[0]
            self.sliderGradient = Gradient(color: selectedColor)
            self.BGGradient = sliderGradient.gl
            sliderView.layer.replaceSublayer(oldLayer, with: BGGradient)
            BGGradient.frame = sliderView.bounds
        }
        sliderView.setNeedsLayout()
        sliderView.setNeedsDisplay()
    }
    
    // 선택된 색을 기준으로 원, 리스트, 슬라이더, 캔버스 업데이트
    func updateColorBasedCanvasForThreeSection(_ initSlider: Bool) {
        guard let color = canvas.selectedColor else { return }
        if (initSlider) {
            changeSliderGradientColor(color)
            selectedColor = color
        }
        currentColor.tintColor = color
        colorCollectionList.reloadData()
        colorPickerLabel.text = canvas.selectedColor.hexa
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
        colorPaletteViewModel.addColor(color: color)
        colorPaletteViewModel.selectedColorIndex += 1;
        colorCollectionList.reloadData()
    }
    
    @IBAction func openColorList(_ sender: Any) {
        guard let paletteListPopupVC = UIStoryboard(name: "ColorPaletteListPopup", bundle: nil).instantiateViewController(identifier: "ColorPaletteListPopupViewController") as? ColorPaletteListPopupViewController else { return }
        paletteListPopupVC.positionY = self.frame.maxY - self.frame.height + 10 - panelCollectionView.contentOffset.y
        paletteListPopupVC.modalPresentationStyle = .overFullScreen
        paletteListPopupVC.colorCollectionList = colorCollectionList
        self.window?.rootViewController?.present(paletteListPopupVC, animated: false, completion: nil)
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
}

extension ColorPaletteCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(CoreData.shared.selectedColorArr.count)
        return CoreData.shared.selectedColorArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else { return UICollectionViewCell() }
        guard let palette = CoreData.shared.selectedPalette else { return cell }
        guard let colors = palette.colors else { return cell }
        guard let cellColor = colors[indexPath.row].uicolor else { return cell }
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
            changeSelectedColor(index: indexPath.row)
        }
    }
    
    func changeSelectedColor(index: Int) {
        initPickerColor()
        CoreData.shared.selectedColorIndex = index
        canvas.selectedColor = CoreData.shared.selectedColor?.uicolor
        updateColorBasedCanvasForThreeSection(true)
        slider.setValue(0, animated: true)
        canvas.setNeedsDisplay()
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
        var paletteColor = colorPaletteViewModel.currentPalette
        let currentColor = paletteColor.removeColor(index: sourceIndexPath.row)
        paletteColor.insertColor(index: destinationIndexPath.row, color: currentColor)
        colorPaletteViewModel.updateSelectedPalette(palette: paletteColor)
    }
}

extension ColorPaletteCollectionViewCell: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color: UIColor

        color = viewController.selectedColor
        self.selectedColor = color
        canvas.selectedColor = color
        setPickerColor(color)
        updateColorBasedCanvasForThreeSection(true)
        canvas.setNeedsDisplay()
    }
    
    func setPickerColor(_ color: UIColor) {
        pickerColor = color.hexa
        selectedColorIndex = -1
    }
    
    func initPickerColor() {
        pickerColor = nil
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
