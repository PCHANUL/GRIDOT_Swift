//
//  ColorPaletteCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/05.
//

import UIKit

class ColorPaletteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var currentColor: UIView!
    @IBOutlet weak var colorCollectionList: UICollectionView!
    @IBOutlet weak var colorPickerButton: UIButton!
    
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var slider: UISlider!
    var viewController: UIViewController!
    
    var canvas: Canvas!
    var colorPaletteViewModel: ColorPaletteListViewModel!
    var sliderGradient: Gradient!
    var BGGradient: CAGradientLayer!
    var selectedColor: UIColor!
    var selectedColorIndex: Int!
    var panelCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = sliderView.bounds.height
        func thumbImage() -> UIImage {
            let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: width * 2, height: width))
            let thumb = UIView(frame: CGRect(x: 0, y: 0, width: width / 4, height: width))
            thumb.backgroundColor = .white
            thumb.layer.shadowColor = UIColor.black.cgColor
            thumb.layer.shadowOffset = .zero
            thumb.layer.shadowRadius = 3
            thumb.layer.shadowOpacity = 0.5
            thumb.center = CGPoint(x: thumbView.frame.size.width  / 2,
                                   y: thumbView.frame.size.height / 2)
            thumbView.addSubview(thumb)
            let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
            return renderer.image { context in
                thumbView.layer.render(in: context.cgContext)
            }
        }
        
        let sliderThumbImage = thumbImage()
        slider.setThumbImage(sliderThumbImage, for: .normal)
        slider.setThumbImage(sliderThumbImage, for: .highlighted)
        slider.addTarget(self, action: #selector(onSliderValChanged), for: .valueChanged)
        
        // 슬라이더 탭 제스쳐 추가
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        self.slider.addGestureRecognizer(tapGestureRecognizer)
        
        // 그림자 설정
        currentColor.layer.shadowColor = UIColor.black.cgColor
        currentColor.layer.shadowOffset = CGSize(width: 0, height: 4)
        currentColor.layer.shadowRadius = 5
        currentColor.layer.shadowOpacity = 0.2
        currentColor.layer.masksToBounds = false
        
        // 순서 변경을 위한 제스쳐
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        colorCollectionList.addGestureRecognizer(gesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let viewModel = colorPaletteViewModel else { return }
        selectedColor = viewModel.currentColor.uicolor
        canvas.selectedColor = selectedColor
        sliderView.clipsToBounds = true
        updateColorBasedCanvasForThreeSection(true)
    }
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.sliderView)
        let widthOfSlider: CGFloat = slider.frame.size.width
        let newValue = ((pointTapped.x - sliderView.frame.size.width / 2) * (CGFloat(slider.maximumValue) * 2) / widthOfSlider)
        slider.setValue(Float(newValue), animated: true)
        changeBasedSliderValue()
        updateColorBasedCanvasForThreeSection(false)
    }
    
    func changeBasedSliderValue() {
        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0;
        self.selectedColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        
        let sValue = CGFloat(slider.value)
        let vSat: CGFloat = (sat / 2) * sValue
        let vBri: CGFloat = (bri / 2) * sValue
        let adjustedColor = UIColor.init(hue: hue, saturation: min(sat + vSat, 1), brightness: min(bri + vBri, 1), alpha: alpha)
        canvas.selectedColor = adjustedColor
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                print("began")
            case .moved:
                changeBasedSliderValue()
                updateColorBasedCanvasForThreeSection(false)
            case .ended:
                print("ended")
            default:
                break
            }
        }
    }
    
    func changeSliderGradientColor(_ selectedColor: UIColor) {
        let subLayers = sliderView.layer.sublayers!
        if subLayers.count == 1 {
            self.sliderGradient = Gradient(color: selectedColor)
            self.BGGradient = sliderGradient.gl
            sliderView.layer.insertSublayer(BGGradient, at: 0)
            BGGradient.frame = sliderView.bounds
        }
        else {
            let oldLayer = subLayers[0]
            self.sliderGradient = Gradient(color: selectedColor)
            self.BGGradient = sliderGradient.gl
            sliderView.layer.replaceSublayer(oldLayer, with: BGGradient)
            BGGradient.frame = sliderView.bounds
        }
        slider.setValue(0, animated: true)
        sliderView.setNeedsLayout()
        sliderView.setNeedsDisplay()
    }
    
    func updateColorBasedCanvasForThreeSection(_ initSlider: Bool) {
        guard let color = canvas.selectedColor else { return }

        if (initSlider) { changeSliderGradientColor(color) }
        currentColor.tintColor = color
        colorCollectionList.reloadData()
    }
    
    @IBAction func addColorButton(_ sender: Any) {
        guard let color = currentColor.tintColor.hexa else { return }
        colorPaletteViewModel.addColor(color: color)
        colorPaletteViewModel.selectedColorIndex += 1;
        colorCollectionList.reloadData()
    }
    
    @IBAction func openColorList(_ sender: Any) {
        let paletteListPopupVC = UIStoryboard(name: "ColorPaletteListPopup", bundle: nil).instantiateViewController(identifier: "ColorPaletteListPopupViewController") as! ColorPaletteListPopupViewController
        paletteListPopupVC.positionY = self.frame.maxY - self.frame.height + 10 - panelCollectionView.contentOffset.y
        paletteListPopupVC.modalPresentationStyle = .overFullScreen
        paletteListPopupVC.colorPaletteViewModel = colorPaletteViewModel
        paletteListPopupVC.colorCollectionList = colorCollectionList
        self.window?.rootViewController?.present(paletteListPopupVC, animated: false, completion: nil)
    }
    
    @IBAction func tappedCurrentColor(_ sender: Any) {
        print("clicked")
        let picker = UIColorPickerViewController()
        picker.delegate = self
        picker.supportsAlpha = false
        picker.selectedColor = currentColor.tintColor
        viewController.present(picker, animated: true, completion: nil)
    }
    
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
        return colorPaletteViewModel.currentPalette.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        cell.color.layer.backgroundColor = colorPaletteViewModel.currentPalette.colors[indexPath.row].uicolor?.cgColor
        if colorPaletteViewModel.selectedColorIndex != indexPath.row {
            cell.color.layer.borderWidth = 0
        } else {
            cell.color.layer.borderColor = UIColor.white.cgColor
            cell.color.layer.borderWidth = 2
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ColorPickerHeader", for: indexPath) as! ColorPickerHeader
        header.colorAddButton.backgroundColor = canvas.selectedColor
        return header
    }
}

extension ColorPaletteCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedColor = colorPaletteViewModel.currentPalette.colors[indexPath.row].uicolor else { return }

        changeSliderGradientColor(selectedColor);
        
        colorPaletteViewModel.selectedColorIndex = indexPath.row
        self.selectedColor = selectedColor
        canvas.selectedColor = selectedColor
        updateColorBasedCanvasForThreeSection(true)
    }
}

extension ColorPaletteCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = colorCollectionList.frame.height / 2
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sideLength = colorCollectionList.frame.height / 2
        return CGSize(width: sideLength, height: sideLength / 2)
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
        let color = viewController.selectedColor
        self.selectedColor = color
        canvas.selectedColor = color
        updateColorBasedCanvasForThreeSection(true)
    }
}

class ColorPickerHeader: UICollectionReusableView {
    @IBOutlet weak var colorAddButton: UIButton!
}

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var color: UIView!
}
