//
//  RenderingManager.swift
//  GriDot
//
//  Created by 박찬울 on 2022/02/05.
//

import UIKit
import Foundation

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
    
    func renderLayerImageInt32(data: [Int]) -> UIImage {
        return layerRenderer.image { context in
            guard let pixelWidth = canvas.onePixelLength else { return }
            drawGridPixelsInt32(context.cgContext, data, pixelWidth)
        }
    }
    
    func renderLayerImageWithBG(_ gridData: [Int], _ backgroundColor: CGColor) -> UIImage {
        return layerRenderer.image { context in
            guard let onePixelLength = canvas.onePixelLength else { return }
            context.cgContext.setStrokeColor(UIColor.clear.cgColor)
            context.cgContext.setFillColor(backgroundColor)
            context.cgContext.addRect(CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
            context.cgContext.drawPath(using: .fillStroke)
            drawGridPixelsInt32(context.cgContext, gridData, onePixelLength)
        }
    }
    
    func renderFrameImage(_ layers: [Layer]) -> UIImage {
        return frameRenderer.image { context in
            for idx in 0..<layers.count {
                let flipedImage = flipImageVertically(originalImage: layers[idx].renderedImage)
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
                    layerImages.append(renderLayerImageWithBG(layer.data, exportData.imageBackgroundColor))
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
            for idx in 0..<images.count {
                let flipedImage = flipImageVertically(originalImage: images[idx])
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
                let flipedImage = flipImageVertically(originalImage: images[i])
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
