//
//  ColorPickerCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/05.
//

import UIKit

class ColorPickerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var currentColor: UIView!
    @IBOutlet weak var colorCollectionList: UICollectionView!
    @IBOutlet weak var colorPickerButton: UIButton!
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var slider3: UISlider!
    @IBOutlet weak var sliderBackground: UIView!
    
    var canvas: Canvas!
    var selectedStackColor: Int = 2
    
    func addBottomBorderWithColor() {
        let border = CALayer()
        border.backgroundColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - 5, width: self.frame.size.width, height: 5)
        self.layer.addSublayer(border)
    }
    
    var viewController: UIViewController!
    var selectedColor: UIColor = UIColor.white
    var selectedColorIndex: Int!
    var colorPaletteViewModel: ColorPaletteListViewModel!
    
    var backgroundLayer3: Gradient!
    var BGGradient: CAGradientLayer!
    
    class Gradient {
        var gl: CAGradientLayer!
        
        init(color: UIColor) {
            self.gl = CAGradientLayer()
            setColor(color: color)
            self.gl.locations = [0.0, 1.0]
            self.gl.startPoint = CGPoint(x: 0, y: 0)
            self.gl.endPoint = CGPoint(x: 1, y: 0)
        }
        
        func setColor(color: UIColor) {
            var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0;
            color.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
            
            let vSat = sat / 2, vBri = bri / 2;
            let colorB = UIColor(hue: hue, saturation: sat - vSat, brightness: bri - vBri, alpha: alpha).cgColor
            let colorL = UIColor(hue: hue, saturation: min(sat + vSat, 1), brightness: min(bri + vBri, 1), alpha: alpha).cgColor
            self.gl.colors = [colorB, colorL]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = view3.bounds.height * 0.7
        func thumbImage() -> UIImage {
            let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
            let unit = thumbView.frame.height
            thumbView.backgroundColor = .white
            thumbView.layer.borderWidth = 1
            thumbView.layer.borderColor = UIColor.darkGray.cgColor
            thumbView.layer.cornerRadius = unit / 2
            let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
            return renderer.image { context in
                thumbView.layer.render(in: context.cgContext)
            }
        }
        
        let image3 = thumbImage()
        slider3.setThumbImage(image3, for: .normal)
        slider3.setThumbImage(image3, for: .highlighted)
        slider3.addTarget(self, action: #selector(onSliderValChanged), for: .valueChanged)
        
        colorPaletteViewModel = ColorPaletteListViewModel()
        colorPaletteViewModel.colorCollectionList = colorCollectionList
        
        // 그림자 설정
        currentColor.layer.shadowColor = UIColor.black.cgColor
        currentColor.layer.masksToBounds = false
        currentColor.layer.shadowOffset = CGSize(width: 0, height: 4)
        currentColor.layer.shadowRadius = 5
        currentColor.layer.shadowOpacity = 0.2
        
        // 순서 변경을 위한 제스쳐
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        colorCollectionList.addGestureRecognizer(gesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = view3.bounds.height / 2
        view3.layer.cornerRadius = width
        view3.clipsToBounds = true
        updateColorBasedCanvasForThreeSection(true)
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                print("began")
            case .moved:
                var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0;
                self.selectedColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
                
                let sValue = CGFloat(slider.value)
                let vSat: CGFloat = (sat / 2) * sValue
                let vBri: CGFloat = (bri / 2) * sValue
                let adjustedColor = UIColor.init(hue: hue, saturation: min(sat + vSat, 1), brightness: min(bri + vBri, 1), alpha: alpha)
                canvas.selectedColor = adjustedColor
                updateColorBasedCanvasForThreeSection(false)
            case .ended:
                print("ended")
            default:
                break
            }
        }
    }
    
    func changeSliderGradientColor(_ selectedColor: UIColor) {
        let subLayers = view3.layer.sublayers!
        if subLayers.count == 1 {
            self.backgroundLayer3 = Gradient(color: selectedColor)
            self.BGGradient = backgroundLayer3.gl
            view3.layer.insertSublayer(BGGradient, at: 0)
            BGGradient.frame = view3.bounds
        }
        else {
            let oldLayer = subLayers[0]
            self.backgroundLayer3 = Gradient(color: selectedColor)
            self.BGGradient = backgroundLayer3.gl
            view3.layer.replaceSublayer(oldLayer, with: BGGradient)
            BGGradient.frame = view3.bounds
        }
        view3.setNeedsLayout()
        view3.setNeedsDisplay()
    }
    
    func updateColorBasedCanvasForThreeSection(_ initSlider: Bool) {
        let color = canvas.selectedColor
        changeSliderGradientColor(color)
        if (initSlider) { slider3.setValue(0, animated: true) }
        currentColor.tintColor = color
        colorCollectionList.reloadData()
    }
    
    @IBAction func addColorButton(_ sender: Any) {
        guard let color = currentColor.tintColor.hexa else { return }
        colorPaletteViewModel.addColor(color: color)
        self.selectedColorIndex += 1;
        colorCollectionList.reloadData()
    }
    
    @IBAction func openColorList(_ sender: Any) {
        let paletteListPopupVC = UIStoryboard(name: "ColorPaletteListPopup", bundle: nil).instantiateViewController(identifier: "ColorPaletteListPopupViewController") as! ColorPaletteListPopupViewController
        
        paletteListPopupVC.positionY = self.frame.maxY
            - self.frame.height + 10
        paletteListPopupVC.modalPresentationStyle = .overFullScreen
        paletteListPopupVC.colorPaletteViewModel = colorPaletteViewModel
        paletteListPopupVC.colorCollectionList = colorCollectionList
        self.window?.rootViewController?.present(paletteListPopupVC, animated: true, completion: nil)
    }
    
    @IBAction func tappedCurrentColor(_ sender: Any) {
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

extension ColorPickerCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPaletteViewModel.currentPalette.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        cell.color.layer.backgroundColor = colorPaletteViewModel.currentPalette.colors[indexPath.row].uicolor?.cgColor
        if self.selectedColorIndex == nil || self.selectedColorIndex != indexPath.row {
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

extension ColorPickerCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedColor = colorPaletteViewModel.currentPalette.colors[indexPath.row].uicolor else { return }

        changeSliderGradientColor(selectedColor);
        
        self.selectedColorIndex = indexPath.row
        self.selectedColor = selectedColor
        canvas.selectedColor = selectedColor
        updateColorBasedCanvasForThreeSection(true)
    }
}

extension ColorPickerCollectionViewCell: UICollectionViewDelegateFlowLayout {
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
        let swappedColor = paletteColor.swapColor(a: sourceIndexPath.row, b: destinationIndexPath.row)
        colorPaletteViewModel.updateSelectedPalette(palette: swappedColor)
    }
}

extension ColorPickerCollectionViewCell: UIColorPickerViewControllerDelegate {
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

class ColorPaletteListViewModel {
    private var colorPaletteList: [ColorPalette] = []
    var selectedPaletteIndex: Int = 0
    
    var nameLabel: String!
    var colorCollectionList: UICollectionView!
    var paletteCollectionList: UICollectionView!
    
    init() {
        // 기본 팔레트를 넣거나 저장되어있는 팔레트를 불러옵니다
        colorPaletteList = [
            ColorPalette(name: "Fantasy 24", colors: ["#1f240a", "#39571c", "#a58c27", "#efac28", "#efd8a1", "#ab5c1c", "#183f39", "#ef692f", "#efb775", "#a56243", "#773421", "#724113", "#2a1d0d", "#392a1c", "#684c3c", "#927e6a", "#276468", "#ef3a0c", "#45230d", "#3c9f9c", "#9b1a0a", "#36170c", "#550f0a", "#300f0a"]),
            ColorPalette(name: "Sweetie 16", colors: ["#1a1c2c", "#5d275d", "#b13e53", "#ef7d57", "#ffcd75", "#a7f070", "#38b764", "#257179", "#29366f", "#3b5dc9", "#41a6f6", "#73eff7", "#f4f4f4", "#94b0c2", "#566c86", "#333c57"]),
            ColorPalette(name: "Vinik 24", colors: ["#000000", "#6f6776", "#9a9a97", "#c5ccb8", "#8b5580", "#c38890", "#a593a5", "#666092", "#9a4f50", "#c28d75", "#7ca1c0", "#416aa3", "#8d6268", "#be955c", "#68aca9", "#387080", "#6e6962", "#93a167", "#6eaa78", "#557064", "#9d9f7f", "#7e9e99", "#5d6872", "#433455"]),
            ColorPalette(name: "Resurrect 64", colors: ["#2e222f", "#3e3546", "#625565", "#966c6c", "#ab947a", "#694f62", "#7f708a", "#9babb2", "#c7dcd0", "#ffffff", "#6e2727", "#b33831", "#ea4f36", "#f57d4a", "#ae2334", "#e83b3b", "#fb6b1d", "#f79617", "#f9c22b", "#7a3045", "#9e4539", "#cd683d", "#e6904e", "#fbb954", "#4c3e24", "#676633", "#a2a947", "#d5e04b", "#fbff86", "#165a4c", "#239063", "#1ebc73", "#91db69", "#cddf6c", "#313638", "#374e4a", "#547e64", "#92a984", "#b2ba90", "#0b5e65", "#0b8a8f", "#0eaf9b", "#30e1b9", "#8ff8e2", "#323353", "#484a77", "#4d65b4", "#4d9be6", "#8fd3ff", "#45293f", "#6b3e75", "#905ea9", "#a884f3", "#eaaded", "#753c54", "#a24b6f", "#cf657f", "#ed8099", "#831c5d", "#c32454", "#f04f78", "#f68181", "#fca790", "#fdcbb0"]),
        ]
        nameLabel = colorPaletteList[selectedPaletteIndex].name
    }
    
    var currentPalette: ColorPalette {
        return colorPaletteList[selectedPaletteIndex]
    }
    
    var numsOfPalette: Int {
        return colorPaletteList.count
    }
    
    func item(_ index: Int) -> ColorPalette {
        return colorPaletteList[index]
    }
    
    func changeSelectedPalette(index: Int) {
        selectedPaletteIndex = index
        nameLabel = currentPalette.name
        reloadColorListAndPaletteList()
    }
    
    func reloadColorListAndPaletteList() {
        colorCollectionList.reloadData()
        if paletteCollectionList != nil {
            paletteCollectionList.reloadData()
        }
    }
    
    // palette
    func newPalette() {
        let newItem = ColorPalette(name: "New Palette", colors: ["#FFFF00"])
        colorPaletteList.insert(newItem, at: 0)
    }
    
    func renamePalette(index: Int, newName: String) {
        colorPaletteList[index].renamePalette(newName: newName)
        if selectedPaletteIndex == index {
            nameLabel = newName
        }
    }
    
    func insertPalette(index: Int, palette: ColorPalette) {
        colorPaletteList.insert(palette, at: index)
    }
    
    func deletePalette(index: Int) -> ColorPalette {
        let removed = colorPaletteList.remove(at: index)
        selectedPaletteIndex -= selectedPaletteIndex == 0 ? 0 : 1
        if numsOfPalette == 0 { newPalette() }
        return removed
    }
    
    func updateSelectedPalette(palette: ColorPalette) {
        colorPaletteList[selectedPaletteIndex] = palette
        nameLabel = palette.name
        reloadColorListAndPaletteList()
    }
    
    func swapPalette(a: Int, b: Int) {
        let bPalette = colorPaletteList[b]
        colorPaletteList[b] = colorPaletteList[a]
        colorPaletteList[a] = bPalette
        reloadColorListAndPaletteList()
    }
    
    // color
    func addColor(color: String) {
        colorPaletteList[selectedPaletteIndex].addColor(color: color)
    }
    
    func updateColor(color: String, colorIndex: Int) {
        colorPaletteList[selectedPaletteIndex].updateColor(index: colorIndex, color: color)
    }
    
    func removeColor(colorIndex: Int) {
        let _ = colorPaletteList[selectedPaletteIndex].removeColor(index: colorIndex)
    }
}

struct ColorPalette {
    var name: String
    var colors: [String]
    
    mutating func addColor(color: String) {
        colors.insert(color, at: 0)
    }
    
    mutating func insertColor(index: Int, color: String) {
        colors.insert(color, at: index)
    }
    
    mutating func updateColor(index: Int, color: String) {
        colors[index] = color
    }
    
    mutating func removeColor(index: Int) -> String {
        return colors.remove(at: index)
    }
    
    mutating func swapColor(a: Int, b: Int) -> ColorPalette {
        let bColor = colors[b]
        updateColor(index: b, color: colors[a])
        updateColor(index: a, color: bColor)
        return self
    }
    
    mutating func renamePalette(newName: String) {
        name = newName
    }
}
