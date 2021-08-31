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
        renderingManager = RenderingManager(exportData.imageSize, exportData.isCategoryAdded)
        
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
    let canvas: Canvas
    let canvasSize: CGSize
    let categoryColorHeight: CGFloat
    let layerRenderer: UIGraphicsImageRenderer
    let frameRenderer: UIGraphicsImageRenderer
    
    init(_ canvasSize: CGSize, _ isCategoryAdded: Bool) {
        self.canvas = Canvas(canvasSize.width, 16, nil)
        self.canvasSize = canvasSize
        
        // Frame image의 height를 위해 isCategoryAdded 값에 따라서 categoryColorHeight 설정
        self.categoryColorHeight = isCategoryAdded ? canvasSize.height / 10 : 0
        self.layerRenderer = UIGraphicsImageRenderer(size: canvasSize)
        self.frameRenderer = UIGraphicsImageRenderer(
            size: CGSize(width: canvasSize.width, height: canvasSize.height + self.categoryColorHeight)
        )
    }
    
    func renderLayerImage(_ gridData: [String : [Int : [Int]]]) -> UIImage {
        return layerRenderer.image { context in
            canvas.drawSeletedPixels(context.cgContext, grid: gridData)
        }
    }
    
    func renderFrameImage(_ layers: [Layer?]) -> UIImage {
        return frameRenderer.image { context in
            for idx in (0..<layers.count).reversed() {
                let flipedImage = canvas.flipImageVertically(originalImage: layers[idx]!.renderedImage)
                context.cgContext.draw(
                    flipedImage.cgImage!,
                    in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height)
                )
            }
        }
    }
    
    func getRerenderedFrameImage(_ renderingManager: RenderingManager, _ exportData: ExportData) -> [UIImage] {
        var layerImages: [UIImage]
        var frameImages: [UIImage]
        var newFrameImage: UIImage
        
        frameImages = []
        for frameData in exportData.frameDataArr {
            if (frameData.isSelected) {
                layerImages = []
                for layer in frameData.data.layers {
                    layerImages.append(renderLayerImage(stringToMatrix(layer!.gridData)))
                }
                newFrameImage = renderFrameImageToExport(frameRenderer, layerImages, exportData, frameData.data.category)
                frameImages.append(newFrameImage)
            }
        }
        return frameImages
    }
    
    func renderFrameImageToExport(_ renderer: UIGraphicsImageRenderer, _ images: [UIImage], _ exportData: ExportData, _ category: String) -> UIImage {
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
                context.cgContext.addRect(CGRect(x: 0, y: canvasSize.height, width: canvasSize.width, height: categoryColorHeight))
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
                height: canvasSize.height + categoryColorHeight
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
                        height: canvasSize.height + categoryColorHeight
                    )
                )
            }
        }
    }
}
