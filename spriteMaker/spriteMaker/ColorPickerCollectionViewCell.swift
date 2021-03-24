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
    @IBOutlet weak var colorPickerNameLabel: UILabel!
    
    // color stack
    @IBOutlet weak var colorStack: UIStackView!
    @IBOutlet weak var colorB: UIButton!
    @IBOutlet weak var colorG: UIButton!
    @IBOutlet weak var colorM: UIButton!
    @IBOutlet weak var colorW: UIButton!
    
    @IBOutlet weak var slider: UISlider!{
        didSet{
            slider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var slider2: UISlider!{
        didSet{
            
            slider2.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }
    @IBOutlet weak var slider3: UISlider!{
        didSet{
            
            slider3.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }
    
    var canvas: Canvas!
    var selectedStackColor: Int = 2
    
    func changeSelectedColorStack(at index: Int) {
        let stack = [self.colorB, self.colorG, self.colorM, self.colorW]
        stack[selectedStackColor]?.layer.borderWidth = 0
        stack[index]?.layer.borderWidth = 1
        stack[index]?.layer.borderColor = UIColor.white.cgColor
        
        let pointerWidth = stack[index]!.bounds.width
        let pointerHeight = stack[index]!.bounds.height
        stackPointer.frame = CGRect(x: 0, y: pointerHeight + 2, width: pointerWidth, height: 2)
        stack[index]?.layer.addSublayer(stackPointer)
        selectedStackColor = index
        
        if canvas == nil { return }
        let color = UIColor(cgColor: (stack[index]?.layer.backgroundColor)!)
        canvas.selectedColor = color
        currentColor.tintColor = color
        selectedColor = color
        colorCollectionList.reloadData()
        canvas.setNeedsDisplay()
    }
    
    
    // selected color가 바뀌었을때 stack의 배경색이 바뀐다.
    func reloadStackColor() {
        
        // set recommended colors
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alphaHue: CGFloat = 0
        selectedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alphaHue)
        
        self.colorM.backgroundColor = selectedColor
        self.colorW.backgroundColor = UIColor.init(hue: hue, saturation: saturation - 0.1, brightness: brightness + 0.2, alpha: alpha)
        self.colorG.backgroundColor = UIColor.init(hue: hue, saturation: saturation - 0.1, brightness: brightness - 0.2, alpha: alpha)
        self.colorB.backgroundColor = UIColor.init(hue: hue, saturation: saturation - 0.2, brightness: brightness - 0.4, alpha: alpha)
        
        canvas.selectedColor = (selectedColor.hexa?.uicolor)!
        canvas.setNeedsDisplay()
    }
    
    func addBottomBorderWithColor() {
        let border = CALayer()
        border.backgroundColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - 5, width: self.frame.size.width, height: 5)
        self.layer.addSublayer(border)
    }
    
    var viewController: UIViewController!
    var selectedColor: UIColor = UIColor.white
    var colorPaletteViewModel: ColorPaletteListViewModel!
    var stackPointer: CALayer!
    
    class Gradient {
        var gl: CAGradientLayer!
        
        init() {
            let colorTop = UIColor(red: 192.0 / 255.0, green: 38.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0).cgColor
            let colorBottom = UIColor(red: 35.0 / 255.0, green: 2.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0).cgColor

            self.gl = CAGradientLayer()
            self.gl.colors = [colorTop, colorBottom]
            self.gl.locations = [0.0, 1.0]
            self.gl.startPoint = CGPoint(x: 0, y: 1)
            self.gl.endPoint = CGPoint(x: 1, y: 1)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let backgroundLayer = Gradient().gl
//        backgroundLayer!.frame = slider.bounds
//        slider.layer.addSublayer(backgroundLayer!)
//        slider.layer.cornerRadius = 5
//        slider2.layer.cornerRadius = 5
//        slider3.layer.cornerRadius = 5
        
        func thumbImage() -> UIImage {
            let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            thumbView.backgroundColor = .darkGray
            thumbView.layer.cornerRadius = thumbView.frame.height / 2
            let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
            return renderer.image { context in
                thumbView.layer.render(in: context.cgContext)
            }
        }
        
        let image = thumbImage()
        slider.setThumbImage(image, for: .normal)
        slider.setThumbImage(image, for: .highlighted)
        slider2.setThumbImage(image, for: .normal)
        slider2.setThumbImage(image, for: .highlighted)
        slider3.setThumbImage(image, for: .normal)
        slider3.setThumbImage(image, for: .highlighted)
        
        colorPaletteViewModel = ColorPaletteListViewModel(nameLabel: colorPickerNameLabel)
        colorPaletteViewModel.colorCollectionList = colorCollectionList
        
        colorM.layer.borderWidth = 1
        colorM.layer.borderColor = UIColor.white.cgColor
        stackPointer = CALayer()
        stackPointer.backgroundColor = UIColor.white.cgColor
        stackPointer.cornerRadius = 7
        
        let scaleFactor: Float = Float(UIScreen.main.bounds.width) / 500.0
        let fontSize = CGFloat(20.0 * scaleFactor)
        colorPickerNameLabel.font = colorPickerNameLabel.font.withSize(fontSize)
        
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
        changeSelectedColorStack(at: 2)
    }
    
    @IBAction func tappedStackColor(_ sender: UIButton) {
        let stackWidth = self.colorStack.frame.width / 4
        let selectedIndex = Int(round(sender.frame.minX / stackWidth))
        changeSelectedColorStack(at: selectedIndex)
    }
    
    @IBAction func addColorButton(_ sender: Any) {
        guard let color = currentColor.tintColor.hexa else { return }
        colorPaletteViewModel.addColor(color: color)
        colorCollectionList.reloadData()
    }
    
    @IBAction func openColorList(_ sender: Any) {
        let paletteListPopupVC = UIStoryboard(name: "ColorPaletteListPopup", bundle: nil).instantiateViewController(identifier: "ColorPaletteListPopupViewController") as! ColorPaletteListPopupViewController
        
        print(self, colorPickerNameLabel.layer.bounds.height, colorPickerNameLabel.font.pointSize)
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ColorPickerHeader", for: indexPath) as! ColorPickerHeader
        header.colorAddButton.backgroundColor = selectedColor
        return header
    }
}

extension ColorPickerCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedColor = colorPaletteViewModel.currentPalette.colors[indexPath.row].uicolor else { return }
        self.selectedColor = selectedColor
        reloadStackColor()
        changeSelectedColorStack(at: 2)
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
        selectedColor = viewController.selectedColor
        reloadStackColor()
        changeSelectedColorStack(at: 2)
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
    
    var nameLabel: UILabel!
    var colorCollectionList: UICollectionView!
    var paletteCollectionList: UICollectionView!
    
     
    init(nameLabel: UILabel) {
        // 기본 팔레트를 넣거나 저장되어있는 팔레트를 불러옵니다
        colorPaletteList = [
            ColorPalette(name: "Fantasy 24", colors: ["#1f240a", "#39571c", "#a58c27", "#efac28", "#efd8a1", "#ab5c1c", "#183f39", "#ef692f", "#efb775", "#a56243", "#773421", "#724113", "#2a1d0d", "#392a1c", "#684c3c", "#927e6a", "#276468", "#ef3a0c", "#45230d", "#3c9f9c", "#9b1a0a", "#36170c", "#550f0a", "#300f0a"]),
            ColorPalette(name: "Sweetie 16", colors: ["#1a1c2c", "#5d275d", "#b13e53", "#ef7d57", "#ffcd75", "#a7f070", "#38b764", "#257179", "#29366f", "#3b5dc9", "#41a6f6", "#73eff7", "#f4f4f4", "#94b0c2", "#566c86", "#333c57"]),
            ColorPalette(name: "Vinik 24", colors: ["#000000", "#6f6776", "#9a9a97", "#c5ccb8", "#8b5580", "#c38890", "#a593a5", "#666092", "#9a4f50", "#c28d75", "#7ca1c0", "#416aa3", "#8d6268", "#be955c", "#68aca9", "#387080", "#6e6962", "#93a167", "#6eaa78", "#557064", "#9d9f7f", "#7e9e99", "#5d6872", "#433455"]),
            ColorPalette(name: "Resurrect 64", colors: ["#2e222f", "#3e3546", "#625565", "#966c6c", "#ab947a", "#694f62", "#7f708a", "#9babb2", "#c7dcd0", "#ffffff", "#6e2727", "#b33831", "#ea4f36", "#f57d4a", "#ae2334", "#e83b3b", "#fb6b1d", "#f79617", "#f9c22b", "#7a3045", "#9e4539", "#cd683d", "#e6904e", "#fbb954", "#4c3e24", "#676633", "#a2a947", "#d5e04b", "#fbff86", "#165a4c", "#239063", "#1ebc73", "#91db69", "#cddf6c", "#313638", "#374e4a", "#547e64", "#92a984", "#b2ba90", "#0b5e65", "#0b8a8f", "#0eaf9b", "#30e1b9", "#8ff8e2", "#323353", "#484a77", "#4d65b4", "#4d9be6", "#8fd3ff", "#45293f", "#6b3e75", "#905ea9", "#a884f3", "#eaaded", "#753c54", "#a24b6f", "#cf657f", "#ed8099", "#831c5d", "#c32454", "#f04f78", "#f68181", "#fca790", "#fdcbb0"]),
        ]
        self.nameLabel = nameLabel
        nameLabel.text = colorPaletteList[selectedPaletteIndex].name
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
        nameLabel.text = currentPalette.name
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
            nameLabel.text = newName
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
        nameLabel.text = palette.name
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
