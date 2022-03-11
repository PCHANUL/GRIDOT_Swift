//
//  ColorListCollectionView.swift
//  GriDot
//
//  Created by 박찬울 on 2022/03/10.
//

import UIKit

class ColorListCollectionView: UICollectionView {
    var currentPalette: Palette
    
    init(frame: CGRect, palette: Palette) {
        self.currentPalette = palette
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.scrollDirection = .horizontal
        
        super.init(frame: frame, collectionViewLayout: layout)
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
        let oneSideLength = self.frame.height
        return CGSize(width: oneSideLength, height: oneSideLength)
    }
}

class ColorCellAtRename: UICollectionViewCell {
}
