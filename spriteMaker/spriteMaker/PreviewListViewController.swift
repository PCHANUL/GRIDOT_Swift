//
//  previewListViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/02/22.
//

import UIKit

class PreviewListViewController: UIViewController {
    
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewCell", for: indexPath) as? PreviewCell else {
            return UICollectionViewCell()
        }
        
        
    }
    
    
}

class PreviewListViewModel {
    
    // UIImage를 저장하여 crud를 처리한다.
    
    private var items: [UIImage] = []
    
    var numsOfItems: Int {
        return items.count
    }
    
    func addItem(image item: UIImage) {
        items.append(item)
    }
    
    func item(at index: Int) -> UIImage {
        return items[index]
    }
    
    func updateItem(at index: Int, image item: UIImage) {
        items[index] = item
    }
    
}

class PreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    
    func updatePreview(item: UIImage) {
        previewImage.image = item
    }
}
