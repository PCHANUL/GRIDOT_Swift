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
    
    weak var homeMenuPanelController: UIViewController!
    weak var superViewController: ViewController!
    var coreData: CoreData!
    var timeMachineVM: TimeMachineViewModel!
    var items: [Time?]!
    
    override func awakeFromNib() {
        self.coreData = CoreData()
        self.timeMachineVM = TimeMachineViewModel()
        self.setItems()
    }
    
    func setItems() {
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
        targetImageView.animationDuration = TimeInterval(Double(images.count) * 0.2)
        targetImageView.startAnimating()
    }
}

extension GalleryCollectionViewCell {
    
    @IBAction func tappedAddBtn(_ sender: Any = 0) {
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
    
    @IBAction func tappedImportBtn(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        homeMenuPanelController.present(imagePicker, animated: true)
    }
    
    @IBAction func tappedExportBtn(_ sender: Any) {
        let alert = UIAlertController(title: "출력", message: "선택된 아이템을 출력하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: nil))
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
}

extension GalleryCollectionViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // [] 새로운 파일을 생성한다.
            // [] pickedImage의 색상 정보를 16*16으로 가져온다.
            // [] 새로운 프레임과 레이어를 생성하여 색상 정보 grid를 생성한다.
            // [] 반복하여 만들어진 여러 프레임을 coreData에 compressData로 변환하여 저장한다.
            // [] setItems로 coreData에서 데이터를 다시 가져오고 collectionView를 갱신한다.
            
        
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension GalleryCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coreData.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpriteCollectionViewCell", for: indexPath) as? SpriteCollectionViewCell else { return UICollectionViewCell() }
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
