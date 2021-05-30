//
//  ColorPaletteCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/14.
//

import UIKit

class ColorPaletteCell: UICollectionViewCell {
    @IBOutlet weak var paletteLabel: UILabel!
    @IBOutlet weak var paletteTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var superView: UIView!
    
    var superViewController: UIViewController!
    var colorPaletteViewModel: ColorPaletteListViewModel!
    var paletteIndex: IndexPath!
    
    var colorPalette: ColorPalette!
    var isSelectedPalette: Bool!
    var isSettingClicked: Bool!
    var isScaled: Bool = false
    
    var setPopupViewPositionY: ((_ keyboardPositionY: CGFloat, _ paletteIndex: IndexPath) -> ())!
    
    override func layoutSubviews() {
        isSelectedPalette = colorPaletteViewModel.selectedPaletteIndex == paletteIndex.row
        colorPalette = colorPaletteViewModel.item(paletteIndex.row)
        deleteButton.layer.cornerRadius = 5
        paletteLabel.text = colorPalette.name
        paletteTextField.attributedPlaceholder = NSAttributedString(
            string: colorPaletteViewModel.currentPalette.name,
            attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.boldSystemFont(ofSize: 14.0)
            ]
        )
        
        let trailingContraint = superView.constraints.first { $0.identifier == "a" }
        if isSelectedPalette {
            self.layer.borderWidth = 3
            self.layer.cornerRadius = 10
            self.layer.borderColor = UIColor.white.cgColor
            paletteTextField.isHidden = !isSettingClicked
            deleteButton.isHidden = !isSettingClicked
            trailingContraint?.constant = isSettingClicked ? 45 : 8
        } else {
            self.layer.borderWidth = 0
            paletteTextField.isHidden = true
            deleteButton.isHidden = true
            trailingContraint?.constant = 8
        }
        collectionView.reloadData()
    }
    
    
    @IBAction func tappedRemovePalette(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Delete Palette", message: "팔레트를 제거하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] (action: UIAlertAction!) in
            print("Handle Ok logic here")
            let _ = self.colorPaletteViewModel.deletePalette(index: self.paletteIndex.row)
            self.colorPaletteViewModel.reloadColorListAndPaletteList()
        }))
        superViewController.present(refreshAlert, animated: true, completion: nil)
    }
}

extension ColorPaletteCell: UITextFieldDelegate {
    private func dismissKeyboard() {
        paletteTextField.resignFirstResponder()
    }
    
    func renamePalette(text: String) {
        var palette = colorPaletteViewModel.currentPalette
        palette.renamePalette(newName: text)
        colorPaletteViewModel.updateSelectedPalette(palette: palette)
        dismissKeyboard()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        paletteTextField.text = colorPalette.name
        let paletteRenamePopupVC = UIStoryboard(name: "ColorPaletteRenamePopup", bundle: nil).instantiateViewController(identifier: "ColorPaletteRenamePopupViewController") as! ColorPaletteRenamePopupViewController
        
        paletteRenamePopupVC.modalPresentationStyle = .pageSheet
        paletteRenamePopupVC.currentPalette = colorPalette
        paletteRenamePopupVC.currentText = paletteTextField.text
        paletteRenamePopupVC.preView = self
        superViewController.present(paletteRenamePopupVC, animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        paletteTextField.text = ""
    }
}

extension ColorPaletteCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPalette.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorFrameCell", for: indexPath) as? ColorFrameCell else {
            return UICollectionViewCell()
        }
        cell.colorFrame.backgroundColor = colorPalette.colors[indexPath.row].uicolor
        cell.colorIndex = indexPath.row
        cell.paletteIndex = paletteIndex.row
        cell.isSettingClicked = isSettingClicked
        cell.colorListCollectionView = collectionView
        cell.colorPaletteViewModel = colorPaletteViewModel
        return cell
    }
}

extension ColorPaletteCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let oneSideLength = collectionView.bounds.height
        return CGSize(width: oneSideLength, height: oneSideLength)
    }
}



