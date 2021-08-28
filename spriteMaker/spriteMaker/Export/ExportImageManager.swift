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
    
    func getResizedFrameImage(frame: Frame, size: CGSize) -> UIImage {
        let renderingManager: RenderingManager
        var images: [UIImage]
        
        renderingManager = RenderingManager(size)
        images = []
        for layer in frame.layers {
            images.append(renderingManager.renderLayerImage(stringToMatrix(layer!.gridData)))
        }
        return renderingManager.renderFrameImageWithUIImages(images)
    }
    
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
    
    func savePngToCameraRoll(image: UIImage) {
        var filename: URL
        
        filename = getDocumentsDirectory()!
        if let data = image.pngData() {
            filename = (getDocumentsDirectory()?.appendingPathComponent("image.png"))!
            try? data.write(to: filename)
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: filename)
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
    
    func getDocumentsDirectory() -> URL?  {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

class RenderingManager {
    let canvasRenderer: UIGraphicsImageRenderer
    let canvasSize: CGSize
    let canvas: Canvas
    
    init(_ canvasSize: CGSize) {
        self.canvasSize = canvasSize
        self.canvasRenderer = UIGraphicsImageRenderer(size: canvasSize)
        self.canvas = Canvas(canvasSize.width, 16, nil)
    }
    
    func renderLayerImage(_ gridData: [String : [Int : [Int]]]) -> UIImage {
        return canvasRenderer.image { context in
            canvas.drawSeletedPixels(context.cgContext, grid: gridData)
        }
    }
    
    func renderFrameImage(_ layers: [Layer?]) -> UIImage {
        return canvasRenderer.image { context in
            for idx in (0..<layers.count).reversed() {
                let flipedImage = canvas.flipImageVertically(originalImage: layers[idx]!.renderedImage)
                context.cgContext.draw(
                    flipedImage.cgImage!,
                    in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.width)
                )
            }
        }
    }
    
    func renderFrameImageWithUIImages(_ images: [UIImage]) -> UIImage {
        return canvasRenderer.image { context in
            for idx in (0..<images.count).reversed() {
                let flipedImage = canvas.flipImageVertically(originalImage: images[idx])
                context.cgContext.draw(
                    flipedImage.cgImage!,
                    in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.width)
                )
            }
        }
    }
    
    func renderSprite(_ frameDataArr: [FrameData], _ selectedFrameCount: Int) -> UIImage {
        let spriteRenderer: UIGraphicsImageRenderer
        let exportImageManager: ExportImageManager
        let imageSize: CGSize
        
        imageSize = CGSize(width: 500, height: 500)
        exportImageManager = ExportImageManager()
        spriteRenderer = UIGraphicsImageRenderer(
            size: CGSize(width: canvasSize.width * CGFloat(selectedFrameCount), height: canvasSize.height + 50)
        )
        
        var count: CGFloat = 0
        return spriteRenderer.image { context in
            for i in 0..<frameDataArr.count {
                if (frameDataArr[i].isSelected) {
                    
                    // get resized frameImages
                    let newImage = exportImageManager.getResizedFrameImage(
                        frame: frameDataArr[i].data,
                        size: imageSize
                    )
                    
                    // draw resized frameImages
                    let flipedImage = canvas.flipImageVertically(originalImage: newImage)
                    context.cgContext.draw(
                        flipedImage.cgImage!,
                        in: CGRect(
                            x: canvasSize.width * count,
                            y: 0,
                            width: canvasSize.width,
                            height: canvasSize.width
                        )
                    )
                    
                    // draw category color
                    context.cgContext.addRect(
                        CGRect(
                            x: canvasSize.width * count,
                            y: canvasSize.height,
                            width: canvasSize.width,
                            height: 50
                        )
                    )
                    context.cgContext.setFillColor(
                        CategoryListViewModel().getCategoryColor(category: frameDataArr[i].data.category).cgColor
                    )
                    context.cgContext.fillPath()
                    
                    count += 1
                }
            }
        }
    }
}
