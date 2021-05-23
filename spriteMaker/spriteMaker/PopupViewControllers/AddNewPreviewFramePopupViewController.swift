//
//  AddNewPreviewFramePopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/16.
//

import UIKit

class AddNewPreviewFramePopupViewController: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var previewListCV: UIView!
    @IBOutlet weak var newPreviewPopup: UIView!
    var previewListCVC: PreviewListCollectionViewCell!
    var popupPositionY: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        newPreviewPopup.layer.cornerRadius = previewListCV.bounds.width / 20
        newPreviewPopup.layer.masksToBounds = true
        newPreviewPopup.layer.shadowColor = UIColor.black.cgColor
        newPreviewPopup.layer.masksToBounds = false
        newPreviewPopup.layer.shadowOffset = CGSize(width: 0, height: 0)
        newPreviewPopup.layer.shadowRadius = 5
        newPreviewPopup.layer.shadowOpacity = 0.8
        
        previewListCV.topAnchor.constraint(equalTo: popupView.topAnchor, constant: popupPositionY).isActive = true
    }
    
    @IBAction func tappedBG(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tappedCopyBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        previewListCVC.previewVM.copyItem()
        previewListCVC.layerListVM.copyPreItem()
        previewListCVC.layerListVM.selectedLayerIndex = 0;
        
        let contentX = CGFloat(previewListCVC.previewVM.selectedPreview) * previewListCVC.cellWidth
        previewListCVC.previewImageCollection.contentOffset.x = contentX
        previewListCVC.reloadPreviewListItems()
    }
    
    @IBAction func tappedAddNewBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        previewListCVC.previewVM.addEmptyItem(isInit: false)
        previewListCVC.layerListVM.addEmptyItem(isInit: false)
        previewListCVC.layerListVM.selectedLayerIndex = 0;
        
        let contentX = CGFloat(previewListCVC.previewVM.selectedPreview) * previewListCVC.cellWidth
        previewListCVC.previewImageCollection.contentOffset.x = contentX
        previewListCVC.reloadPreviewListItems()
    }
    
}
