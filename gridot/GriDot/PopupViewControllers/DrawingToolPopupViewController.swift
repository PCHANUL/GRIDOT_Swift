//
//  DrawingToolPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/24.
//

import UIKit

class DrawingToolPopupViewController: UIViewController {
    @IBOutlet weak var popupSuperView: UIView!
    @IBOutlet weak var extToolList: UICollectionView!
    @IBOutlet weak var listHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var listWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var listLeadingContraint: NSLayoutConstraint!
    @IBOutlet weak var listTopContraint: NSLayoutConstraint!
    
    var popupPositionY: CGFloat!
    var popupPositionX: CGFloat!
    var drawingToolCollection: UICollectionView!
    var changeMainToExt: ((_: Int)->Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: extToolList, side: "all", radius: extToolList.frame.width / 5)
        setViewShadow(target: extToolList, radius: 10, opacity: 0.2)
    }
    
    @IBAction func tappedBG(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

extension DrawingToolPopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreData.shared.selectedExtTools.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtToolCell", for: indexPath) as? ExtToolCell else {
            return UICollectionViewCell()
        }
        let extTools = CoreData.shared.selectedExtTools
        let listHeight = CGFloat(extTools.count) * (extToolList.bounds.width * 0.6 + 10) + 10
        
        extToolList.heightAnchor.constraint(equalToConstant: listHeight).isActive = true
        cell.toolImage.image = UIImage(named: extTools[indexPath.row])
        return cell
    }
}

extension DrawingToolPopupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // drawingToolList의 아이콘을 선택된 아이콘으로 변경
        changeMainToExt(indexPath.row)
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
