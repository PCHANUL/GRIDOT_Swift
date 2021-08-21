//
//  ExportViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/07.
//

import UIKit

class ExportViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    var superViewController: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 25)
    }
    
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedBackground(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedSave(_ sender: Any) {
//        savePhotoLibrary(image: UIImage(named: "empty")!)
        
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
    
    func savePhotoLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { isSuccess, error in
                    print(" 이미지 저장 완료되었는가? \(isSuccess)")
                }
            } else {
                // 권한을 다시 요청
                print("권한을 받지 못함")
            }
        }
    }
    
    func getDocumentsDirectory() -> URL?  {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
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
}

import ImageIO
import MobileCoreServices
import Photos
import AssetsLibrary

class GifManager {
    
    private func getDocumentsDirectory() -> URL?  {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    public func generateGif(photos: [UIImage], filename: String) -> Bool {
        if let docsDirectory = getDocumentsDirectory() {
            let url = docsDirectory.appendingPathComponent(filename)
            let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
            let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: 0.125]]
            
            if let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, photos.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
                for photo in photos {
                    CGImageDestinationAddImage(destination, photo.cgImage!, gifProperties as CFDictionary?)
                }
                return CGImageDestinationFinalize(destination)
            }
        }
        return false
    }

    public func saveGifToCameraRoll(filename: String) {
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
}
