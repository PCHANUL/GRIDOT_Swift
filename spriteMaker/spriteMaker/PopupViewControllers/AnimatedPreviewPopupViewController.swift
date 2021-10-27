//
//  AnimatedPreviewPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/01.
//

import UIKit

class AnimatedPreviewPopupViewController: UIViewController {

    @IBOutlet var superView: UIView!
    @IBOutlet var windowView: UIView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var speedPicker: UIPickerView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pauseBtn: UIButton!
    weak var animateBtn: UIButton!
    
    let categoryListVM = CategoryListViewModel()
    var animatedPreviewVM: AnimatedPreviewViewModel!
    var popupPosition: CGPoint!
    
    var categorys: [String] = []
    var speedPickerItems = ["0.2", "0.4", "0.6", "Speed", "1.0", "1.2", "1.5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topConstraint.constant = popupPosition.y
        leadingConstraint.constant = popupPosition.x
        pauseBtn.isSelected = !animatedPreviewVM.isAnimated
        
        setSideCorner(target: pickerView, side: "all", radius: pickerView.bounds.width / 10)
        setViewShadow(target: pickerView, radius: 20, opacity: 1)
        setSideCorner(target: pauseBtn, side: "bottom", radius: pickerView.bounds.width / 10)
        setViewShadow(target: pauseBtn, radius: 5, opacity: 0.5)
        
        let curCategory = animatedPreviewVM.curCategory
        let categoryIndex = curCategory == "All" ? 0 : categorys.firstIndex(of: curCategory)! + 1
        speedPicker.selectRow(categoryIndex, inComponent: 1, animated: false)
        speedPicker.selectRow(animatedPreviewVM.animationSpeedIndex, inComponent: 0, animated: false)
    }
    
    @IBAction func closePopupView(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedPauseBtn(_ sender: UIButton) {
        if (sender.isSelected) {
            animatedPreviewVM!.startAnimating()
            animateBtn.setImage(nil, for: .normal)
            animateBtn.backgroundColor = UIColor.clear
        } else {
            animatedPreviewVM!.pauseAnimating()
            let image = UIImage(
                systemName: "pause.fill",
                withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 30)
            )
            animateBtn.setImage(image, for: .normal)
            animateBtn.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        }
        sender.isSelected = !sender.isSelected
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
        var pickerLabel = view as? UILabel

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 20)
            pickerLabel?.textAlignment = .center
        }
        
        switch component {
        case 0:
            pickerLabel?.text = speedPickerItems[row]
        default:
            if (row > 0) {
                let categoryName = categorys[row - 1]
                let categoryIndex = categoryListVM.indexOfCategory(name: categoryName)
                pickerLabel?.backgroundColor = categoryListVM.item(at: categoryIndex).color
                pickerLabel?.text = categoryName
            } else {
                pickerLabel?.text = "All"
            }
        }
        
        return pickerLabel!
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0:
            animatedPreviewVM.animationSpeedIndex = row
            animatedPreviewVM.changeAnimatedPreview()
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

