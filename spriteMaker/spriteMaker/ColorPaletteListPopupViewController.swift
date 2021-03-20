//
//  ColorPaletteListPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/12.
//

import UIKit

class ColorPaletteListPopupViewController: UIViewController {
    @IBOutlet var popupSuperView: UIView!
    @IBOutlet weak var colorPaletteCell: UIView!
    @IBOutlet weak var paletteListView: UIView!
    @IBOutlet weak var palettePopupView: UIView!
    @IBOutlet weak var paletteListCollctionView: UICollectionView!
    
    var positionY: CGFloat!
    var colorPaletteViewModel: ColorPaletteListViewModel!
    var colorCollectionList: UICollectionView!
    
    var isSettingClicked: Bool = false
    @IBOutlet weak var confirmButton: UIButton!
    
    var popupPositionContraint: NSLayoutConstraint!
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPaletteViewModel.paletteCollectionList = paletteListCollctionView
        paletteListView.layer.cornerRadius = colorPaletteCell.frame.width / 20
        confirmButton.layer.cornerRadius = 10
        setPopupViewPositionY(keyboardPositionY: 0, paletteIndex: IndexPath(item: 0, section: 0))
    }
    
    func setPopupViewPositionY(keyboardPositionY: CGFloat, paletteIndex: IndexPath) {
        print("asdf")
        // 초기화
        if popupPositionContraint != nil {
            popupPositionContraint.isActive = false
        }
        var additionalHeight: CGFloat = 0
        if keyboardPositionY != 0 {
            // 확대
            setPopupScale()
            // set additional position
            let basePosition = keyboardPositionY - (paletteListView.frame.minY + paletteListCollctionView.frame.minY * 1.5)
            let cellPosition = (paletteListCollctionView.cellForItem(at: paletteIndex)!.frame.maxY - paletteListCollctionView.contentOffset.y) * 1.5
            additionalHeight = basePosition - cellPosition
        } else {
            setPopupScale(isInit: true)
        }
        
        popupPositionContraint = colorPaletteCell.topAnchor.constraint(equalTo: palettePopupView.topAnchor, constant: positionY + additionalHeight)
        popupPositionContraint.isActive = true
        popupPositionContraint.priority = UILayoutPriority(500)
    }
    
    func setPopupScale(isInit: Bool = false) {
        UIView.animate(withDuration: 0.3, animations: {
            let scaleValue: CGFloat = isInit ? 1.0 : 1.5
            self.paletteListView.transform = CGAffineTransform(scaleX: scaleValue, y: scaleValue)
        })
    }
    
    @IBAction func settingOption(_ sender: Any) {
        // option 설정
        isSettingClicked = !isSettingClicked
        confirmButton.isHidden = !isSettingClicked
        paletteListCollctionView.reloadData()
    }
    
    @IBAction func createNewPalette(_ sender: Any) {
        colorPaletteViewModel.newPalette()
        let index = colorPaletteViewModel.selectedPaletteIndex
        colorPaletteViewModel.changeSelectedPalette(index: index + 1)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        let center = popupSuperView.frame.height / 2
        
        switch gesture.state {
        case .changed:
            let movement = popupSuperView.center.y + gesture.translation(in: paletteListView).y
            if movement > center {
                popupSuperView.center.y = popupSuperView.center.y + gesture.translation(in: paletteListView).y
                gesture.setTranslation(CGPoint.zero, in: popupSuperView)
            }
        case .ended:
            if popupSuperView.frame.minY > popupSuperView.frame.height / 10 {
                dismiss(animated: true, completion: nil)
            } else {
                popupSuperView.center.y = center
            }
        default: break
        }
    }
}

extension ColorPaletteListPopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPaletteViewModel.numsOfPalette
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPaletteCell", for: indexPath) as? ColorPaletteCell else {
            return UICollectionViewCell()
        }
        cell.colorPaletteViewModel = colorPaletteViewModel
        cell.paletteIndex = indexPath
        cell.isSettingClicked = isSettingClicked
        cell.superViewController = self
        cell.setPopupViewPositionY = setPopupViewPositionY
        return cell
        
    }
}

extension ColorPaletteListPopupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorPaletteViewModel.changeSelectedPalette(index: indexPath.row)
    }
}

extension ColorPaletteListPopupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height = width / 3
        return CGSize(width: width, height: height)
    }
}


