//
//  GalleryCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/16.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
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
        return coreData.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpriteCollectionViewCell", for: indexPath) as! SpriteCollectionViewCell
        
        // set title
        cell.titleTextField.text = coreData.items[indexPath.row].title
        
        // coreData에서 첫번째 frame의 image를 가져온다.
        let convertedData = TimeMachineViewModel().decompressData(
            coreData.items[indexPath.row].data!,
            size: CGSize(width: cell.spriteImage.layer.bounds.width, height: cell.spriteImage.layer.bounds.height)
        )
        if (convertedData == nil) {
            cell.spriteImage.image = UIImage(named: "empty")
        }
        
        // selectedData라면 외곽선을 그린다.
        if (coreData.selectedDataIndex == indexPath.row) {
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SpriteHeaderCollectionViewCell", for: indexPath) as! SpriteHeaderCollectionViewCell
        return header
    }
    
}

extension GalleryCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coreData.changeSelectedIndex(index: indexPath.row - 1)
//        switch indexPath.row {
//        case 0:
//            coreData.createData(title: "untitled", data: "")
//            UserDefaults.standard.setValue(coreData.items.count - 1, forKey: "selectedDataIndex")
//            collectionView.setContentOffset(
//                CGPoint(x: 0, y: -collectionView.contentInset.top + collectionView.contentSize.height - collectionView.frame.height),
//                animated: true
//            )
//        default:
//
//        }
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.frame.width, height: 50)
    }
}

class SpriteHeaderCollectionViewCell: UICollectionReusableView {
    
}

class SpriteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var spriteImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func awakeFromNib() {
        setSideCorner(target: spriteImage, side: "all", radius: spriteImage.bounds.width / 15)
        titleTextField.layer.borderColor = UIColor.black.cgColor
    }
}

extension SpriteCollectionViewCell: UITextFieldDelegate {
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        CoreData().updateTitle(title: textField.text!)
        titleTextField.resignFirstResponder()
        return true
      }
    
}
