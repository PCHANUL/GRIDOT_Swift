//
//  MiddleExtensionView.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/12/05.
//

import Foundation
import UIKit

class MiddleExtensionView: UIView {
    let sideButtonView: UIView
    let midExtensionBtn: UIView
    let midSideBtn: UIView
    
    init(_ sideButtonView: UIView, _ midSideBtn: UIView, _ midExtensionBtn: UIView) {
        var point = CGPoint(x: 0, y: 0)
        var size = CGSize(width: 0, height: 0)
        self.sideButtonView = sideButtonView
        self.midSideBtn = midSideBtn
        self.midExtensionBtn = midExtensionBtn
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        point.x += sideButtonView.frame.minX + 6
        point.y += (sideButtonView.window?.safeAreaInsets.top)!
        point.y += midExtensionBtn.frame.minY - 5
        size.height = midSideBtn.frame.maxY - midExtensionBtn.frame.minY + 10
        size.width = sideButtonView.frame.width * 2
        self.frame = CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
        
        let buttonView = UIView(frame: CGRect(
            x: 0,
            y: midExtensionBtn.frame.height + 8,
            width: midSideBtn.frame.width,
            height: midSideBtn.frame.height
        ))
        self.addSubview(buttonView)
        buttonView.backgroundColor = UIColor.init(named: "Color1")
        setSideCorner(target: buttonView, side: "all", radius: midSideBtn.bounds.width / 4)
        
        guard let iconImage = UIImage.init(named: "Eraser") else { return }
        let buttonIcon = UIImageView.init(image: iconImage)
        buttonIcon.frame = CGRect(
            x: 7,
            y: (buttonView.frame.height - (buttonView.frame.width - 14)) / 2,
            width: buttonView.frame.width - 14,
            height: buttonView.frame.width - 14)
        buttonView.addSubview(buttonIcon)
        
        let button = UIButton(frame: CGRect(
            x: 0, y: 5,
            width: midExtensionBtn.frame.width,
            height: midExtensionBtn.frame.height
        ))
        self.addSubview(button)
        setSideCorner(target: button, side: "all", radius: button.frame.height / 2)
        let imageConfig = UIImage.SymbolConfiguration(weight: .bold)
        button.setImage(UIImage.init(systemName: "xmark", withConfiguration: imageConfig), for: .normal)
        button.addTarget(self, action: #selector(removeExtensionView), for: .touchDown)
        button.backgroundColor = UIColor.init(named: "Color1")
        button.tintColor = UIColor.init(named: "Icon")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.sectionInset.top = 5
        layout.sectionInset.bottom = 5
        
        let toolCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.addSubview(toolCollectionView)
        toolCollectionView.register(MiddleExtensionCell.self, forCellWithReuseIdentifier: "middleExtensionCell")
        toolCollectionView.delegate = self
        toolCollectionView.dataSource = self
        toolCollectionView.showsVerticalScrollIndicator = false
        
        setSideCorner(target: toolCollectionView, side: "all", radius: toolCollectionView.frame.width / 4)
        toolCollectionView.translatesAutoresizingMaskIntoConstraints = false
        toolCollectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        toolCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        toolCollectionView.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 5).isActive = true
        toolCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func removeExtensionView() {
        self.removeFromSuperview()
    }
}


extension MiddleExtensionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "middleExtensionCell", for: indexPath) as? MiddleExtensionCell else { return UICollectionViewCell() }
        cell.backgroundColor = UIColor.init(named: "Color1")
        setSideCorner(target: cell, side: "all", radius: cell.frame.width / 4)
        
        return cell
    }
}

extension MiddleExtensionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sideLen = collectionView.frame.width - 10
        return CGSize(width: sideLen, height: sideLen)
    }
}

extension MiddleExtensionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

class MiddleExtensionCell: UICollectionViewCell {
}
