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
        
        if isSelectedPalette {
            self.layer.borderWidth = 3
            self.layer.cornerRadius = 10
            self.layer.borderColor = UIColor.white.cgColor
            paletteTextField.isHidden = !isSettingClicked
            deleteButton.isHidden = !isSettingClicked
        } else {
            self.layer.borderWidth = 0
            paletteTextField.isHidden = true
            deleteButton.isHidden = true
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

//extension ColorPaletteCell {
//    @objc private func adjustInputView(noti: Notification) {
//        if isSelectedPalette {
//            // 키보드가 사라지는 경우
//            if noti.name.rawValue == "UIKeyboardWillHideNotification" {
//                setPopupViewPositionY(0, paletteIndex)
//                isScaled = false
//                return
//            }
//            if isScaled == false {
//                // 키보드 높이에 따른 인풋뷰 위치 변경
//                guard let userInfo = noti.userInfo else { return }
//                guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//                // 키보드의 위치 정보를 보낸다.
//                let keyboardHeight = keyboardFrame.minY
//                setPopupViewPositionY(keyboardHeight, self.paletteIndex)
//                isScaled = true
//            }
//
//
//        }
//    }
//}

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

class ColorFrameCell: UICollectionViewCell {
    var colorIndex: Int!
    var paletteIndex: Int!
    var isSettingClicked: Bool!
    var colorListCollectionView: UICollectionView!
    var colorPaletteViewModel: ColorPaletteListViewModel!
    @IBOutlet weak var colorFrame: UIView!
    @IBOutlet weak var removeColor: UIButton!
    
    @IBAction func tappedRemoveColor(_ sender: Any) {
        var palette = colorPaletteViewModel.item(paletteIndex)
        let _ = palette.removeColor(index: colorIndex!)
        colorPaletteViewModel.updateSelectedPalette(palette: palette)
    }
    
    override func layoutSubviews() {
        if colorPaletteViewModel.selectedPaletteIndex == paletteIndex {
            removeColor.isHidden = !isSettingClicked
        } else {
            removeColor.isHidden = true
        }
    }
}

