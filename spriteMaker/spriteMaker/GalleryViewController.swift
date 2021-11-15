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
    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    var coreData = CoreData()
    var timeMachineVM = TimeMachineViewModel()
    var exportViewController: ExportViewController!
    
    var selectedIndex = 0
    let screenWidth = UIScreen.main.bounds.width - 10
    var pickerComponents = MaxNumOfRectSideLine(row: 1, column: 1)
    
    override func viewWillAppear(_ animated: Bool) {
        selectedIndex = coreData.selectedIndex
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (selectedIndex != coreData.selectedIndex) {
            coreData.changeSelectedIndex(index: selectedIndex)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let keyboardTextField = KeyboardTextField(targetView: self) {
            return self.coreData.selectedData.title!
        } saveText: { text in
            self.coreData.updateTitle(title: text, index: self.coreData.selectedIndex)
            self.itemCollectionView.reloadData()
        }
        self.view.addSubview(keyboardTextField)
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
    
    func reloadItemCollectionView() {
        DispatchQueue.main.async { [self] in
            itemCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            itemCollectionView.reloadData()
        }
    }
}

// stackView button events
extension GalleryViewController {
    @IBAction func tappedAddBtn(_ sender: Any = 0) {
        let alert = UIAlertController(title: "새 아이템", message: "새로운 아이템을 만드시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self] UIAlertAction in
            coreData.createData(title: "untitled", data: "", thumbnail: UIImage(named: "empty")!)
            coreData.setSelectedIndexToFirst()
            itemCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            itemCollectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedCopyBtn(_ sender: Any) {
        let alert = UIAlertController(title: "복사", message: "선택된 아이템을 복사하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self] UIAlertAction in
            coreData.copySelectedData()
            coreData.setSelectedIndexToFirst()
            itemCollectionView.reloadData()
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
            coreData.deleteData(index: coreData.selectedIndex)
            itemCollectionView.reloadData()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coreData.numsOfData
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpriteCollectionViewCell", for: indexPath) as? SpriteCollectionViewCell else { return UICollectionViewCell() }
        cell.index = coreData.numsOfData - indexPath.row - 1
        guard let data = coreData.getData(index: cell.index) else { return cell }
        setSelectedViewOutline(cell.spriteImage, selectedIndex == cell.index)
        
        cell.coreData = coreData
        cell.titleTextField.text = data.title
        if let imageData = data.thumbnail {
            cell.spriteImage.image = UIImage(data: imageData)
        }
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = coreData.numsOfData - indexPath.row - 1
        
        if (selectedIndex == index) {
            print("change tab number")
        } else {
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
                loadingAlert = ProgressBarLoadingAlert(targetVC: self, maxCount: horValue * verValue)
                loadingAlert.startLoading()
                
                DispatchQueue.global().async {
                    let frames = transImageToFrames(pickedImage, 16, 20, horValue, verValue)
                    let data = timeMachineVM.compressData(frames: frames, selectedFrame: 0, selectedLayer: 0)
                    coreData.createData(title: "untitled", data: data, thumbnail: frames[0].renderedImage)
                    coreData.setSelectedIndexToFirst()
                    reloadItemCollectionView()
                    loadingAlert.stopLoading()
                }
            }
        }
        
        func transImageToFrames(_ image: UIImage, _ numsOfPixel: Int, _ pixelWidth: Int, _ numsOfRowItem: Int, _ numsOfColumnItem: Int) -> [Frame] {
            let grid = Grid()
            var frames: [Frame] = []
            let layerImagePixelWidth = 20
            let layerImageSize = CGSize(width: numsOfPixel * layerImagePixelWidth, height: numsOfPixel * layerImagePixelWidth)
            let layerImageRenderer = UIGraphicsImageRenderer(size: layerImageSize)
                    
            for y in 0..<numsOfColumnItem {
                for x in 0..<numsOfRowItem {
                    grid.initGrid()

                    for i in 0..<numsOfPixel {
                        for j in 0..<numsOfPixel {
                            guard let color = image.getPixelColor(pos: CGPoint(x: i + (x * numsOfPixel), y: j + (y * numsOfPixel))) else { return [] }
                            if (color.cgColor.alpha != 0) {
                                grid.addLocation(hex: color.hexa!, x: i, y: j)
                            }
                        }
                    }

                    let renderedImage = layerImageRenderer.image { context in
                        drawSeletedPixels(context.cgContext, grid: grid.gridLocations, pixelWidth: Double(layerImagePixelWidth))
                    }
                    let layer = Layer(gridData: matrixToString(grid: grid.gridLocations), renderedImage: renderedImage, ishidden: false)
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
    var coreData: CoreData!
    
    override func awakeFromNib() {
        setSideCorner(target: spriteImage, side: "all", radius: spriteImage.bounds.width / 15)
        setViewShadow(target: self, radius: 5, opacity: 0.5)
        titleTextField.layer.borderColor = UIColor.black.cgColor
    }
}

extension SpriteCollectionViewCell: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        coreData.changeSelectedIndex(index: index)
    }
}
