//
//  ExportOptionViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/01.
//

import UIKit

class ExportOptionViewController: UIViewController {
    @IBOutlet weak var optionStackView: UIStackView!
    @IBOutlet weak var addCategoryColor: UISwitch!
    @IBOutlet weak var isChangedToLivePhoto: UISwitch!
    @IBOutlet weak var isChangedToSpriteImage: UISwitch!
    @IBOutlet weak var imageSizeValue: UISegmentedControl!
    @IBOutlet weak var backgroundColorValue: UISegmentedControl!
    var gifLabel: UILabel!
    var pngLabel: UILabel!
    
    var selectedBackgroundColor: CGColor {
        print(backgroundColorValue.selectedSegmentIndex)
        switch backgroundColorValue.selectedSegmentIndex {
        case 0:
            return UIColor.black.cgColor
        case 1:
            return UIColor.white.cgColor
        default:
            return UIColor.clear.cgColor
        }
    }
    @IBAction func changePNGToSpriteImage(_ sender: UISwitch) {
        if (sender.isOn) {
            pngLabel.text = "Sprite"
        } else {
            pngLabel.text = "PNG"
        }
    }
    
    
    @IBAction func changeGifToLivephoto(_ sender: UISwitch) {
        if (sender.isOn) {
            gifLabel.text = "LivePhoto"
            backgroundColorValue.selectedSegmentIndex = 0
        } else {
            gifLabel.text = "GIF"
        }
    }
    
    @IBAction func changeBackgroundColor(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 2 && isChangedToLivePhoto.isOn) {
            let alert = UIAlertController(
                title: "Invalid background color",
                message: "LivePhoto should have a background color.",
                preferredStyle: UIAlertController.Style.alert
            )
            let confirmAction = UIAlertAction(title: "confirm", style: UIAlertAction.Style.default) { UIAlertAction in
                sender.selectedSegmentIndex = 0
            }
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
        }
    }
}
