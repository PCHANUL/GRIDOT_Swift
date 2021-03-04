//
//  AnimatedPreviewPopupViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/03/01.
//

import UIKit

class AnimatedPreviewPopupViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var superCollectionView: UIView!
    @IBOutlet weak var animatedPreview: UIView!
    @IBOutlet weak var previewList: UIView!
    @IBOutlet var superView: UIView!
    var categorys: [String] = []
    let categoryList = CategoryList()
    var nums = 0
    var animatedPreviewClass: AnimatedPreviewClass!
    var positionY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cornerRadius = animatedPreview.bounds.width / 5
        superCollectionView.layer.cornerRadius = cornerRadius
        previewList.topAnchor.constraint(equalTo: superView.topAnchor, constant: positionY).isActive = true
    }
    @IBAction func tappedCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func tappedResetButton(_ sender: Any) {
        animatedPreviewClass.changeAnimatedPreview(isReset: true)
        dismiss(animated: true, completion: nil)
    }
}

extension AnimatedPreviewPopupViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimatedPreviewPopupCell", for: indexPath) as? AnimatedPreviewPopupCell else {
            return AnimatedPreviewPopupCell()
        }
        cell.layer.cornerRadius = 20
        let index = categoryList.indexOfCategory(name: categorys[indexPath.row])
        cell.backgroundColor = categoryList.item(at: index).color
        cell.updateLabel(text: categorys[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
        
        headerView.layer.cornerRadius = 20
        return headerView
    }
}

extension AnimatedPreviewPopupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height = width / 2
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height = width / 2
        return CGSize(width: width, height: height)
    }
}

extension AnimatedPreviewPopupViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 클릭시 animatedPreview의 배경색이 바뀌며 해당 카테고리만 재생된다.
        animatedPreviewClass.changeSelectedCategory(category: categorys[indexPath.row])
        animatedPreviewClass.changeAnimatedPreview(isReset: false)
        dismiss(animated: true, completion: nil)
    }
}

class AnimatedPreviewPopupCell: UICollectionViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    
    func updateLabel(text: String) {
        categoryLabel.text = text
    }
}

