//
//  DrawingToolPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/24.
//

import UIKit

class DrawingToolPopupViewController: UIViewController {
    @IBOutlet weak var popupSuperView: UIView!
    @IBOutlet weak var drawingToolList: UIView!
    @IBOutlet weak var toolListInnerView: UIView!
    @IBOutlet weak var toolIcon: UIView!
    @IBOutlet weak var toolIconList: UICollectionView!
    
    var popupPositionY: CGFloat!
    var popupPositionX: CGFloat!
    var drawingTool: DrawingTool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingToolList.topAnchor.constraint(equalTo: popupSuperView.topAnchor, constant: popupPositionY).isActive = true
        toolIcon.leadingAnchor.constraint(equalTo: toolListInnerView.leadingAnchor, constant: popupPositionX).isActive = true
        print(drawingTool)
    }
    
    @IBAction func tappedBG(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

//extension DrawingToolPopupViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//
//
//}
