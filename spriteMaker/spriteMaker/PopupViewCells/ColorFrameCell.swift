//
//  ColorFrameCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/30.
//

import UIKit

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
