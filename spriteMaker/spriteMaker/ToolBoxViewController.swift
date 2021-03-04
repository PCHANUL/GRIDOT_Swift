//
//  ToolBoxViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/03.
//

import UIKit

class ToolBoxViewController: UIViewController {
    @IBOutlet weak var toolCollectionView: UICollectionView!
    
    var previewImageToolBar = PreviewListCollectionViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ToolBoxViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewListCollectionViewCell", for: indexPath) as? PreviewListCollectionViewCell else {
                return UICollectionViewCell()
            }
            previewImageToolBar = cell
            return previewImageToolBar
        default:
            return UICollectionViewCell()
        }
    }
}

extension ToolBoxViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = toolCollectionView.bounds.width
        let height: CGFloat = toolCollectionView.bounds.height * 0.3
        return CGSize(width: width, height: height)
    }
}

