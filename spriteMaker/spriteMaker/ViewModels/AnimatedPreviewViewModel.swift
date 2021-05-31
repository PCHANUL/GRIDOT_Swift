//
//  AnimatedPreviewViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/05.
//

import UIKit

class AnimatedPreviewViewModel {
    var targetView: UIView?
    var viewModel: PreviewListViewModel?
    var curCategory: String = ""
    let categoryListVM = CategoryListViewModel()
    
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
        guard (viewModel != nil) || (targetView != nil) else { return }
        guard let targetImageView = findImageViewOfUIView(targetView!) else { return }
        let images: [UIImage]
        
        if isReset { curCategory = "" }
        if curCategory == "" {
            images = viewModel!.getAllImages()
            targetView!.layer.backgroundColor = UIColor.darkGray.cgColor
        } else {
            images = viewModel!.getCategoryImages(category: curCategory)
            targetView!.layer.backgroundColor = categoryListVM.getCategoryColor(category: curCategory).cgColor
        }
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(images.count)
        targetImageView.startAnimating()
    }
}
