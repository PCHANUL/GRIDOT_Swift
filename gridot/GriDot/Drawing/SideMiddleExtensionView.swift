//
//  MiddleExtensionView.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/12/05.
//

import Foundation
import UIKit

class MiddleExtensionView: UIView {
    var setButtonImage: () -> Void
    var buttonIcon: UIImageView = UIImageView()
    var superView: UIView = UIView()
    var closeButton: UIButton!
    var currentSide: direction!
    
    init(_ midSideBtnView: UIView, _ superViewRect: CGRect, _ currentSide: direction, _ setButtonImage: @escaping ()->Void) {
        let screenSize = UIScreen.main.bounds.size
        self.setButtonImage = setButtonImage
        self.currentSide = currentSide
        
        super.init(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        
        superView = UIView(frame: superViewRect)
        setBackgroundView()
        setCloseButton(midSideBtnView)
        setMainButton(midSideBtnView)
        setSuperView(superViewRect)
        setCollectionView()
    }
    
    func setBackgroundView() {
        let screenSize = UIScreen.main.bounds.size
        
        let closeBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        closeBackgroundView.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        closeBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeExtensionView)))
        self.addSubview(closeBackgroundView)
    }
    
    func setSuperView(_ rect: CGRect) {
        setSideCorner(target: superView, side: "all", radius: superView.bounds.width / 8)
        superView.backgroundColor = UIColor.init(named: "Color2")
        self.addSubview(superView)
    }
    
    func setCloseButton(_ midSideBtnView: UIView) {
        let width = midSideBtnView.frame.width
        let x = currentSide == .left ? 7 : superView.frame.width - width - 7
        let imageConfig = UIImage.SymbolConfiguration(weight: .bold)
        
        closeButton = UIButton(frame: CGRect(
            x: x, y: 2.5, width: width, height: width
        ))
        closeButton.setImage(UIImage.init(systemName: "xmark", withConfiguration: imageConfig), for: .normal)
        closeButton.addTarget(self, action: #selector(removeExtensionView), for: .touchDown)
        closeButton.backgroundColor = UIColor.init(named: "Color1")
        closeButton.tintColor = UIColor.init(named: "Icon")
        setSideCorner(target: closeButton, side: "all", radius: closeButton.frame.height / 2)
        superView.addSubview(closeButton)
    }
    
    func setMainButton(_ midSideBtnView: UIView) {
        let width = midSideBtnView.frame.width
        let height = midSideBtnView.frame.height
        let x = currentSide == .left ? 7 : superView.frame.width - width - 7
        let buttonView = UIView(frame: CGRect(
            x: x, y: width + 4, width: width, height: height - width - 2
        ))
        buttonView.backgroundColor = UIColor.init(named: "Color1")
        setSideCorner(target: buttonView, side: "all", radius: midSideBtnView.bounds.width / 4)
        
        if let iconImage = UIImage.init(named: CoreData.shared.selectedSubTool) {
            buttonIcon = UIImageView.init(image: iconImage)
        }
        buttonIcon.frame = CGRect(
            x: 7,
            y: (buttonView.frame.height - (buttonView.frame.width - 14)) / 2,
            width: buttonView.frame.width - 14,
            height: buttonView.frame.width - 14
        )
        buttonView.addSubview(buttonIcon)
        superView.addSubview(buttonView)
    }
    
    func setCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.sectionInset.top = 5
        layout.sectionInset.bottom = 5
        
        let toolCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        superView.addSubview(toolCollectionView)
        toolCollectionView.register(MiddleExtensionCell.self, forCellWithReuseIdentifier: "middleExtensionCell")
        toolCollectionView.delegate = self
        toolCollectionView.dataSource = self
        toolCollectionView.showsVerticalScrollIndicator = false
         
        setSideCorner(target: toolCollectionView, side: "all", radius: toolCollectionView.frame.width / 4)
        toolCollectionView.translatesAutoresizingMaskIntoConstraints = false
        toolCollectionView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 5).isActive = true
        toolCollectionView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -5).isActive = true
        if (currentSide == .left) {
            toolCollectionView.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 5).isActive = true
            toolCollectionView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -5).isActive = true
        } else {
            toolCollectionView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 5).isActive = true
            toolCollectionView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -5).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func removeExtensionView() {
        self.removeFromSuperview()
    }
    
    func setSuperViewFrame(_ pos: CGPoint) {
        superView.frame = CGRect(x: pos.x,
                                 y: pos.y,
                                 width: superView.frame.width,
                                 height: superView.frame.height
        )
        superView.transform = CGAffineTransform(rotationAngle: .pi/2)
    }
}


extension MiddleExtensionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreData.shared.subToolList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "middleExtensionCell", for: indexPath) as? MiddleExtensionCell else { return UICollectionViewCell() }
        cell.backgroundColor = UIColor.init(named: "Color1")
        setSideCorner(target: cell, side: "all", radius: cell.frame.width / 4)
        
        cell.toolName = CoreData.shared.subToolList[indexPath.row]
        let image = UIImage.init(named: cell.toolName)
        let cellSubView = cell.subviews
        
        if (cellSubView.count == 0) {
            let toolImage = UIImageView.init(image: image)
            toolImage.frame = CGRect(
                x: 5, y: 5,
                width: collectionView.frame.width - 20,
                height: collectionView.frame.width - 20
            )
            cell.addSubview(toolImage)
        } else {
            (cellSubView[0] as! UIImageView).image = image
        }
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
        let cellToolName = collectionView.cellForItem(at: indexPath) as! MiddleExtensionCell
        CoreData.shared.changeSubTool(tool: cellToolName.toolName)
        buttonIcon.image = UIImage(named: cellToolName.toolName)
        setButtonImage()
        removeExtensionView()
    }
}

class MiddleExtensionCell: UICollectionViewCell {
    var toolName: String = ""
}
