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
    var layerListVM: LayerListViewModel!
    var popupPositionY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layerOption.layer.cornerRadius = previewListCV.bounds.width / 20
        layerOption.layer.masksToBounds = true
        previewListCV.topAnchor.constraint(equalTo: superView.topAnchor, constant: popupPositionY).isActive = true
    }
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedHidden(_ sender: Any) {
        // [] layerVM에서 해당 레이어를 숨기기
        // [] layerVM을 확인하여 해당 레이어가 숨긴 상태이라면 이미지 바꾸기
        //
    }
    
    @IBAction func tappedDelete(_ sender: Any) {
        // [] 레이어 제거
    }
}
