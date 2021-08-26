//
//  ExportImageManager.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/26.
//

//import ImageIO
//import AssetsLibrary

import UIKit
import MobileCoreServices
import Photos

class ExportImageManager {
    
    func generateGif(photos: [UIImage], filename: String, speed: String) -> Bool {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsDirectoryPath.appending(filename)
        let cfURL = URL(fileURLWithPath: path) as CFURL
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: speed]]
        
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
