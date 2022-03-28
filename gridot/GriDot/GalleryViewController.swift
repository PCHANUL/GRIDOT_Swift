//
//  GalleryViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/11/05.
//

import UIKit
import RxSwift
import RxCocoa

struct MaxNumOfRectSideLine {
    var row: Int
    var column: Int
}

class UIViewChangesHeight: UIView {
    var heightConstraint: NSLayoutConstraint!
    var maxHeight: CGFloat!
    var minHeight: CGFloat = 100
    var startPoint: CGFloat!
    var endPoint: CGFloat!
    var prevPoint: CGFloat!
    
    func initHeightConstrant(startPoint: CGFloat, endPoint: CGFloat, minHeight: CGFloat, maxHeight: CGFloat) {
        heightConstraint = self.heightAnchor.constraint(equalToConstant: frame.height)
        heightConstraint.priority = UILayoutPriority(1000)
        heightConstraint.isActive = true
        prevPoint = startPoint
        self.startPoint = 0
        self.endPoint = endPoint
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    func setViewHeight(_ point: CGFloat) {
        if (heightConstraint == nil) { return }
        if (heightConstraint.constant == maxHeight && point < startPoint) { return }
        if (heightConstraint.constant == minHeight && point > endPoint) { return }
        
        let acc = prevPoint - point
        let newHeight = self.frame.height + acc
        
        if (newHeight > minHeight && newHeight < maxHeight) {
            heightConstraint.constant = newHeight
        } else if (newHeight < minHeight) {
            heightConstraint.constant = minHeight
        } else if (newHeight > maxHeight) {
            heightConstraint.constant = maxHeight
        }
        prevPoint = point
    }
}

class GalleryViewController: UIViewController {
    @IBOutlet weak var assetCollectionView: UICollectionView!
    @IBOutlet weak var profileView: UIViewChangesHeight!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var profileEffect: UIVisualEffectView!
    
    var timeMachineVM = TimeMachineViewModel()
    var exportViewController: ExportViewController!
    
    let screenWidth = UIScreen.main.bounds.width - 10
    var pickerComponents = MaxNumOfRectSideLine(row: 1, column: 1)
    var keyboardTextField: KeyboardTextField!
    let selectedTextPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    var selectedIndex = 0
    let disposeBag = DisposeBag()
    var fireStorage: FireStorage?
    
    deinit {
        selectedTextPointer.deinitialize(count: 1)
        selectedTextPointer.deallocate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        assetCollectionView.reloadData()
        selectedIndex = CoreData.shared.selectedAssetIndex
    }
    
    override func viewDidAppear(_ animated: Bool) {
        assetCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    override func viewDidLoad() {
        setSideCorner(target: thumbnailView, side: "all", radius: thumbnailView.frame.width / 2)
        setViewShadow(target: profileEffect, radius: 10, opacity: 0.1)
        
        // 유저 이름 변경
        UserInfo.shared.userNameObservable
            .subscribe { value in
                if let value = value.element {
                    self.userIdLabel.text = value
                }
            }.disposed(by: disposeBag)
        
        // 유저 썸네일 변경
        UserInfo.shared.userImageObservable
            .subscribe { value in
                if let value = value.element {
                    self.profileImageView.image = value
                } else {
                    let defaultImage = UIImage(named: "person.fill")
                    self.profileImageView.image = defaultImage?.withTintColor(.darkGray)
                }
            }.disposed(by: disposeBag)
        
        // CoreData 에셋 선택 변경
        CoreData.shared.assetIndexObservable
            .subscribe { index in
                if let idx = index.element {
                    self.selectedIndex = idx
                    self.assetCollectionView.reloadData()
                }
            }.disposed(by: disposeBag)
        
        // assetCV 순서 변경을 위해 길게 누름
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        assetCollectionView.addGestureRecognizer(gesture)
        
        assetCollectionView.rx
            .contentOffset.map { $0.y }
            .subscribe { [weak self] point in
                DispatchQueue.main.async {
                    setSideCorner(target: (self?.thumbnailView)!, side: "all", radius: (self?.thumbnailView.frame.width)! / 2)
                }
                
                guard let contentHeight = self?.assetCollectionView.contentSize else { return }
                guard let frameHeight = self?.assetCollectionView.frame.height else { return }
                
                if (contentHeight.height == 0) { return }
                if (self?.profileView.heightConstraint == nil) {
                    self?.profileView.initHeightConstrant(
                        startPoint: 50,
                        endPoint: contentHeight.height - frameHeight,
                        minHeight: 50,
                        maxHeight: 150
                    )
                }
                
                if let point = point.element {
                    self?.profileView.setViewHeight(point)
                    
                    let minHeight = (self?.profileView.minHeight)!
                    if (minHeight + 30 > (self?.profileView.heightConstraint.constant)!) {
                        self?.userIdLabel.isHidden = true
                    } else {
                        self?.userIdLabel.isHidden = false
                    }
                }
            }.disposed(by: disposeBag)
    }

    func reloadAssetCollectionView() {
        DispatchQueue.main.async { [self] in
            assetCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            assetCollectionView.reloadData()
        }
    }
    
    @objc func handleLongPressGesture(_ gesture: UIGestureRecognizer) {
        let collectionView = assetCollectionView
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else { return }
            collectionView?.beginInteractiveMovementForItem(at: targetIndexPath)
            collectionView?.cellForItem(at: targetIndexPath)?.alpha = 0.5
        case .changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView?.endInteractiveMovement()
            collectionView?.reloadData()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
    
    func getAssetItemIndex(_ index: Int) -> Int {
        return (CoreData.shared.numsOfAsset - index - 1)
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreData.shared.numsOfAsset
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AssetHeaderCell", for: indexPath) as? AssetHeaderCell else { return UICollectionReusableView() }
        header.superViewController = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return setSpriteCell(collectionView, indexPath)
    }
    
    func setSpriteCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpriteCollectionViewCell", for: indexPath) as? SpriteCollectionViewCell else { return UICollectionViewCell() }
        cell.index = getAssetItemIndex(indexPath.row)
        guard let data = CoreData.shared.getAsset(index: cell.index) else { return cell }
        setSideCorner(target: cell, side: "all", radius: cell.frame.width / 15)
        cell.layer.masksToBounds = false
        cell.coreData = CoreData.shared
        cell.titleTextField.text = data.title
        cell.selectedText = selectedTextPointer
        if let imageData = data.thumbnail {
            cell.spriteImage.image = UIImage(data: imageData)
        }
        cell.superViewController = self
        return cell
    }
}

class AssetHeaderCell: UICollectionReusableView {
    var superViewController: GalleryViewController!
    
    @IBAction func tappedAddAsset(_ sender: Any) {
        let alert = UIAlertController(title: "새 아이템", message: "새로운 아이템을 만드시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self] UIAlertAction in
            CoreData.shared.createEmptyAsset()
            CoreData.shared.selectedAssetIndex = CoreData.shared.numsOfAsset - 1
            self.superViewController.assetCollectionView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
            self.superViewController.assetCollectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        superViewController.present(alert, animated: true, completion: nil)
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = getAssetItemIndex(indexPath.row)
        
        CoreData.shared.selectedAssetIndex = index
        self.tabBarController?.selectedIndex = 1
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        width = (self.view.frame.width / 2) - 30
        height = (self.view.frame.width / 2)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: self.view.frame.width, height: 200)
    }

    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let numsOfAsset = CoreData.shared.numsOfAsset - 1
        let src = numsOfAsset - sourceIndexPath.row
        let dst = numsOfAsset - destinationIndexPath.row
        let selected = getSelectedIndexInReorderedContents(CoreData.shared.selectedAssetIndex, src, dst)
        
        CoreData.shared.reorderFunc(itemAt: src, to: dst) { a, b in
            CoreData.shared.swapAsset(a, b)
        }
        CoreData.shared.saveData(entity: .asset)
        CoreData.shared.selectedAssetIndex = selected
        selectedIndex = CoreData.shared.selectedAssetIndex
        assetCollectionView.reloadData()
    }
}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            popupErrorMessage(
                targetVC: picker,
                title: "이미지 오류",
                message: "잘못된 이미지를 선택하였습니다.\n다른 이미지를 선택하여주세요."
            )
            return
        }
        
        pickerComponents.row = Int(pickedImage.size.width) / 16
        pickerComponents.column = Int(pickedImage.size.height) / 16
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 100))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        var loadingAlert: ProgressBarLoadingAlert!
        
        presentPickerAlertController(picker, pickerView, title: "개수 선택", message: "변환하려는 이미지의 가로와 세로의 이미지 개수를 선택하세요.") { [self] (vc) in
            let horValue = pickerView.selectedRow(inComponent: 0)
            let verValue = pickerView.selectedRow(inComponent: 1)
            if (horValue == 0 || verValue == 0) {
                picker.dismiss(animated: true, completion: nil)
                popupErrorMessage(
                    targetVC: self,
                    title: "선택 오류",
                    message: "개수를 잘못 선택하였습니다."
                )
                return
            }
            
            picker.dismiss(animated: true) { [self] in
                let isStopped = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
                isStopped.initialize(to: false)
                
                loadingAlert = ProgressBarLoadingAlert(targetVC: self, maxCount: horValue * verValue) {
                    isStopped.initialize(to: true)
                }
                loadingAlert.startLoading()

                func cleanupFunc() {
                    isStopped.deinitialize(count: 1)
                    isStopped.deallocate()
                    loadingAlert.stopLoading()
                }
                
                DispatchQueue.global().async {
                    let frames = transImageToFrames(pickedImage, 16, 20, horValue, verValue, isStopped)
                    if (frames.count == 0) {
                        cleanupFunc()
                        return
                    }
                    let data = compressDataInt32(frames: frames, selectedFrame: 0, selectedLayer: 0)
                    CoreData.shared.createAsset(title: "untitled", data: "", gridData: data, thumbnail: frames[0].renderedImage)
                    CoreData.shared.selectedAssetIndex = CoreData.shared.numsOfAsset - 1
                    self.selectedIndex = CoreData.shared.numsOfAsset - 1
                    self.reloadAssetCollectionView()
                    cleanupFunc()
                }
            }
        }
        
        func transImageToFrames(_ image: UIImage, _ numsOfPixel: Int, _ pixelWidth: Int, _ numsOfRowItem: Int, _ numsOfColumnItem: Int, _ isStopped: UnsafeMutablePointer<Bool>) -> [Frame] {
            var frames: [Frame] = []
            let layerImagePixelWidth = 20
            let layerImageSize = CGSize(width: numsOfPixel * layerImagePixelWidth, height: numsOfPixel * layerImagePixelWidth)
            let layerImageRenderer = UIGraphicsImageRenderer(size: layerImageSize)
                    
            for y in 0..<numsOfColumnItem {
                for x in 0..<numsOfRowItem {
                    if (isStopped.pointee) { return [] }
                    let gridData = image.transImageToGrid(start: CGPoint(x: x, y: y))
                    let renderedImage = layerImageRenderer.image { context in
                        drawGridPixelsInt32(context.cgContext, gridData, Double(layerImagePixelWidth))
                    }
                    let layer = Layer(data: gridData, renderedImage: renderedImage)
                    let frame = Frame(layers: [layer], renderedImage: renderedImage)
                    frames.append(frame)
                    loadingAlert.addCount()
                }
            }
            return frames
        }
    }
}

extension GalleryViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return pickerComponents.row
        case 1:
            return pickerComponents.column
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth / 3, height: 100))
        if (row == 0) {
            label.text = component == 0 ? "가로 개수" : "세로 개수"
        } else {
            label.text = "\(row)"
        }
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }
}

class SpriteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var spriteImage: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var buttonGroupView: UIView!
    @IBOutlet weak var optionButton: UIButton!
    
    weak var superViewController: GalleryViewController!
    var index: Int!
    var selectedText: UnsafeMutablePointer<Int>!
    var coreData: CoreData!
    var buttonGroupTimer: Timer!
    
    override func awakeFromNib() {
        setSideCorner(target: spriteImage, side: "all", radius: spriteImage.bounds.width / 15)
        setSideCorner(target: buttonGroupView, side: "all", radius: buttonGroupView.bounds.width / 15)
        setViewShadow(target: self, radius: 5, opacity: 0.1)
        setViewShadow(target: titleTextField, radius: 7, opacity: 0.7)
        optionButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
        titleTextField.layer.shadowColor = UIColor.white.cgColor
    }
    
    @IBAction func tappedOptionButton(_ sender: UIButton) {
        showButtonGroupView()
    }
    
    func showButtonGroupView() {
        buttonGroupView.isHidden = false
        UIView.transition(with: buttonGroupView, duration: 0.3, options: .showHideTransitionViews, animations: nil, completion: nil)
        UIView.transition(with: self, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        
        buttonGroupTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false)
        { [weak self] (Timer) in
            self?.buttonGroupView.isHidden = true
            UIView.transition(with: self!.buttonGroupView, duration: 0.3, options: .showHideTransitionViews, animations: nil, completion: nil)
            UIView.transition(with: self!, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            Timer.invalidate()
        }
    }
    
    func hideButtonGroupView() {
        if (buttonGroupTimer != nil && buttonGroupTimer.isValid) {
            buttonGroupView.isHidden = true
            UIView.transition(with: buttonGroupView, duration: 0.3, options: .showHideTransitionViews, animations: nil, completion: nil)
            UIView.transition(with: self, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            buttonGroupTimer.invalidate()
        }
    }
    
    @IBAction func tappedCopyBtn(_ sender: Any) {
        self.hideButtonGroupView()
        let alert = UIAlertController(title: "복사", message: "선택된 아이템을 복사하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self] UIAlertAction in
            CoreData.shared.copySelectedAsset()
            CoreData.shared.selectedAssetIndex = CoreData.shared.numsOfAsset - 1
            superViewController.assetCollectionView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
            superViewController.assetCollectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        superViewController.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedExportBtn(_ sender: Any) {
        self.hideButtonGroupView()
        guard let exportVC = superViewController.storyboard?.instantiateViewController(withIdentifier: "ExportViewController") as? ExportViewController else { return }
        exportVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 10, height: 100)
        exportVC.superViewController = superViewController
        superViewController.present(exportVC, animated: true, completion: nil)
    }
    
    @IBAction func tappedRemoveBtn(_ sender: Any) {
        self.hideButtonGroupView()
        let alert = UIAlertController(title: "제거", message: "선택된 아이템을 제거하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { [self] UIAlertAction in
            let index = CoreData.shared.selectedAssetIndex
            
            CoreData.shared.deleteData(entity: .asset, index: index)
            superViewController.selectedIndex = CoreData.shared.selectedAssetIndex
            if (CoreData.shared.numsOfAsset == 0) {
                CoreData.shared.initAsset()
                superViewController.selectedIndex = 0
            }
            superViewController.assetCollectionView.reloadData()
        }))
        superViewController.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedEditBtn(_ sender: Any) {
        self.hideButtonGroupView()
        CoreData.shared.selectedAssetIndex = index
        
        guard let renamePopupVC = initRenamePopupCV(
            presentTarget: superViewController,
            currentText: CoreData.shared.getAsset(index: index)?.title,
            callback: changeAssetTitle
        ) else { return }
        
        let imageView = createAssetImageView()
        renamePopupVC.addSubviewToContentView(imageView)
    }
    
    func createAssetImageView() -> UIImageView {
        let sideLength: CGFloat = 100
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
        imageView.image = spriteImage.image
        imageView.backgroundColor = .white
        setSideCorner(target: imageView, side: "all", radius: sideLength / 15)
        setViewShadow(target: imageView, radius: 5, opacity: 0.2)
        return imageView
    }
    
    func changeAssetTitle(_ text: String) {
        CoreData.shared.updateAssetTitleSelected(title: text)
        self.superViewController.assetCollectionView.reloadData()
    }
}

extension SpriteCollectionViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        return
    }
}
