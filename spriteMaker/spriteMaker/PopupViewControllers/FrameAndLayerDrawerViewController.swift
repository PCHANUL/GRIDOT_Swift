//
//  FrameAndLayerDrawerViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/24.
//

import UIKit

class FrameAndLayerDrawerViewController: UIViewController {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var drawerCV: UICollectionView!
    @IBOutlet weak var drawerView: UIView!
    var selectedSegment: String!
    var layerVM: LayerListViewModel!
    var layerHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: drawerView, side: "all", radius: drawerView.frame.width / 20)
        setViewShadow(target: drawerView, radius: 30, opacity: 1)
    }
    
    @IBAction func tappedBackGround(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

extension FrameAndLayerDrawerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedSegment {
        case "Frame":
            return layerVM.numsOfFrames
        case "Layer":
            return layerVM.numsOfLayer
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawerCell", for: indexPath) as? DrawerCell else { return UICollectionViewCell() }
        return cell
    }
}

extension FrameAndLayerDrawerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: layerHeight, height: layerHeight)
    }
}

class DrawerCell: UICollectionViewCell {
    
}
