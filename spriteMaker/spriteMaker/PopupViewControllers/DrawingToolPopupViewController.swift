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
    @IBOutlet weak var extToolList: UICollectionView!
    
    var popupPositionY: CGFloat!
    var popupPositionX: CGFloat!
    var drawingToolViewModel: DrawingToolViewModel!
    var drawingToolCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingToolList.topAnchor.constraint(equalTo: popupSuperView.topAnchor, constant: popupPositionY).isActive = true
        toolIcon.leadingAnchor.constraint(equalTo: toolListInnerView.leadingAnchor, constant: popupPositionX).isActive = true
        extToolList.layer.cornerRadius = extToolList.bounds.width / 5
    }
    
    @IBAction func tappedBG(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

extension DrawingToolPopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let items = drawingToolViewModel.currentItem().extTools else { return 0 }
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtToolCell", for: indexPath) as? ExtToolCell else {
            return UICollectionViewCell()
        }
        if let extTools = drawingToolViewModel.currentItem().extTools {
            let listHeight = CGFloat(extTools.count) * (extToolList.bounds.width * 0.6 + 10) + 10
            extToolList.heightAnchor.constraint(equalToConstant: listHeight).isActive = true
        }
        guard let extDrawingTool = drawingToolViewModel.currentItem().extTools?[indexPath.row] else { return cell }
        cell.toolImage.image = UIImage(named: extDrawingTool.name)
        return cell
    }
}

extension DrawingToolPopupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // drawingToolList의 아이콘을 선택된 아이콘으로 변경
        guard let extTools = drawingToolViewModel.currentItem().extTools else { return }
        drawingToolViewModel.changeCurrentItemName(name: extTools[indexPath.row].name)
        drawingToolCollection.reloadData()
        tappedBG(true)
    }
}

extension DrawingToolPopupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLength = extToolList.frame.width * 0.6
        return CGSize(width: sideLength, height: sideLength)
    }
}

class ExtToolCell: UICollectionViewCell {
    @IBOutlet weak var toolImage: UIImageView!
}
