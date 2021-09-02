//
//  GalleryCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/16.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuStackView: UIStackView!
    var homeMenuPanelController: UIViewController!
    var coreData: CoreData!
    var items: [Time?]!
    
    override func awakeFromNib() {
        self.coreData = CoreData()
        self.setItems()
    }
    
    func setItems() {
        let timeMachineVM = TimeMachineViewModel()
        items = []
        for index in (0..<coreData.items.count).reversed() {
            items.append(timeMachineVM.decompressData(
                coreData.items[index].data!,
                size: CGSize(width: 200, height: 200)
            ))
        }
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

extension GalleryCollectionViewCell {
    @IBAction func tappedAddBtn(_ sender: Any) {
        coreData.createData(title: "untitled", data: "")
        UserDefaults.standard.setValue(coreData.items.count - 1, forKey: "selectedDataIndex")
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        setItems()
        collectionView.reloadData()
    }
    
    @IBAction func tappedCopyBtn(_ sender: Any) {
        let alert = UIAlertController(title: "복사", message: "선택된 아이템을 복사하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { UIAlertAction in
            self.coreData.copySelectedData()
            UserDefaults.standard.setValue(self.coreData.items.count - 1, forKey: "selectedDataIndex")
            self.setItems()
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        homeMenuPanelController.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedRemoveBtn(_ sender: Any) {
        let alert = UIAlertController(title: "제거", message: "선택된 아이템을 제거하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { UIAlertAction in
            self.coreData.deleteData(index: self.coreData.selectedDataIndex)
            if (self.coreData.selectedDataIndex >= self.coreData.items.count) {
                UserDefaults.standard.setValue(self.coreData.selectedDataIndex - 1, forKey: "selectedDataIndex")
            }
            self.setItems()
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        homeMenuPanelController.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedExportBtn(_ sender: Any) {
        let alert = UIAlertController(title: "출력", message: "선택된 아이템을 출력하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        homeMenuPanelController.present(alert, animated: true, completion: nil)
    }
}

extension GalleryCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coreData.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpriteCollectionViewCell", for: indexPath) as! SpriteCollectionViewCell
        let index = coreData.items.count - indexPath.row - 1
        cell.index = index
        
        // set title
        cell.titleTextField.text = coreData.items[index].title
        if (items[indexPath.row] == nil) {
            cell.spriteImage.image = UIImage(named: "empty")
        }
        
        // selectedData라면 외곽선을 그린다.
        if (coreData.selectedDataIndex == index) {
            cell.spriteImage.layer.borderWidth = 1
            cell.spriteImage.layer.borderColor = UIColor.white.cgColor
            animateImages(items[indexPath.row], targetImageView: cell.spriteImage)
        } else {
            cell.spriteImage.layer.borderWidth = 0
            cell.spriteImage.stopAnimating()
            cell.spriteImage.image = items[indexPath.row]?.frames[0].renderedImage
        }
        return cell
    }
}

extension GalleryCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = coreData.items.count - indexPath.row - 1
        
        if (coreData.selectedDataIndex == index) {
            homeMenuPanelController.dismiss(animated: true, completion: nil)
        } else {
            coreData.changeSelectedIndex(index: coreData.items.count - indexPath.row - 1)
            collectionView.reloadData()
        }
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

class SpriteHeaderCollectionViewCell: UICollectionReusableView {
    
}

class SpriteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var spriteImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    var index: Int!
    
    override func awakeFromNib() {
        setSideCorner(target: spriteImage, side: "all", radius: spriteImage.bounds.width / 15)
        setViewShadow(target: self, radius: 5, opacity: 0.5)
        titleTextField.layer.borderColor = UIColor.black.cgColor
    }
}

extension SpriteCollectionViewCell: UITextFieldDelegate {
      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        CoreData().updateTitle(title: textField.text!, index: index)
        titleTextField.resignFirstResponder()
        return true
      }
    
}
