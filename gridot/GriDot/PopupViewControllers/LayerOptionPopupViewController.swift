//
//  LayerOptionPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/23.
//

import UIKit

class LayerOptionPopupViewController: UIViewController {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var layerOption: UIView!
    @IBOutlet weak var ishiddenBtn: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    var layerListVM: LayerListViewModel!
    var popupPositionX: CGFloat!
    var popupPositionY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: layerOption, side: "all", radius: layerOption.bounds.height / 3)
        setPopupViewShadow(layerOption)
        topConstraint.constant = popupPositionY
        leadingConstraint.constant = popupPositionX - (layerOption.frame.width / 2)
    }
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedHidden(_ sender: Any) {
        layerListVM.toggleVisibilitySelectedLayer()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedDelete(_ sender: Any) {
        layerListVM.deleteSelectedLayer()
        dismiss(animated: false, completion: nil)
    }
}
