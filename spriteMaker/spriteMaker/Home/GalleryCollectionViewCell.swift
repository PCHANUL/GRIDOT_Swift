//
//  GalleryCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/16.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    var coreData: CoreData!
    
    override func awakeFromNib() {
        setViewShadow(target: self, radius: 5, opacity: 0.5)
    }
}

extension GalleryCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
            
        switch indexPath.row {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddSpriteCollectionViewCell", for: indexPath) as! AddSpriteCollectionViewCell
        default:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpriteCollectionViewCell", for: indexPath) as! SpriteCollectionViewCell
        }
            
        return cell
    }
}

extension GalleryCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        width = (self.bounds.width / 2) - 30
        height = (self.bounds.width / 2)
        return CGSize(width: width, height: height)
    }
}

class AddSpriteCollectionViewCell: UICollectionViewCell {
    
}

class SpriteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var spriteImage: UIImageView!
    
    override func awakeFromNib() {
        setSideCorner(target: spriteImage, side: "all", radius: spriteImage.bounds.width / 15)
    }
    
}
