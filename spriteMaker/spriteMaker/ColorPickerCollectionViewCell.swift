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
    
    // color stack
    @IBOutlet weak var colorStack: UIStackView!
    @IBOutlet weak var colorB: UIButton!
    @IBOutlet weak var colorG: UIButton!
    @IBOutlet weak var colorM: UIButton!
    @IBOutlet weak var colorW: UIButton!
    
    
    var canvas: Canvas!
    var selectedStackColor: Int = 2
    
    func changeSelectedColorStack(at index: Int) {
        print("stack")
        let stack = [self.colorB, self.colorG, self.colorM, self.colorW]
        stack[selectedStackColor]?.layer.borderWidth = 0
        stack[index]?.layer.borderWidth = 1
        stack[index]?.layer.borderColor = UIColor.white.cgColor
        selectedStackColor = index
        
        canvas.selectedColor = UIColor(cgColor: (stack[index]?.layer.backgroundColor)!)
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
        
        
        // set selected color
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        selectedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        print("255", red * 255, green * 255, blue * 255, alpha * 255)
        
        print(selectedColor.hexa ?? "none")
        print(selectedColor.hexa?.uicolor)
        
        canvas.selectedColor = (selectedColor.hexa?.uicolor)!
        canvas.setNeedsDisplay()
    }
    
    
    
    var viewController: UIViewController!
    var selectedColor: UIColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorM.layer.borderWidth = 1
        colorM.layer.borderColor = UIColor.white.cgColor
        
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
    
    @IBAction func tappedStackColor(_ sender: UIButton) {
        let stackWidth = self.colorStack.frame.width / 4
        let selectedIndex = Int(round(sender.frame.minX / stackWidth))
        changeSelectedColorStack(at: selectedIndex)
    }
    
    @IBAction func addColorButton(_ sender: Any) {
        print("addColor")
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ColorPickerHeader", for: indexPath) as! ColorPickerHeader
        
        
        header.colorAddButton.layer.backgroundColor = self.selectedColor.cgColor
        return header
    }
}

extension ColorPickerCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = colorCollectionList.frame.height
        return CGSize(width: sideLength, height: sideLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sideLength = colorCollectionList.frame.height
        return CGSize(width: sideLength, height: sideLength)
     }
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
//        let item = orderOfTools.remove(at: sourceIndexPath.row)
//        orderOfTools.insert(item, at: destinationIndexPath.row)
//        toolCollectionView.reloadData()
    }
}

extension ColorPickerCollectionViewCell: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        currentColor.tintColor = selectedColor
        colorCollectionList.reloadData()
        reloadStackColor()
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        currentColor.tintColor = selectedColor
        colorCollectionList.reloadData()
        reloadStackColor()
    }
}

class ColorPickerHeader: UICollectionReusableView {
    @IBOutlet weak var colorAddButton: UIButton!
}

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var color: UIView!
    
}




