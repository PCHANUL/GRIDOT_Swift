//
//  TestViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/06.
//

import UIKit

struct gameCommand {
    var name: String
    var pos: CGRect
    var view: UIImageView
    var label: UILabel
}

class TestingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gameControllerBox: UIView!
    @IBOutlet weak var gameStickView: GameStickView!
    @IBOutlet weak var gameButtonView: GameButtonView!
    @IBOutlet weak var gameButton_A: UIImageView!
    @IBOutlet weak var gameButton_B: UIImageView!
    @IBOutlet weak var gameButton_C: UIImageView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var screenView: UIView!
    var superViewController: ViewController!
    
    var gameCommands: [gameCommand]!
    var gameData: Time!
    var coreData: CoreData!
    var screen: Screen!
    
    var toastLabel: UILabel!
    
    var isInit: Bool = false
    override func layoutSubviews() {
        if (isInit == false) {
            isInit = true
            initScreenData()
            
            self.gameStickView.testViewController = self
            self.gameButtonView.testViewController = self
            self.gameStickView.screen = screen
            self.gameButtonView.screen = screen
        }
    }
    
    func initScreenData() {
        if (gameData == nil) { return }
        if (screen != nil) { screen.removeFromSuperview() }
        
        screen = Screen(self.frame.width * 0.9, gameData)
        screen.backgroundColor = .white
        screen.initCounter()
        screen.activateFrameIntervalInputAction()
        
        screenView.addSubview(screen)
        self.gameStickView.screen = screen
        self.gameButtonView.screen = screen
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
                label.text = ""
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
                self.initScreenData()
                self.categoryCollectionView.reloadData()
                self.superViewController.mainViewController.removeLabelView()
            }
        }
    }
    
    func terminateTest() {
        screen.frameInterval.invalidate()
    }
}

// button methods
extension TestingCollectionViewCell {
    
    // 버튼의 위치와 범위에 pos가 있는지 확인
    func getKeyIndex(pos: CGPoint) -> Int {
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
    
    func changeButtonStatus(_ index: Int, _ color: UIColor, _ text: String, isTemp: Bool) {
        if (index == -1) { return }
        if (isTemp == false) {
            gameCommands[index].name = text
        }
        gameCommands[index].label.text = text
        gameCommands[index].view.tintColor = color
    }
    
    func recoverChangedButtonStatus(_ index: Int, _ text: String) {
        if (index == -1) { return }
        let color: UIColor
        let textStr: String
        
        if (gameCommands[index].name == "" || gameCommands[index].name == text) {
            textStr = ""
            color = UIColor.darkGray
        } else {
            textStr = gameCommands[index].name
            color = CategoryListViewModel().getCategoryColor(
                category: gameCommands[index].name
            )
        }
        gameCommands[index].label.text = textStr
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
