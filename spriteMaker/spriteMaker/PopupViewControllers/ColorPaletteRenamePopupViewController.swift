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
    
    var currentPalette: ColorPalette!
    var currentText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = currentText
        superView.layer.cornerRadius = superView.bounds.width / 25
        superView.layer.masksToBounds = true
    }
}

extension ColorPaletteRenamePopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPalette.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCellAtRename else {
            return UICollectionViewCell()
        }
        cell.colorCell.backgroundColor = currentPalette.colors[indexPath.row].uicolor
        return cell
    }
}

extension ColorPaletteRenamePopupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let oneSideLength = colorPaletteList.bounds.height
        return CGSize(width: oneSideLength, height: oneSideLength)
    }
}

class ColorCellAtRename: UICollectionViewCell {
    @IBOutlet weak var colorCell: UIView!
}
