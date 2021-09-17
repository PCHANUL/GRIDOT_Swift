//
//  TestViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/06.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var panelView: UIView!
    var segmentedControl: UISegmentedControl!
    var testPanelViewController: TestPanelViewController!
    
    var items = ["Game", "Message", "AppleWatch"]
    var coreData: CoreData = CoreData()
    var timeMachineVM: TimeMachineViewModel = TimeMachineViewModel()
    var selectedData: Time!
    
    override func viewDidLoad() {
        segmentedControl.selectedSegmentIndex = 0
        setSideCorner(target: tabBarView, side: "top", radius: tabBarView.bounds.width / 25)
        
        selectedData = timeMachineVM.decompressData(coreData.selectedData.data!, size: CGSize(width: 300, height: 300))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "panel") {
            testPanelViewController = segue.destination as? TestPanelViewController
            testPanelViewController.superView = self
        }
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}


// panel
class TestPanelViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var gameBoyPanelCVC: GameBoyPanelCollectionViewCell!
    var superView: TestViewController!
    
}

extension TestPanelViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            gameBoyPanelCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "GameBoyPanelCollectionViewCell", for: indexPath) as? GameBoyPanelCollectionViewCell
            gameBoyPanelCVC.gameData = superView.selectedData
            gameBoyPanelCVC.testView = superView
            return gameBoyPanelCVC
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameBoySettingPanelCollectionViewCell", for: indexPath)
            return cell
        }
    }
}

extension TestPanelViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewFrame = superView.panelView.frame
        return CGSize(width: viewFrame.width, height: viewFrame.height)
    }
}


// game boy
class GameBoyPanelCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gameControllerBox: UIView!
    @IBOutlet weak var gameStickView: GameStickView!
    @IBOutlet weak var gameButtonView: GameButtonView!
    @IBOutlet weak var gameButton_A: UIImageView!
    @IBOutlet weak var gameButton_B: UIImageView!
    @IBOutlet weak var gameButton_C: UIImageView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    weak var testView: TestViewController!
    
    var gameCommands: [gameCommand]!
    var gameData: Time!
    
    var isInit: Bool = false
    override func layoutSubviews() {
        if (isInit == false) {
            gameStickView.testViewController = self
            gameButtonView.testViewController = self
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
                
                gameCommands.append(gameCommand(pos: rect, view: button as! UIImageView, label: label))
            }
        }
    }
    
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
        gameCommands[index].label.text = ""
        gameCommands[index].view.tintColor = UIColor.darkGray
    }
    
    func changeButtonColor(_ index: Int, _ color: UIColor, _ text: String) {
        gameCommands[index].label.text = text
        gameCommands[index].view.tintColor = color
    }
}

struct gameCommand {
    var pos: CGRect
    var view: UIImageView
    var label: UILabel
}

extension GameBoyPanelCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameData.categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameBoyCategoryCollectionViewCell", for: indexPath) as! GameBoyCategoryCollectionViewCell
        cell.categoryName.text = gameData.categoryList[indexPath.row]
        cell.testView = testView
        return cell
    }
}

extension GameBoyPanelCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: categoryCollectionView.frame.height - 10)
    }
}


// game boy category
class GameBoyCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryName: UILabel!
    var testView: TestViewController!
    var categoryVM = CategoryListViewModel()
    var labelView = UILabel()
    var selectedIndex = 0
    
    override func layoutSubviews() {
        self.backgroundColor = categoryVM.getCategoryColor(category: categoryName.text!)
        setSideCorner(target: self, side: "all", radius: self.frame.height / 4)
    }
    
    func setLabelView(_ pos: CGPoint) {
        guard let buttonVivew = testView.testPanelViewController.gameBoyPanelCVC.gameButton_A else { return }
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
        testView.view.addSubview(labelView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameBoyPanelCVC = testView.testPanelViewController.gameBoyPanelCVC
        if (gameBoyPanelCVC?.gameCommands == nil) {
            gameBoyPanelCVC?.initGameCommandsArr()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: testView.view) else { return }
        guard let gameBoyPanelCVC = testView.testPanelViewController.gameBoyPanelCVC else { return }
        guard let categoryCV = gameBoyPanelCVC.categoryCollectionView else { return }
        
        if (categoryCV.isScrollEnabled == true) {
            if (pos.y < (categoryCV.frame.minY + (window?.safeAreaInsets.top)!)) {
                setLabelView(pos)
                categoryCV.isScrollEnabled = false
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
            gameBoyPanelCVC.initButtonColor(selectedIndex)
            selectedIndex = -1
            return
        }
        
        // change selected button
        if (selectedIndex != index) {
            if (selectedIndex != -1) { gameBoyPanelCVC.initButtonColor(selectedIndex) }
            selectedIndex = index
            let color = categoryVM.getCategoryColor(category: categoryName.text!)
            gameBoyPanelCVC.changeButtonColor(index, color, categoryName.text!)
        }
        
        labelView.isHidden = selectedIndex != -1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameBoyPanelCVC = testView.testPanelViewController.gameBoyPanelCVC else { return }
        gameBoyPanelCVC.categoryCollectionView.isScrollEnabled = true
        labelView.removeFromSuperview()
    }
}

class GameBoySettingPanelCollectionViewCell: UICollectionViewCell {
    
}


