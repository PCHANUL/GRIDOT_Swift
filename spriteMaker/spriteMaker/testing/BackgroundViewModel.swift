//
//  BackgroundViewModel.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/10/10.
//

import UIKit

class BackgroundViewModel {
    
    func drawBackground(_ context: CGContext) {
        guard let ground1 = UIImage(named: "ground1") else { return }
        guard let ground2 = UIImage(named: "ground2") else { return }
        guard let ground3 = UIImage(named: "ground3") else { return }
        
        guard let filpedImage = flipImageVertically(originalImage: ground1).cgImage else { return }
        
        let len = 16 * 4
        var count = 0
        var posY = 0
        
        while (count != 5) {
            print(count)
            context.draw(filpedImage, in: CGRect(x: 0, y: posY, width: len, height: len))
            posY += len
            count += 1
        }
        
        
    }
}
