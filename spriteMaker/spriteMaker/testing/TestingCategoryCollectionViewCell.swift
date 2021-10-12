//
//  TestingCategoryCollectionViewCell.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/01.
//

import UIKit

// game boy category
class TestingCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryName: UILabel!
    var testView: TestingCollectionViewCell!
    var categoryVM = CategoryListViewModel()
    var labelView = UILabel()
    var selectedIndex = -1
    
    override func layoutSubviews() {
        self.backgroundColor = categoryVM.getCategoryColor(category: categoryName.text!)
        setSideCorner(target: self, side: "all", radius: self.frame.height / 4)
    }
    
    func setLabelView(_ pos: CGPoint) {
        guard let buttonVivew = testView.gameButton_A else { return }
        let rect = CGRect(
            x: pos.x - 25, y: pos.y - 100,
            width: buttonVivew.frame.width, height: buttonVivew.frame.height
        )
        
        labelView = UILabel(frame: rect)
        labelView.backgroundColor = categoryVM.getCategoryColor(category: categoryName.text!)
        labelView.textColor = UIColor.white
        labelView.textAlignment = .center
        labelView.text = categoryName.text
        labelView.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        labelView.layer.cornerRadius = buttonVivew.frame.width / 2
        labelView.clipsToBounds = true
        testView.addSubview(labelView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameBoyPanelCVC = testView
        if (gameBoyPanelCVC?.gameCommands == nil) {
            gameBoyPanelCVC?.initGameCommandsArr()
        }
    }
    
    // change label position and get selected button index and change button
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: testView) else { return }
        guard let gameBoyPanelCVC = testView else { return }
        guard let categoryCV = gameBoyPanelCVC.categoryCollectionView else { return }
        
        if (categoryCV.isScrollEnabled == true) {
            if (pos.y < (categoryCV.frame.minY + (window?.safeAreaInsets.top)!)) {
                categoryCV.isScrollEnabled = false
                
                setLabelView(pos)
                gameBoyPanelCVC.initButtonColor(selectedIndex)
                selectedIndex = -1
            } else { return }
        }
        
        // change label position
        labelView.frame = CGRect(
            x: pos.x - 25, y: pos.y - 100,
            width: gameBoyPanelCVC.gameButton_A.frame.width,
            height: gameBoyPanelCVC.gameButton_A.frame.height
        )
        
        // get index of selected key button
        let index = gameBoyPanelCVC.getKeyIndex(
            pos: CGPoint(x: labelView.frame.midX, y: labelView.frame.midY)
        )
        
        // init or change selected key button
        if (index == -1 && selectedIndex != -1) {
            gameBoyPanelCVC.recoverChangedButtonStatus(selectedIndex, categoryName.text!)
            selectedIndex = -1
        } else if (selectedIndex != index) {
            gameBoyPanelCVC.recoverChangedButtonStatus(selectedIndex, categoryName.text!)
            selectedIndex = index
            
            let color = categoryVM.getCategoryColor(category: categoryName.text!)
            gameBoyPanelCVC.changeButtonStatus(selectedIndex, color, categoryName.text!, isTemp: true)
        }
        
        labelView.isHidden = selectedIndex != -1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameBoyPanelCVC = testView else { return }
        gameBoyPanelCVC.categoryCollectionView.isScrollEnabled = true
        labelView.removeFromSuperview()
        
        let color = categoryVM.getCategoryColor(category: categoryName.text!)
        gameBoyPanelCVC.changeButtonStatus(selectedIndex, color, categoryName.text!, isTemp: false)
    }
}
