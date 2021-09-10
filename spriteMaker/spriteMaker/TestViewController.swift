//
//  TestViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/06.
//

import UIKit

class TestViewController: UIViewController {
    var segmentedControl: UISegmentedControl!
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var toggleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var gameStickView: GameStick!
    @IBOutlet weak var gameStickImageView: UIImageView!
    
    var items = ["Game", "Message", "AppleWatch"]
    let gameCommands = ["up", "down", "left", "right"]
    
    override func viewDidLoad() {
        segmentedControl.selectedSegmentIndex = 0
        setSideCorner(target: tabBarView, side: "top", radius: tabBarView.bounds.width / 25)
        
        // set picker
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.transform = CGAffineTransform(rotationAngle: -90 * (.pi/180))
        picker.frame = pickerView.bounds
        picker.center = pickerView.center
        pickerView.addSubview(picker)
        
        // set gameStick
        gameStickView.testViewController = self
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
}

import AudioToolbox


class GameStick: UIView {
    weak var testViewController: TestViewController!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: self) else { return }
        guard let key = calcTouchPosition(pos) else { return }
        
        changeGameStickViewImage(key)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let pos = touches.first?.location(in: self) else { return }
        guard let key = calcTouchPosition(pos) else {
            initGameStickViewImage()
            return
        }
        changeGameStickViewImage(key)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        initGameStickViewImage()
    }
    
    func initGameStickViewImage() {
        testViewController.gameStickImageView.image = UIImage(systemName: "circle.grid.cross")
    }
    
    func changeGameStickViewImage(_ keyIndex: Int) {
        let keyCommand = testViewController.gameCommands[keyIndex]
        testViewController.gameStickImageView.image = UIImage(systemName: "circle.grid.cross.\(keyCommand).fill")
    }
    
    func calcTouchPosition(_ location: CGPoint) -> Int? {
        let calc_a = location.x > location.y
        let calc_b = self.frame.width - location.x > location.y

        if (calc_a && calc_b) { return 0 }
        else if (!calc_a && !calc_b) { return 1 }
        else if (!calc_a && calc_b) { return 2 }
        else if (calc_a && !calc_b) { return 3 }
        return nil
    }
    
}

extension TestViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 150
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.height
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 150, height: pickerView.frame.height)
        
        var pickerLabel = view as? UILabel

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.frame = CGRect(x: 0, y: 0, width: 150, height: pickerView.frame.height)
            pickerLabel?.font = UIFont(name: "System", size: 16)
            pickerLabel?.textAlignment = .center
            pickerLabel?.text = items[row]
            view.addSubview(pickerLabel!)
            view.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
        }
        
        return view
    }
    
}
