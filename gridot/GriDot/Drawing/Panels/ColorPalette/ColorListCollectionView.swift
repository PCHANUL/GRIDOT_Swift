//
//  ColorListCollectionView.swift
//  GriDot
//
//  Created by 박찬울 on 2022/03/10.
//

import UIKit

class ColorListCollectionView: UICollectionView {
    var currentPalette: Palette
    
    init(frame: CGRect, collectionViewLayout: UICollectionViewLayout, palette: Palette) {
        self.currentPalette = palette
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorListCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPalette.colors!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCellAtRename else {
            return UICollectionViewCell()
        }
        let hex = currentPalette.colors![indexPath.row]
        cell.contentView.backgroundColor = hex.uicolor
        return cell
    }
}

extension ColorListCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let oneSideLength = 10
        return CGSize(width: oneSideLength, height: oneSideLength)
    }
}

class ColorCellAtRename: UICollectionViewCell {
}
