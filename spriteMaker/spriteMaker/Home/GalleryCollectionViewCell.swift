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
        self.coreData = CoreData()
    }
    
    func animateImages(_ data: Time?, targetImageView: UIImageView) {
        let images: [UIImage]
        
        if (data == nil) { return }
        images = data!.frames.map { frame in
            return frame.renderedImage
        }
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(images.count)
        targetImageView.startAnimating()
    }
}

extension GalleryCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coreData.items.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddSpriteCollectionViewCell", for: indexPath) as! AddSpriteCollectionViewCell
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpriteCollectionViewCell", for: indexPath) as! SpriteCollectionViewCell
            
            // set title
            cell.titleLabel.text = coreData.items[indexPath.row - 1].title
            
            // coreData에서 첫번째 frame의 image를 가져온다.
            let convertedData = TimeMachineViewModel().decompressData(
                coreData.items[indexPath.row - 1].data!,
                size: CGSize(width: cell.spriteImage.layer.bounds.width, height: cell.spriteImage.layer.bounds.height)
            )
            if (convertedData == nil) {
                cell.spriteImage.image = UIImage(named: "empty")
            }
            
            // selectedData라면 외곽선을 그린다.
            if (coreData.selectedDataIndex == indexPath.row - 1) {
                cell.spriteImage.layer.borderWidth = 1
                cell.spriteImage.layer.borderColor = UIColor.white.cgColor
                animateImages(convertedData, targetImageView: cell.spriteImage)
            } else {
                cell.spriteImage.layer.borderWidth = 0
                cell.spriteImage.stopAnimating()
                cell.spriteImage.image = convertedData?.frames[0].renderedImage
            }
            return cell
        }
    }
}

extension GalleryCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            coreData.createData(title: "untitled", data: "")
        default:
            coreData.changeSelectedIndex(index: indexPath.row - 1)
        }
        collectionView.reloadData()
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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingBtn: UIButton!
    
    override func awakeFromNib() {
        setSideCorner(target: spriteImage, side: "all", radius: spriteImage.bounds.width / 15)
        setViewShadow(target: settingBtn, radius: 3, opacity: 1)
    }
    
}
