//
//  HomeMenuViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/12.
//

import UIKit

class HomeMenuPanelViewController: UIViewController {
    @IBOutlet weak var homeMenuPanelCV: UICollectionView!
    var superViewController: HomeViewController!
    var viewContentOffset: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewContentOffset = homeMenuPanelCV.contentOffset.x
    }
}

extension HomeMenuPanelViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCollectionViewCell", for: indexPath) as! galleryCollectionViewCell
        return cell
    }
}

extension HomeMenuPanelViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: homeMenuPanelCV.bounds.width - 20, height: homeMenuPanelCV.bounds.height - 20)
    }
}

extension HomeMenuPanelViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("panel")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        superViewController.selectedMenuIndex = Int(scrollView.contentOffset.x / homeMenuPanelCV.bounds.width)
        viewContentOffset = scrollView.contentOffset.x
        superViewController.moveMenuToggle()
    }
}



// gallery collectionView
class galleryCollectionViewCell: UICollectionViewCell {
    
}

extension galleryCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "spriteCollectionViewCell", for: indexPath) as! spriteCollectionViewCell
        return cell
    }
}


class spriteCollectionViewCell: UICollectionViewCell {
    
}
