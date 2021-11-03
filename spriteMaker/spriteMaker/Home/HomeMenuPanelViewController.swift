//
//  HomeMenuViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/12.
//

import UIKit

class HomeMenuPanelViewController: UIViewController {
    @IBOutlet weak var homeMenuPanelCV: UICollectionView!
    
    weak var homeViewController: HomeViewController!
    var viewContentOffset: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewContentOffset = homeMenuPanelCV.contentOffset.x
    }
}

extension HomeMenuPanelViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
//        case 0:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as? GalleryCollectionViewCell else { return UICollectionViewCell() }
//            cell.homeMenuPanelController = self
//            cell.superViewController = homeViewController.superViewController
//            return cell
//        case 1:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingCollectionViewCell", for: indexPath) as? SettingCollectionViewCell else { return UICollectionViewCell() }
//            return cell
//                case 2:
//                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserInfoCollectionViewCell", for: indexPath) as? UserInfoCollectionViewCell else { return UICollectionViewCell() }
//                    return cell
        default:
            let cell = UICollectionViewCell()
            return cell
        }
    }
}

extension HomeMenuPanelViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: homeMenuPanelCV.bounds.width - 20, height: homeMenuPanelCV.bounds.height - 10)
    }
}

extension HomeMenuPanelViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        homeViewController.selectedTabIndex = Int(scrollView.contentOffset.x / homeMenuPanelCV.bounds.width)
        viewContentOffset = scrollView.contentOffset.x
        homeViewController.moveMenuToggle()
    }
}

// setting collectionView
class SettingCollectionViewCell: UICollectionViewCell {
    
}


// userInfo collectionView
class UserInfoCollectionViewCell: UICollectionViewCell {
    
}
