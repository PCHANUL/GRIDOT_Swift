//
//  LoadingCanvasViewModel.swift
//  GriDot
//
//  Created by 박찬울 on 2022/02/06.
//

import UIKit

class LoadingCanvasViewModel {
    var loadingImages: [UIImage] = []
    var loadingView: UIView
    var loadingAnimatedImage: UIImageView
    var loadingLabel: UILabel
    
    init(frame: CGRect) {
        loadingView = UIView(frame: frame)
        loadingAnimatedImage = UIImageView(frame: frame)
        loadingLabel = UILabel(frame: CGRect(
            x: (frame.width / 2) - 50,
            y: (frame.width / 2) - 10,
            width: 100,
            height: 22
        ))
        initLoadingImage("light")
    }
    
    func setLabelView(_ targetVC: DrawingViewController) {
        setLoadingCanvasView(targetVC.canvasView)
        targetVC.layerVM.frames = []
        targetVC.layerVM.reloadRemovedList()
        targetVC.layerVM.reloadLayerList()
        targetVC.previewImageToolBar.animatedPreview.image = UIImage(named: "empty")
    }
    
    func changeLoadingColorMode(_ colorMode: String) {
        if (colorMode != "dark" && colorMode != "light") { return }
        initLoadingImage(colorMode)
        loadingAnimatedImage.animationImages = loadingImages
        loadingAnimatedImage.startAnimating()
    }
    
    func initLoadingImage(_ colorMode: String) {
        loadingImages = []
        for index in 0...15 {
            loadingImages.append(UIImage(named: "loading\(index)_\(colorMode)")!)
        }
    }
    
    func setLoadingCanvasView(_ targetView: UIView) {
        let colorMode = (targetView.traitCollection.userInterfaceStyle == .dark) ? "dark" : "light"
        
        initLoadingImage(colorMode)
        loadingAnimatedImage.animationImages = loadingImages
        loadingAnimatedImage.animationDuration = TimeInterval(1)
        loadingAnimatedImage.startAnimating()
        loadingView.backgroundColor = .clear
        loadingView.addSubview(loadingAnimatedImage)
        targetView.insertSubview(loadingView, at: 0)
        addSubviewLoadingText(targetView)
    }
    
    func addSubviewLoadingText(_ targetView: UIView) {
        loadingLabel.text = "Loading"
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        loadingLabel.alpha = 0.5
        targetView.insertSubview(loadingLabel, at: 2)
    }
    
    func removeLoadingCanvasView(_ targetView: UIView) {
        let canvasSubviews = targetView.subviews
        loadingAnimatedImage.stopAnimating()
        if (canvasSubviews.count == 3) {
            loadingAnimatedImage.removeFromSuperview()
            loadingLabel.removeFromSuperview()
            loadingView.removeFromSuperview()
        }
    }
}
