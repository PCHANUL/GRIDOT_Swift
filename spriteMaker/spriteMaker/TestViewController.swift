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
    
    var items = ["Game", "Message", "AppleWatch"]
    
    override func viewDidLoad() {
        print(pickerView.frame)
        segmentedControl.selectedSegmentIndex = 0
        
        setSideCorner(target: tabBarView, side: "top", radius: tabBarView.bounds.width / 25)
        print(pickerView.frame)
        let picker = UIPickerView()
        
        picker.dataSource = self
        picker.delegate = self
        
        picker.transform = CGAffineTransform(rotationAngle: -90 * (.pi/180))
        picker.frame = pickerView.bounds
        picker.center = pickerView.center
        
        pickerView.addSubview(picker)
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
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
