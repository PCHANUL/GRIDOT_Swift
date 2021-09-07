//
//  AnimatedPreviewPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/01.
//

import UIKit

class AnimatedPreviewPopupViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var superCollectionView: UIView!
    @IBOutlet var superView: UIView!
    @IBOutlet var windowView: UIView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var speedPicker: UIPickerView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    var categorys: [String] = []
    let categoryListVM = CategoryListViewModel()
    var nums = 0
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var popupPosition: CGPoint!
    
    var speedPickerItems = ["0.2", "0.4", "0.6", "Speed", "1.0", "1.2", "1.5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topConstraint.constant = popupPosition.y
        leadingConstraint.constant = popupPosition.x
        
        setSideCorner(target: superCollectionView, side: "all", radius: superCollectionView.bounds.width / 7)
        setViewShadow(target: superCollectionView, radius: 15, opacity: 0.7)
        setSideCorner(target: pickerView, side: "all", radius: pickerView.bounds.width / 7)
        setViewShadow(target: pickerView, radius: 15, opacity: 0.7)
        
        speedPicker.selectRow(speedPickerItems.firstIndex(of: "Speed")!, inComponent: 0, animated: true)
    }
    
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedResetButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension AnimatedPreviewPopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorys.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimatedPreviewPopupCell", for: indexPath) as? AnimatedPreviewPopupCell else {
            return AnimatedPreviewPopupCell()
        }
        
        cell.layer.cornerRadius = cell.bounds.height / 3
        cell.layer.borderColor = UIColor.white.cgColor
        if indexPath.row == 0 {
            cell.layer.borderWidth = animatedPreviewVM.curCategory == "All" ? 2 : 0
            cell.updateLabel(text: "All")
            cell.backgroundColor = UIColor.init(white: 0.18, alpha: 1)
            setViewShadow(target: cell, radius: 5, opacity: 1)
        } else {
            let categoryName = categorys[indexPath.row - 1]
            let categoryIndex = categoryListVM.indexOfCategory(name: categoryName)
            cell.backgroundColor = categoryListVM.item(at: categoryIndex).color
            cell.layer.borderWidth = animatedPreviewVM.curCategory == categoryName ? 2 : 0
            cell.updateLabel(text: categoryName)
            setViewShadow(target: cell, radius: 0, opacity: 0)
        }
        return cell
    }
}

extension AnimatedPreviewPopupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width - 5
        let height = width / 2
        return CGSize(width: width, height: height)
    }
}

extension AnimatedPreviewPopupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 클릭시 animatedPreview의 배경색이 바뀌며 해당 카테고리만 재생된다.
        if indexPath.row == 0 {
            animatedPreviewVM.initAnimatedPreview()
        } else {
            animatedPreviewVM.changeSelectedCategory(category: categorys[indexPath.row - 1])
            animatedPreviewVM.changeAnimatedPreview()
        }
        dismiss(animated: false, completion: nil)
    }
}

extension AnimatedPreviewPopupViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return speedPickerItems.count
        case 1:
            return categorys.count + 1
        default:
            return 0
        }
    }
}

extension AnimatedPreviewPopupViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        switch component {
        case 0:
            var pickerLabel = view as? UILabel

            if (pickerLabel == nil)
            {
                pickerLabel = UILabel()
                pickerLabel?.font = UIFont(name: "System", size: 20)
                pickerLabel?.textAlignment = .center
            }
            
            pickerLabel?.text = speedPickerItems[row]
            return pickerLabel!
        default:
            var pickerLabel = view as? UILabel

            if (pickerLabel == nil)
            {
                pickerLabel = UILabel()
                pickerLabel?.font = UIFont(name: "System", size: 20)
                pickerLabel?.textAlignment = .center
            }
            
            if (row > 0) {
                let categoryName = categorys[row - 1]
                let categoryIndex = categoryListVM.indexOfCategory(name: categoryName)
                pickerLabel?.backgroundColor = categoryListVM.item(at: categoryIndex).color
                pickerLabel?.text = categoryName
//                pickerLabel?.layer.cornerRadius = 10
            } else {
                pickerLabel?.text = "All"
            }
            
            return pickerLabel!
            
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row, component)
        
            
        let images = animatedPreviewVM.viewModel!.getAllImages()
        
        switch component {
        case 0:
            guard let targetImageView = animatedPreviewVM.findImageViewOfUIView(animatedPreviewVM.targetView!) else { return }
            animatedPreviewVM.animationSpeed = row
            let speed = Double(0.05) * (7 - Double(row))
            targetImageView.animationDuration = TimeInterval(Double(images.count) * speed)
            targetImageView.startAnimating()
        case 1:
            if (row == 0) {
                animatedPreviewVM.initAnimatedPreview()
            } else {
                animatedPreviewVM.changeSelectedCategory(category: categorys[row - 1])
                animatedPreviewVM.changeAnimatedPreview()
            }
        default:
            return
        }
        
    }
}

class AnimatedPreviewPopupCell: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    
    func updateLabel(text: String) {
        categoryLabel.text = text
    }
}

