//
//  ExportOptionViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/01.
//

import UIKit

class ExportOptionViewController: UIViewController {
    @IBOutlet weak var imageSizeValue: UISegmentedControl!
    @IBOutlet weak var addCategoryColor: UISwitch!
    var gifLabel: UILabel!
    
    @IBAction func changeGifToLivephoto(_ sender: UISwitch) {
        if (sender.isOn) {
            gifLabel.text = "LivePhoto"
        } else {
            gifLabel.text = "GIF"
        }
    }
}
