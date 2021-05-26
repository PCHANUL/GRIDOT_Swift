//
//  LayerOptionPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/23.
//

import UIKit

class LayerOptionPopupViewController: UIViewController {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var previewListCV: UIView!
    @IBOutlet weak var layerOption: UIView!
    @IBOutlet weak var ishiddenBtn: UIButton!
    
    var layerListVM: LayerListViewModel!
    var popupPositionY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layerOption.layer.cornerRadius = previewListCV.bounds.width / 20
        layerOption.layer.masksToBounds = true
        layerOption.layer.shadowColor = UIColor.black.cgColor
        layerOption.layer.masksToBounds = false
        layerOption.layer.shadowOffset = CGSize(width: 0, height: 0)
        layerOption.layer.shadowRadius = 5
        layerOption.layer.shadowOpacity = 0.8
        
        previewListCV.topAnchor.constraint(equalTo: superView.topAnchor, constant: popupPositionY).isActive = true
        
    }
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedHidden(_ sender: Any) {
        layerListVM.toggleVisibilitySelectedLayer()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedDelete(_ sender: Any) {
        // [] 레이어 제거
        
    }
}
