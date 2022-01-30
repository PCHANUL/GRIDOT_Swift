//
//  AnimatedPreviewViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/04/05.
//

import UIKit

class AnimatedPreviewViewModel {
    var targetView: UIView?
    var targetImageView: UIImageView!
    var viewModel: LayerListViewModel?
    var categoryListVM: CategoryListViewModel!
    
    var animatedImages: [UIImage]
    var animationSpeedIndex: Int
    var curCategory: String
    var isAnimated: Bool
    
    init() {
        categoryListVM = CategoryListViewModel()
        animatedImages = []
        animationSpeedIndex = 3
        curCategory = "All"
        isAnimated = false
    }
    
    var animationSpeed: Double {
        let speed: Double
        
        speed = Double(animatedImages.count) * Double(0.05) * (7 - Double(animationSpeedIndex))
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
    
    func  initAnimatedPreview() {
        curCategory = "All"
        changeAnimatedPreview()
    }
    
    func startAnimating() {
        isAnimated = true
        targetImageView.animationDuration = TimeInterval(animationSpeed)
        targetImageView.startAnimating()
    }
    
    func pauseAnimating() {
        isAnimated = false
        targetImageView.stopAnimating()
        targetImageView.image = animatedImages[0]
    }
    
    func changeAnimatedPreview() {
        guard (viewModel != nil) || (targetView != nil) else { return }
        
        if (curCategory == "All") {
            animatedImages = viewModel!.getAllImages()
            targetView!.layer.backgroundColor = UIColor.init(white: 0.2, alpha: 1).cgColor
        } else {
            animatedImages = viewModel!.getCategoryImages(category: curCategory)
            targetView!.layer.backgroundColor = categoryListVM.getCategoryColor(category: curCategory).cgColor
        }
        targetImageView.animationImages = animatedImages
        
        if (isAnimated) {
            startAnimating()
        } else {
            pauseAnimating()
        }
    }
    
    func setSelectedFramePreview() {
        guard (viewModel != nil) || (targetView != nil) else { return }

        targetImageView.stopAnimating()
        targetImageView.image = viewModel?.selectedFrame?.renderedImage
    }
}
