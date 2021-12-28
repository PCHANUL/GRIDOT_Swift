//
//  ColorFrameCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/30.
//

import UIKit

class ColorFrameCell: UICollectionViewCell {
    @IBOutlet weak var colorFrame: UIView!
    @IBOutlet weak var removeColor: UIButton!
    
    var isSettingClicked: Bool!
    var paletteIndex: Int!
    var colorIndex: Int!
    
    @IBAction func tappedRemoveColor(_ sender: Any) {
        CoreData.shared.removeColor(index: colorIndex!)
    }
    
    override func layoutSubviews() {
        let isSelected = CoreData.shared.selectedPaletteIndex == paletteIndex
        removeColor.isHidden = isSelected ? !isSettingClicked : true
    }
}
