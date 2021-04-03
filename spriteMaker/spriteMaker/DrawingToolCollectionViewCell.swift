//
//  DrawingToolCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/03.
//

import UIKit

class DrawingToolCollectionViewCell: UICollectionViewCell {
    
}

extension DrawingToolCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingTool", for: indexPath) as? DrawingToolCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 20, height: 20)
    }
}

extension DrawingToolCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 클릭시
    }
}

class DrawingToolCell: UICollectionViewCell {
    
}
