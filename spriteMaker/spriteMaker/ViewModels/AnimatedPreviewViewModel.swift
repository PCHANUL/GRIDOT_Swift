//
//  AnimatedPreviewViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/05.
//

import UIKit

class AnimatedPreviewViewModel {
    var targetImageView: UIImageView!
    let categoryList = CategoryList()
    var curCategory: String = ""
    var viewModel: PreviewListViewModel!
    
    init(viewModel: PreviewListViewModel, targetImageView: UIImageView) {
        self.viewModel = viewModel
        self.targetImageView = targetImageView
    }
    
    func changeSelectedCategory(category: String) {
        curCategory = category
    }
    
    func changeAnimatedPreview(isReset: Bool) {
        let images: [UIImage]
        if isReset { curCategory = "" }
        if curCategory == "" {
            images = viewModel.getAllImages()
            targetImageView.layer.backgroundColor = UIColor.white.cgColor
        } else {
            images = viewModel.getCategoryImages(category: curCategory)
            targetImageView.layer.backgroundColor = categoryList.getCategoryColor(category: curCategory).cgColor
        }
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(images.count)
        targetImageView.startAnimating()
    }
}
