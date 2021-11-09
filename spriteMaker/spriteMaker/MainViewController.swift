//
//  MainViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/19.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var mainCollectionView: UICollectionView!
    var superViewController: ViewController!
    var galleryCollectionViewCell: GalleryCollectionViewCell!
    var drawingCollectionViewCell: DrawingCollectionViewCell!
    var testingCollectionViewCell: TestingCollectionViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testingCollectionViewCell = TestingCollectionViewCell()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        switch superViewController.selectedToggleStr {
        case "home":
            print("home")
        case "draw":
            print("draw")
            if (superViewController.coreData.hasIndexChanged) {
                updateData()
            }
        case "test":
            print("test")
            if (superViewController.coreData.hasIndexChanged) {
                DispatchQueue.main.async { [self] in
                    testingCollectionViewCell.updateTestData()
                }
            }
        default:
            return
        }
    }
    
    func updateData() {
        DispatchQueue.main.async { [self] in
            setLabelView(superViewController)
            DispatchQueue.main.async { [self] in
                drawingCollectionViewCell.updateCanvasData()
                drawingCollectionViewCell.removeLoadingImageView()
                
                drawingCollectionViewCell.previewImageToolBar.setOffsetForSelectedFrame()
                drawingCollectionViewCell.previewImageToolBar.setOffsetForSelectedLayer()
                superViewController.coreData.changeHasIndexChanged(false)
            }
        }
    }
}

extension MainViewController {
    func setLabelView(_ targetView: UIViewController) {
        drawingCollectionViewCell.loadingCanvasView()
        drawingCollectionViewCell.layerVM.frames = []
        drawingCollectionViewCell.layerVM.reloadRemovedList()
        drawingCollectionViewCell.layerVM.reloadLayerList()
        drawingCollectionViewCell.previewImageToolBar.animatedPreview.image = UIImage(named: "empty")
    }
    
    func removeLabelView() {
        DispatchQueue.main.async { [self] in
            self.drawingCollectionViewCell.removeLoadingImageView()
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        switch indexPath.row {
        case 0:
            galleryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as? GalleryCollectionViewCell
            galleryCollectionViewCell.mainViewController = self
            galleryCollectionViewCell.superViewController = superViewController
            return galleryCollectionViewCell
        case 1:
            drawingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingCollectionViewCell", for: indexPath) as? DrawingCollectionViewCell
            drawingCollectionViewCell.superViewController = superViewController
            return drawingCollectionViewCell
        case 2:
            testingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestingCollectionViewCell", for: indexPath) as? TestingCollectionViewCell
            testingCollectionViewCell.superViewController = superViewController
            return testingCollectionViewCell
        default:
            return UICollectionViewCell()
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let view = superViewController.mainContainerView!
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}
