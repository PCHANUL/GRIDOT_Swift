//
//  AnimatedPreviewViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/05.
//

import UIKit

class AnimatedPreviewViewModel {
    var targetView: UIView!
    var targetImageView: UIImageView!
    let categoryListVM = CategoryListViewModel()
    var viewModel: PreviewListViewModel!
    var curCategory: String = ""
    
    
    init(_ viewModel: PreviewListViewModel, _ targetView: UIView) {
        self.viewModel = viewModel
        self.targetView = targetView
        self.targetImageView = findImageViewOfUIView(targetView)
    }
    
    func changeSelectedCategory(category: String) {
        curCategory = category
    }
    
    func findImageViewOfUIView(_ targetView: UIView) -> UIImageView? {
        for subView in targetView.subviews where subView is UIImageView {
            return subView as? UIImageView
        }
        return nil
    }
    
    func changeAnimatedPreview(isReset: Bool) {
        let images: [UIImage]
        
        if isReset { curCategory = "" }
        if curCategory == "" {
            images = viewModel.getAllImages()
            targetView.layer.backgroundColor = UIColor.darkGray.cgColor
        } else {
            images = viewModel.getCategoryImages(category: curCategory)
            targetView.layer.backgroundColor = categoryListVM.getCategoryColor(category: curCategory).cgColor
        }
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(images.count)
        targetImageView.startAnimating()
    }
}
