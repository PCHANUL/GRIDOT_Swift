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
    
    func exportPng(_ exportData: ExportData, _ selectedFrameCount: Int) -> URL {
        let renderingManager: RenderingManager
        let sprite: UIImage
        var filePath: URL
        var images: [UIImage]
        
        // 초기 렌더링 설정
        renderingManager = RenderingManager(exportData.imageSize)
        
        // 이미지 렌더링
        images = renderingManager.getRerenderedFrameImage(renderingManager, exportData)
        sprite = renderingManager.renderSprite(exportData, selectedFrameCount, images)
        
        // 파일 경로에 파일 생성
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
        renderingManager = RenderingManager(exportData.imageSize)
        
        // 이미지 렌더링
        images = renderingManager.getRerenderedFrameImage(renderingManager, exportData)
        
        // 파일 경로에 파일 생성
        filePath = getAppendedDocumentsDirectory("\(exportData.title).gif")!
        if (!generateGif(photos: images, filePath: filePath, speed: String(speed))) {
            print("failed")
        }
        return filePath
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
    
    func getAppendedDocumentsDirectory(_ pathComponent: String) -> URL? {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return path.appendingPathComponent("\(pathComponent).png")
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
    
    func getRerenderedFrameImage(_ renderingManager: RenderingManager, _ exportData: ExportData) -> [UIImage] {
        var layerImages: [UIImage]
        var frameImages: [UIImage]
        var newFrameImage: UIImage
        let noneCategoryRenderer: UIGraphicsImageRenderer
        let categoryRenderer: UIGraphicsImageRenderer
        
        // set renderers
        noneCategoryRenderer = UIGraphicsImageRenderer(size: canvasSize)
        categoryRenderer = UIGraphicsImageRenderer(size: CGSize(width: exportData.imageSize.width, height: exportData.imageSize.height + 50))
        
        frameImages = []
        for frameData in exportData.frameDataArr {
            if (frameData.isSelected) {
                layerImages = []
                for layer in frameData.data.layers {
                    layerImages.append(renderLayerImage(stringToMatrix(layer!.gridData)))
                }
                
                // isCategoryAdded 값에 따라서 다른 렌더러
                if (exportData.isCategoryAdded) {
                    newFrameImage = renderFrameImageToExport(categoryRenderer, layerImages, exportData, frameData.data.category)
                } else {
                    newFrameImage = renderFrameImageToExport(noneCategoryRenderer, layerImages, exportData, frameData.data.category)
                }
                frameImages.append(newFrameImage)
            }
        }
        return frameImages
    }
    
    func renderFrameImageToExport(_ renderer: UIGraphicsImageRenderer,_ images: [UIImage], _ exportData: ExportData, _ category: String) -> UIImage {
        let categoryColor: CGColor
        
        categoryColor = CategoryListViewModel().getCategoryColor(category: category).cgColor
        return renderer.image { context in
            for idx in (0..<images.count).reversed() {
                let flipedImage = canvas.flipImageVertically(originalImage: images[idx])
                context.cgContext.draw(
                    flipedImage.cgImage!,
                    in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height)
                )
            }
            
            // draw category color
            if (exportData.isCategoryAdded) {
                context.cgContext.addRect(
                    CGRect(
                        x: 0,
                        y: canvasSize.height,
                        width: canvasSize.width,
                        height: 50
                    )
                )
                context.cgContext.setFillColor(categoryColor)
                context.cgContext.fillPath()
            }
        }
    }
    
    func renderSprite(_ exportData: ExportData, _ selectedFrameCount: Int, _ images: [UIImage]) -> UIImage {
        let spriteRenderer: UIGraphicsImageRenderer
        
        spriteRenderer = UIGraphicsImageRenderer(
            size: CGSize(
                width: canvasSize.width * CGFloat(selectedFrameCount),
                height: exportData.isCategoryAdded ? canvasSize.height + 50 : canvasSize.height
            )
        )
        
        return spriteRenderer.image { context in
            for i in 0..<images.count {
                // draw resized frameImages
                let flipedImage = canvas.flipImageVertically(originalImage: images[i])
                context.cgContext.draw(
                    flipedImage.cgImage!,
                    in: CGRect(
                        x: canvasSize.width * CGFloat(i),
                        y: 0,
                        width: canvasSize.width,
                        height: canvasSize.width
                    )
                )
            }
        }
    }
}
