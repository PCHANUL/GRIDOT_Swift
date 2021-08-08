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
