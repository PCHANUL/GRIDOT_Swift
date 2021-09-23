//
//  TestViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/06.
//

import UIKit

class TestingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gameControllerBox: UIView!
    @IBOutlet weak var gameStickView: GameStickView!
    @IBOutlet weak var gameButtonView: GameButtonView!
    @IBOutlet weak var gameButton_A: UIImageView!
    @IBOutlet weak var gameButton_B: UIImageView!
    @IBOutlet weak var gameButton_C: UIImageView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    var superViewController: ViewController!
    
    var gameCommands: [gameCommand]!
    var gameData: Time!
    var coreData: CoreData!
    
    var toastLabel: UILabel!
    
    var isInit: Bool = false
    override func layoutSubviews() {
        if (isInit == false) {
            self.gameStickView.testViewController = self
            self.gameButtonView.testViewController = self
            isInit = true
        }
    }
    
    func initGameCommandsArr() {
        gameCommands = []
        
        for view in gameControllerBox.subviews {
            for button in view.subviews {
                let boxFrame = gameControllerBox.frame
                let viewFrame = view.frame
                let buttonFrame = button.frame
                
                // get button size
                let minX = boxFrame.minX + viewFrame.minX + buttonFrame.minX
                let minY = boxFrame.minY + viewFrame.minY + buttonFrame.minY
                let rect = CGRect(x: minX, y: minY, width: buttonFrame.width, height: buttonFrame.height)
                
                // set label
                let label = UILabel(
                    frame: CGRect(x: 0, y: 0, width: button.frame.width, height: button.frame.height)
                )
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: gameButton_A.frame.width / 5, weight: .heavy)
                button.addSubview(label)
                
                gameCommands.append(gameCommand(name: "", pos: rect, view: button as! UIImageView, label: label))
            }
        }
    }
    
    func updateTestData() {
        DispatchQueue.main.async {
            self.gameData = TimeMachineViewModel().decompressData(CoreData().selectedData.data!, size: CGSize(width: 300, height: 300))
            if (self.isInit) {
                self.categoryCollectionView.reloadData()
                self.superViewController.mainViewController.removeLabelView()
            }
        }
    }
}


struct gameCommand {
    var name: String
    var pos: CGRect
    var view: UIImageView
    var label: UILabel
}

// button methods
extension TestingCollectionViewCell {
    func getKeyIndex(pos: CGPoint) -> Int {
        // 버튼의 위치와 범위에 pos가 있는지 확인
        for index in 0..<gameCommands.count {
            let commandPos = gameCommands[index].pos
            if (commandPos.minX < pos.x && commandPos.maxX > pos.x
                    && commandPos.minY < pos.y && commandPos.maxY > pos.y) {
                return index
            }
        }
        return -1
    }
    
    func initButtonColor(_ index: Int) {
        if (index == -1) { return }
        gameCommands[index].name = ""
        gameCommands[index].label.text = ""
        gameCommands[index].view.tintColor = UIColor.darkGray
    }
    
    func recoverChangedButtonColor(_ index: Int, _ text: String) {
        if (index == -1) { return }
        let color: UIColor
        let textStr: String
        
        if (gameCommands[index].name == "" || gameCommands[index].name == text) {
            color = UIColor.darkGray
            textStr = ""
        } else {
            color = CategoryListViewModel().getCategoryColor(category: gameCommands[index].name)
            textStr = gameCommands[index].name
        }
        
        gameCommands[index].label.text = textStr
        gameCommands[index].view.tintColor = color
    }
    
    func preChangeButtonColor(_ index: Int, _ color: UIColor, _ text: String) {
        gameCommands[index].label.text = text
        gameCommands[index].view.tintColor = color
    }
    
    func changeButtonColor(_ index: Int, _ color: UIColor, _ text: String) {
        if (index == -1) { return }
        gameCommands[index].name = text
        gameCommands[index].label.text = text
        gameCommands[index].view.tintColor = color
    }
}


extension TestingCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (gameData == nil) { return 0 }
        return gameData.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestingCategoryCollectionViewCell", for: indexPath) as! TestingCategoryCollectionViewCell
        cell.categoryName.text = gameData.categoryList[indexPath.row]
        cell.testView = self
        return cell
    }
}

extension TestingCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: categoryCollectionView.frame.height - 10)
    }
}


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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: testView) else { return }
        guard let gameBoyPanelCVC = testView else { return }
        guard let categoryCV = gameBoyPanelCVC.categoryCollectionView else { return }
        
        if (categoryCV.isScrollEnabled == true) {
            if (pos.y < (categoryCV.frame.minY + (window?.safeAreaInsets.top)!)) {
                setLabelView(pos)
                categoryCV.isScrollEnabled = false
                gameBoyPanelCVC.initButtonColor(selectedIndex)
                selectedIndex = -1
            } else { return }
        }
        
        labelView.frame = CGRect(
            x: pos.x - 25, y: pos.y - 100,
            width: gameBoyPanelCVC.gameButton_A.frame.width,
            height: gameBoyPanelCVC.gameButton_A.frame.height
        )
        let index = gameBoyPanelCVC.getKeyIndex(
            pos: CGPoint(
                x: labelView.frame.midX,
                y: labelView.frame.midY - (window?.safeAreaInsets.top)!
            )
        )
        
        // init selected button
        if (index == -1 && selectedIndex != -1) {
            gameBoyPanelCVC.recoverChangedButtonColor(selectedIndex, categoryName.text!)
            selectedIndex = -1
            return
        }
        
        // change selected button
        if (selectedIndex != index) {
            gameBoyPanelCVC.recoverChangedButtonColor(selectedIndex, categoryName.text!)
            selectedIndex = index
            let color = categoryVM.getCategoryColor(category: categoryName.text!)
            gameBoyPanelCVC.preChangeButtonColor(selectedIndex, color, categoryName.text!)
        }
        
        labelView.isHidden = selectedIndex != -1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameBoyPanelCVC = testView else { return }
        gameBoyPanelCVC.categoryCollectionView.isScrollEnabled = true
        labelView.removeFromSuperview()
        
        let color = categoryVM.getCategoryColor(category: categoryName.text!)
        gameBoyPanelCVC.changeButtonColor(selectedIndex, color, categoryName.text!)
    }
}

class GameBoySettingPanelCollectionViewCell: UICollectionViewCell {
    
}


