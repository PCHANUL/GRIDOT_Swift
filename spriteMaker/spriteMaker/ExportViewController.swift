//
//  ExportViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/07.
//

import UIKit
import ImageIO
import MobileCoreServices
import Photos
import AssetsLibrary

class ExportViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var closeHandle: UIView!
    var superViewController: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: backgroundView, side: "top", radius: backgroundView.bounds.width / 25)
        setSideCorner(target: closeHandle, side: "all", radius: closeHandle.frame.height / 2)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // start animated image
        let view = superViewController.panelContainerViewController.previewImageToolBar.animatedPreview!
        view.startAnimating()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let destination = segue.destination as? ExportPanelViewController else { return }
    }
    
    func animateImages(_ data: Time?, targetImageView: UIImageView) {
        let images: [UIImage]
        
        if (data == nil) { return }
        images = data!.frames.map { frame in
            return frame.renderedImage
        }
        targetImageView.animationImages = images
        targetImageView.animationDuration = TimeInterval(images.count)
        targetImageView.startAnimating()
    }
    
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedSave(_ sender: Any) {
        guard let time = superViewController.timeMachineVM.presentTime else {
            return
        }
        let images = time.frames.map { frame in
            return frame.renderedImage
        }

        if generateGif(photos: images, filename: "/file.gif") {
            saveGifToCameraRoll(filename: "/file.gif")
            print("success")
        } else {
            print("failed")
        }
    }
    
    func generateGif(photos: [UIImage], filename: String) -> Bool {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsDirectoryPath.appending(filename)
        let cfURL = URL(fileURLWithPath: path) as CFURL
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.125]]
        
        if let destination = CGImageDestinationCreateWithURL(cfURL, kUTTypeGIF, photos.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
                for photo in photos {
                    CGImageDestinationAddImage(destination, photo.cgImage!, gifProperties as CFDictionary?)
                }
                return CGImageDestinationFinalize(destination)
            }
        return false
    }
    
    func saveGifToCameraRoll(filename: String) {
        if let docsDirectory = getDocumentsDirectory() {
            let fileUrl: URL = docsDirectory.appendingPathComponent(filename)
            do {
                let data = try Data(contentsOf: fileUrl)
                if let _ = UIImage(data: data) {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl)
                        }, completionHandler: {completed, error in
                            if error != nil {
                                print("error")
                            } else if completed {
                                print("completed")
                            } else {
                                print("not completed")
                            }
                    })
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    func getDocumentsDirectory() -> URL?  {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

class ExportPanelViewController: UIViewController {
    var oneSideLength: CGFloat!
    
}

extension ExportPanelViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pngExportCell", for: indexPath) as! pngExportCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifExportCell", for: indexPath) as! gifExportCell
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "spriteExportCell", for: indexPath) as! spriteExportCell
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    
}

extension ExportPanelViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let len = oneSideLength!
        return CGSize(width: len, height: len - 10)
    }
}

class pngExportCell: UICollectionViewCell {
    
}

class gifExportCell: UICollectionViewCell {
    
}

class spriteExportCell: UICollectionViewCell {
    
}


