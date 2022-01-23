//
//  GalleryViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/11/05.
//

import UIKit

struct MaxNumOfRectSideLine {
    var row: Int
    var column: Int
}

class GalleryViewController: UIViewController {
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var assetCollectionView: UICollectionView!
    
    var timeMachineVM = TimeMachineViewModel()
    var exportViewController: ExportViewController!
    
    let screenWidth = UIScreen.main.bounds.width - 10
    var pickerComponents = MaxNumOfRectSideLine(row: 1, column: 1)
    var selectedIndex = 0
    var keyboardTextField: KeyboardTextField!
    let selectedTextPointer = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    
    deinit {
        selectedTextPointer.deinitialize(count: 1)
        selectedTextPointer.deallocate()
    }
    
    override func awakeFromNib() {
        self.keyboardTextField = KeyboardTextField(targetView: self) { [self] in
            let index = selectedTextPointer.pointee
            let title = CoreData.shared.getAsset(index: index)?.title
            return title!
        } saveText: { [self] text in
            CoreData.shared.updateTitle(title: text, index: selectedTextPointer.pointee)
            assetCollectionView.reloadData()
        }
        self.view.addSubview(keyboardTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        assetCollectionView.reloadData()
        keyboardTextField.addNotiObserver()
        selectedIndex = CoreData.shared.selectedAssetIndex
    }
    
    override func viewDidLoad() {
        // 순서 변경을 위한 제스쳐
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        assetCollectionView.addGestureRecognizer(gesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        keyboardTextField.removeNotiObserver()
        if (selectedIndex != CoreData.shared.selectedAssetIndex) {
            CoreData.shared.changeSelectedAssetIndex(index: selectedIndex)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "export":
            exportViewController = segue.destination as? ExportViewController
            exportViewController.superViewController = self
        default:
            return
        }
    }
    
    func reloadAssetCollectionView() {
        DispatchQueue.main.async { [self] in
            assetCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            assetCollectionView.reloadData()
        }
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
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
}

// stackView button events
extension GalleryViewController {
    @IBAction func tappedAddBtn(_ sender: Any = 0) {
        let alert = UIAlertController(title: "새 아이템", message: "새로운 아이템을 만드시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self] UIAlertAction in
            CoreData.shared.createAsset(title: "untitled", data: "", thumbnail: UIImage(named: "empty")!)
            CoreData.shared.changeSelectedAssetIndex(index: CoreData.shared.numsOfAsset - 1)
            selectedIndex = CoreData.shared.numsOfAsset - 1
            assetCollectionView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
            assetCollectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedCopyBtn(_ sender: Any) {
        let alert = UIAlertController(title: "복사", message: "선택된 아이템을 복사하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self] UIAlertAction in
            CoreData.shared.copySelectedAsset()
            CoreData.shared.changeSelectedAssetIndex(index: CoreData.shared.numsOfAsset - 1)
            selectedIndex = CoreData.shared.numsOfAsset - 1
            assetCollectionView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
            assetCollectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedImportBtn(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @IBAction func tappedExportBtn(_ sender: Any) {
        let alert = UIAlertController(title: "출력", message: "선택된 아이템을 출력하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { [self] UIAlertAction in
            present(exportViewController, animated: false, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedRemoveBtn(_ sender: Any) {
        let alert = UIAlertController(title: "제거", message: "선택된 아이템을 제거하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { [self] UIAlertAction in
            let index = CoreData.shared.selectedAssetIndex
            
            CoreData.shared.deleteData(entity: .asset, index: index)
            selectedIndex = CoreData.shared.selectedAssetIndex
            if (CoreData.shared.numsOfAsset == 0) {
                CoreData.shared.initAsset()
                selectedIndex = 0
            }
            assetCollectionView.reloadData()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreData.shared.numsOfAsset
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpriteCollectionViewCell", for: indexPath) as? SpriteCollectionViewCell else { return UICollectionViewCell() }
        cell.index = CoreData.shared.numsOfAsset - indexPath.row - 1
        guard let data = CoreData.shared.getAsset(index: cell.index) else { return cell }
        setSelectedViewOutline(cell, selectedIndex == cell.index)
        setSideCorner(target: cell, side: "all", radius: cell.frame.width / 15)
        cell.layer.masksToBounds = false
        cell.coreData = CoreData.shared
        cell.titleTextField.text = data.title
        cell.selectedText = selectedTextPointer
        if let imageData = data.thumbnail {
            cell.spriteImage.image = UIImage(data: imageData)
        }
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = CoreData.shared.numsOfAsset - indexPath.row - 1
        
        if (selectedIndex == index) {
            print("change tab number")
        } else {
            CoreData.shared.changeSelectedAssetIndex(index: index)
            selectedIndex = index
            collectionView.reloadData()
        }
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
    
    // Re-order
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let numsOfAsset = CoreData.shared.numsOfAsset - 1
        let src = numsOfAsset - sourceIndexPath.row
        let dst = numsOfAsset - destinationIndexPath.row
        
        CoreData.shared.reorderFunc(itemAt: src, to: dst) { a, b in
            CoreData.shared.swapAsset(a, b)
        }
        
        CoreData.shared.selectedAssetIndex.setSelectedIndex(src, dst)
        CoreData.shared.saveData(entity: .asset)
        CoreData.shared.hasIndexChanged = true
        selectedIndex.setSelectedIndex(src, dst)
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
                    let data = timeMachineVM.compressData(frames: frames, selectedFrame: 0, selectedLayer: 0)
                    CoreData.shared.createAsset(title: "untitled", data: data, thumbnail: frames[0].renderedImage)
                    CoreData.shared.changeSelectedAssetIndex(index: CoreData.shared.numsOfAsset - 1)
                    selectedIndex = CoreData.shared.numsOfAsset - 1
                    reloadAssetCollectionView()
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
                        drawGridPixels(context.cgContext, grid: gridData, pixelWidth: Double(layerImagePixelWidth))
                    }
                    let layer = Layer(gridData: matrixToString(grid: gridData), renderedImage: renderedImage, ishidden: false)
                    let frame = Frame(layers: [layer], renderedImage: renderedImage, category: "Default")
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
    var index: Int!
    var selectedText: UnsafeMutablePointer<Int>!
    var coreData: CoreData!
    
    override func awakeFromNib() {
        setSideCorner(target: spriteImage, side: "all", radius: spriteImage.bounds.width / 15)
        setViewShadow(target: self, radius: 5, opacity: 0.2)
        setViewShadow(target: titleTextField, radius: 7, opacity: 0.7)
        titleTextField.layer.shadowColor = UIColor.white.cgColor
    }
}

extension SpriteCollectionViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedText.initialize(to: index)
    }
}
