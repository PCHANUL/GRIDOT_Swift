//
//  previewListViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/22.
//

import UIKit

class PreviewListViewController: UIViewController {
    
    @IBOutlet weak var previewCollectionView: UICollectionView!
    let viewModel = PreviewListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension PreviewListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numsOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }
        
        let preview = viewModel.item(at: indexPath.item)
        cell.updatePreview(item: preview, index: indexPath.item)
        
        if cell.seletedIndex == indexPath.item {
            cell.previewCell.layer.borderWidth = 3
            cell.previewCell.layer.borderColor = UIColor.yellow.cgColor
        }
        
        return cell
    }
}

extension PreviewListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreviewCell else { return }
        cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        cell.tappedPreview(index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreviewCell else { return }
        cell.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
}

extension PreviewListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let sideLength = view.bounds.height
        return CGSize(width: sideLength, height: sideLength)
    }
}

class PreviewListViewModel {
    private var items: [PreviewImage] = []
    
    var numsOfItems: Int {
        return items.count
    }
    
    func addItem(image item: UIImage) {
        items.append(PreviewImage(image: item))
        print(items)
    }
    
    func item(at index: Int) -> PreviewImage {
        return items[index]
    }
    
    func updateItem(at index: Int, image item: UIImage) {
        items[index] = PreviewImage(image: item)
    }
}

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewCell: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    
    var index: Int!
    var seletedIndex: Int!
    
    func updatePreview(item: PreviewImage, index: Int) {
        previewImage.image = item.image
        self.index = index
    }
    
    func tappedPreview(index: Int) {
        self.seletedIndex = index
    }
}

struct PreviewImage {
    let image: UIImage
}
