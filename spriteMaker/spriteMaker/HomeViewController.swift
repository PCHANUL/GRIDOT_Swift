//
//  HomeViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/05.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var userStatusView: UIView!
    @IBOutlet weak var galleryCV: UICollectionView!
    
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOneSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 20)
        setOneSideCorner(target: userStatusView, side: "all", radius: userStatusView.bounds.width / 15)
        setOneSideCorner(target: galleryCV, side: "all", radius: galleryCV.bounds.width / 20)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let oneSideLen = (galleryCV.bounds.width / 3) - 10
        return CGSize(width: oneSideLen, height: oneSideLen)
    }
}

class HomeCollectionViewCell: UICollectionViewCell {
    
}
