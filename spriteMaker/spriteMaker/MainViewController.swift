//
//  MainViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/19.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var mainCollectionView: UICollectionView!
    var superViewController: ViewController!
    var drawingCollectionViewCell: DrawingCollectionViewCell!
    var testingCollectionViewCell: TestingCollectionViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            drawingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingCollectionViewCell", for: indexPath) as? DrawingCollectionViewCell
            drawingCollectionViewCell.superViewController = superViewController
            return drawingCollectionViewCell
        default:
            testingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestingCollectionViewCell", for: indexPath) as? TestingCollectionViewCell
            return testingCollectionViewCell
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let view = superViewController.mainContainerView!
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
