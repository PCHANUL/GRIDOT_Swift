//
//  ColorPaletteRenamePopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/26.
//

import UIKit

class ColorPaletteRenamePopupViewController: UIViewController {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var colorPaletteList: UICollectionView!
    @IBOutlet weak var closeButton: UIView!
    
    weak var preView: ColorPaletteCell!
    var currentPalette: Palette!
    var currentText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        superView.layer.cornerRadius = superView.bounds.width / 25
        superView.layer.masksToBounds = true
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.gray.cgColor
        textField.text = currentText
        textField.becomeFirstResponder()
    }
    
    @IBAction func tappedRenameButton(_ sender: Any) {
        preView.renamePalette(text: textField.text!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ColorPaletteRenamePopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPalette.colors!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCellAtRename else {
            return UICollectionViewCell()
        }
        cell.colorCell.backgroundColor = currentPalette.colors![indexPath.row].uicolor
        return cell
    }
}

extension ColorPaletteRenamePopupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let oneSideLength = colorPaletteList.bounds.height
        return CGSize(width: oneSideLength, height: oneSideLength)
    }
}

extension ColorPaletteRenamePopupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        preView.renamePalette(text: textField.text!)
        dismiss(animated: true, completion: nil)
        return true
    }
}

class ColorCellAtRename: UICollectionViewCell {
    @IBOutlet weak var colorCell: UIView!
}
