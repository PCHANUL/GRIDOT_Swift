//
//  PreviewListViewController.swift
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
    
    @IBAction func tappedAdd(_ sender: Any) {
        // 마지막 아이템을 복제하여 추가합니다.
        let lastIndex = viewModel.numsOfItems - 1
        let lastItem = viewModel.item(at: lastIndex)
        viewModel.addItem(image: lastItem.image, item: lastItem.imageCanvasData)
        previewCollectionView.reloadData()
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
            cell.contentView.layer.borderWidth = 2
            cell.contentView.layer.borderColor = UIColor.white.cgColor
        }
        return cell
    }
}

extension PreviewListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreviewCell else { return }
        
        // [] 만약에 이전에 선택한 셀과 같은 셀을 선택한다면 선택 옵션팝업을 띄운다.
        
        cell.contentView.layer.borderWidth = 2
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.tappedPreview(index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreviewCell else { return }
        cell.contentView.layer.borderWidth = 0
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
    
    func checkExist(at index: Int) -> Bool {
        return index + 1 <= self.numsOfItems
    }
    
    func addItem(image item: UIImage, item imageCanvasData: String) {
        items.append(PreviewImage(image: item, imageCanvasData: imageCanvasData))
    }
    
    func item(at index: Int) -> PreviewImage {
        return items[index]
    }
    
    func updateItem(at index: Int, image item: UIImage, item imageCanvasData: String) {
        items[index] = PreviewImage(image: item, imageCanvasData: imageCanvasData)
    }
}

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewCell: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    
    var index: Int!
    var seletedIndex: Int = 0
    
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
    let imageCanvasData: String
}
