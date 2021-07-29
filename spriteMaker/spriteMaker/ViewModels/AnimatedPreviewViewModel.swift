//
//  AnimatedPreviewViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/05.
//

import UIKit

class AnimatedPreviewViewModel {
    var targetView: UIView?
    var viewModel: LayerListViewModel?
    var categoryListVM: CategoryListViewModel!
    var curCategory: String = ""
    
    init() {
        categoryListVM = CategoryListViewModel()
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
    
    func initAnimatedPreview() {
        guard (viewModel != nil) || (targetView != nil) else { return }
        guard let targetImageView = findImageViewOfUIView(targetView!) else { return }
        let images: [UIImage]
        
        curCategory = ""
        images = viewModel!.getAllImages()
        targetView!.layer.backgroundColor = UIColor.darkGray.cgColor
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(images.count)
        targetImageView.startAnimating()
    }
    
    func changeAnimatedPreview() {
        guard (viewModel != nil) || (targetView != nil) else { return }
        guard let targetImageView = findImageViewOfUIView(targetView!) else { return }
        let images: [UIImage]
        
        images = viewModel!.getCategoryImages(category: curCategory)
        targetView!.layer.backgroundColor = categoryListVM.getCategoryColor(category: curCategory).cgColor
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(images.count)
        targetImageView.startAnimating()
    }
}
