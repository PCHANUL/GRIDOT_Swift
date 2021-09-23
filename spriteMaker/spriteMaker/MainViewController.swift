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
    
    var toastLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testingCollectionViewCell = TestingCollectionViewCell()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x != 0) {
            print("scrolled")
            testingCollectionViewCell.updateTestData()
        }
    }
}

extension MainViewController {
    func setLabelView(_ targetView: UIViewController) {
        toastLabel = UILabel(frame: CGRect(x: targetView.view.frame.size.width/2 - 150, y: targetView.view.frame.size.height/2 - 100, width: 300, height: 200))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.text = "로딩중"
        toastLabel.alpha = 0.8
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        targetView.view.addSubview(toastLabel)
    }
    
    func removeLabelView() {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 1,
                delay: 0,
                options: .curveEaseOut,
                animations: { self.toastLabel.alpha = 0.0 },
                completion: {(isCompleted) in self.toastLabel.removeFromSuperview() }
            )
        }
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
            testingCollectionViewCell.superViewController = superViewController
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
