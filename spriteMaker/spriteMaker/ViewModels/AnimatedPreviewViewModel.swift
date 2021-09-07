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
    var animationSpeed: Int
    
    init() {
        categoryListVM = CategoryListViewModel()
        animationSpeed = 0
    }
    
    func calcAnimationSpeed(_ imageCount: Int) -> Double {
        let speed: Double
        
        speed = Double(imageCount) * Double(0.05) * (7 - Double(animationSpeed))
        return speed
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
        
        curCategory = "All"
        images = viewModel!.getAllImages()
        targetView!.layer.backgroundColor = UIColor.darkGray.cgColor
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(calcAnimationSpeed(images.count))
        targetImageView.startAnimating()
    }
    
    func changeAnimatedPreview() {
        guard (viewModel != nil) || (targetView != nil) else { return }
        guard let targetImageView = findImageViewOfUIView(targetView!) else { return }
        let images: [UIImage]
        
        images = viewModel!.getCategoryImages(category: curCategory)
        targetView!.layer.backgroundColor = categoryListVM.getCategoryColor(category: curCategory).cgColor
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(calcAnimationSpeed(images.count))
        targetImageView.startAnimating()
    }
    
    func setSelectedFramePreview() {
        guard (viewModel != nil) || (targetView != nil) else { return }
        guard let targetImageView = findImageViewOfUIView(targetView!) else { return }

        targetImageView.stopAnimating()
        targetImageView.image = viewModel?.selectedFrame?.renderedImage
    }
}
