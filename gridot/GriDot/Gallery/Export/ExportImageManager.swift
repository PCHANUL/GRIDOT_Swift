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
    func exportPng(_ exportData: ExportData) -> [URL] {
        let renderingManager: RenderingManager
        var filePath: [URL]
        var images: [UIImage]
        
        // 초기 렌더링 설정
        renderingManager = RenderingManager(exportData.imageSize, exportData.isCategoryAdded)
        
        // 이미지 렌더링
        images = renderingManager.getRerenderedFrameImage(renderingManager, exportData)
        
        // 파일 경로에 파일 생성
        filePath = images.indices.map { idx in
            let path = getAppendedDocumentsDirectory("\(exportData.title) \(idx).png")!
            if let data = images[idx].pngData() {
                try? data.write(to: path)
            }
            return path
        }
        return filePath
    }
    
    func exportSprite(_ exportData: ExportData) -> URL {
        let renderingManager: RenderingManager
        let sprite: UIImage
        var filePath: URL
        var images: [UIImage]
        
        // 초기 렌더링 설정
        renderingManager = RenderingManager(exportData.imageSize, exportData.isCategoryAdded)
        
        // 이미지 렌더링
        images = renderingManager.getRerenderedFrameImage(renderingManager, exportData)
        sprite = renderingManager.renderSprite(exportData, images)
        
        filePath = getAppendedDocumentsDirectory("\(exportData.title).png")!
        if let data = sprite.pngData() {
            try? data.write(to: filePath)
        }
        return filePath
    }
    
    func exportGif(_ exportData: ExportData, _ speed: Double) -> URL {
        let renderingManager: RenderingManager
        var images: [UIImage]
        var filePath: URL
        
        // 초기 런더링 설정
        renderingManager = RenderingManager(exportData.imageSize, exportData.isCategoryAdded)
        
        // 이미지 렌더링
        images = renderingManager.getRerenderedFrameImage(renderingManager, exportData)
        
        // 파일 경로에 파일 생성
        filePath = getAppendedDocumentsDirectory("\(exportData.title).gif")!
        if (!generateGif(photos: images, filePath: filePath, speed: String(speed))) {
            print("failed")
        }
        return filePath
    }
    
    func exportLivePhoto(_ exportData: ExportData, _ speed: Double) {
        let images = ExportImageManager().getImageWithBG(exportData)
        let settings = CXEImagesToVideo.videoSettings(
            codec: AVVideoCodecType.h264.rawValue,
            width: Int(exportData.imageSize.width * 3),
            height: Int(exportData.imageSize.height * 3)
        )
        
        let movieMaker = CXEImagesToVideo(videoSettings: settings)
        movieMaker.createMovieFrom(images: images){ (videoURL: URL) in
            
            // get still image url
            let photoURL = self.getAppendedDocumentsDirectory("\(exportData.title).png")!
            if let data = images[0].pngData() {
                try? data.write(to: photoURL)
            }
            
            // gnerate LivePhoto
            LivePhoto.generate(
                from: photoURL,
                videoURL: videoURL,
                progress: { percent in },
                completion: { (livePhoto: PHLivePhoto?, resources: LivePhoto.LivePhotoResources?) in
                    LivePhoto.saveToLibrary(resources!) { (success: Bool) in
                    print(success)
                }
            })
        }
    }
    
    func generateGif(photos: [UIImage], filePath: URL, speed: String) -> Bool {
        let cfURL = filePath as CFURL
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
    
    func getImageWithBG(_ exportData: ExportData) -> [UIImage] {
        let renderingManager = RenderingManager(exportData.imageSize, exportData.isCategoryAdded)
        return renderingManager.getRerenderedFrameImage(renderingManager, exportData)
    }
    
    func getAppendedDocumentsDirectory(_ pathComponent: String) -> URL? {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return path.appendingPathComponent("\(pathComponent)")
    }
}
