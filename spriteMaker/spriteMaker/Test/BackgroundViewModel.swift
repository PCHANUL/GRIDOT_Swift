//
//  BackgroundViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/10.
//

import UIKit

class BackgroundViewModel {
    
    func drawBackground(_ context: CGContext) {
        guard let backgroundImage = UIImage(named: "industrial.v2") else { return }
        guard let filpedImage = flipImageVertically(originalImage: backgroundImage).cgImage else { return }
        
        context.draw(filpedImage, in: CGRect(x: 0, y: 0, width: 512 * 4, height: 512 * 4))
        
        
    }
}
