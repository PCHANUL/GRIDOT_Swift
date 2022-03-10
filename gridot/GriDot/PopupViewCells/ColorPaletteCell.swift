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
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var superView: UIView!
    
    weak var superViewController: UIViewController!
    var paletteIndex: IndexPath!
    var colorPalette: Palette!
    var isSelectedPalette: Bool!
    var isSettingClicked: Bool!
    var isScaled: Bool = false
    
    var setPopupViewPositionY: ((_ keyboardPositionY: CGFloat, _ paletteIndex: IndexPath) -> ())!
    
    override func layoutSubviews() {
        deleteButton.layer.cornerRadius = 5
        paletteLabel.text = colorPalette.name
        paletteTextField.attributedPlaceholder = NSAttributedString(
            string: CoreData.shared.selectedPalette!.name!,
            attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.boldSystemFont(ofSize: 14.0)
            ]
        )
    }
    
    @IBAction func tappedRemovePalette(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Delete Palette", message: "팔레트를 제거하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] (action: UIAlertAction!) in
            CoreData.shared.deleteData(entity: .palette, index: paletteIndex.row)
        }))
        superViewController.present(refreshAlert, animated: true, completion: nil)
    }
}

extension ColorPaletteCell: UITextFieldDelegate {
    private func dismissKeyboard() {
        paletteTextField.resignFirstResponder()
    }
    
    func renamePalette(text: String) {
        guard let palette = CoreData.shared.selectedPalette else { return }
        palette.name = text
        CoreData.shared.updatePalette(index: CoreData.shared.selectedPaletteIndex, palette: palette)
        paletteTextField.placeholder = text
        dismissKeyboard()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        paletteTextField.text = colorPalette.name
        guard let renamePopupVC = UIStoryboard(name: "RenamePopup", bundle: nil).instantiateViewController(identifier: "RenamePopupViewController") as? RenamePopupViewController else { return }
        
        renamePopupVC.modalPresentationStyle = .pageSheet
        renamePopupVC.currentPalette = colorPalette
        renamePopupVC.currentText = paletteTextField.text
        renamePopupVC.preView = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 60, height: 60)
        
        let newCVC = ColorListCollectionView.init(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height), collectionViewLayout: layout, palette: colorPalette)
        newCVC.delegate = newCVC
        newCVC.dataSource = newCVC
        newCVC.register(ColorCellAtRename.self, forCellWithReuseIdentifier: "colorCell")
        
        superViewController.present(renamePopupVC, animated: true, completion: nil)
        renamePopupVC.contentView.addSubview(newCVC)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        paletteTextField.text = ""
    }
}

extension ColorPaletteCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(collectionView)
        if (colorPalette == nil) { return 0 }
        guard let palette = CoreData.shared.getPalette(index: paletteIndex.row) else { return 0 }
        return palette.colors!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorFrameCell", for: indexPath) as? ColorFrameCell else {
            return UICollectionViewCell()
        }
        cell.colorIndex = indexPath.row
        cell.paletteIndex = paletteIndex.row
        cell.isSettingClicked = isSettingClicked
        
        guard let palette = CoreData.shared.getPalette(index: paletteIndex.row) else { return cell }
        if (indexPath.row >= palette.colors!.count) { return cell }
        cell.colorFrame.backgroundColor = palette.colors![indexPath.row].uicolor
        
        return cell
    }
}

extension ColorPaletteCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let oneSideLength = collectionView.bounds.height
        return CGSize(width: oneSideLength, height: oneSideLength)
    }
}



