//
//  GalleryViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/11/05.
//

import UIKit

class GalleryViewController: UIViewController {
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    var coreData = CoreData()
    var timeMachineVM = TimeMachineViewModel()
    var exportViewController: ExportViewController!
    
    let screenWidth = UIScreen.main.bounds.width - 10
    var pickerComponents = [
        "가로 개수": 1,
        "세로 개수": 1
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        pickerComponents["가로 개수"] = Int(pickedImage.size.width) / 16
        pickerComponents["세로 개수"] = Int(pickedImage.size.height) / 16
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 100))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: 100)
        vc.view.addSubview(pickerView)
        
        let alert = UIAlertController(title: "개수 선택", message: "변환하려는 이미지의 가로와 세로의 이미지 개수를 선택하세요.", preferredStyle: .actionSheet)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self] (alertAction) in
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
                DispatchQueue.global().async {
                    let renderedImage = renderPickedImage(pickedImage)
                    let frames = transImageToFrames(renderedImage, 16, 20, horValue, verValue)
                    let data = timeMachineVM.compressData(frames: frames, selectedFrame: 0, selectedLayer: 0)
                    coreData.createData(title: "untitled", data: data, thumbnail: frames[0].renderedImage)
                    coreData.setSelectedIndexToFirst()
                    
                    DispatchQueue.main.async {
                        itemCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                        itemCollectionView.reloadData()
                    }
                }
            }
        }))
        picker.present(alert, animated: true, completion: nil)
    }
    
    func popupErrorMessage(targetVC: UIViewController, title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        targetVC.present(alert, animated: true, completion: nil)
    }
    
    func transImageToFrames(_ image: UIImage, _ numsOfPixel: Int, _ pixelWidth: Int, _ numsOfHorizontalItem: Int, _ numsOfVerticalItem: Int) -> [Frame] {
        var frames: [Frame] = []
        let imageRenderer = UIGraphicsImageRenderer(size: CGSize(width: numsOfPixel * pixelWidth, height: numsOfPixel * pixelWidth))
                
        let grid = Grid()
        for y in 0..<numsOfVerticalItem {
            for x in 0..<numsOfHorizontalItem {
                grid.initGrid()
                
                for i in 0..<numsOfPixel {
                    for j in 0..<numsOfPixel {
                        guard let color = image.getPixelColor(
                                pos: CGPoint(
                                    x: i + (x * numsOfPixel),
                                    y: j + (y * numsOfPixel)
                                )
                        ) else { return [] }
                        
                        if (color.cgColor.alpha != 0) {
                            grid.addLocation(hex: color.hexa!, x: i, y: j)
                        }
                    }
                }
                
                let renderedImage = imageRenderer.image { [self] context in
                    drawSeletedPixels(context.cgContext, grid: grid.gridLocations, pixelWidth: 20)
                }
                let layer = Layer(gridData: matrixToString(grid: grid.gridLocations), renderedImage: renderedImage, ishidden: false)
                let frame = Frame(layers: [layer], renderedImage: renderedImage, category: "Default")
                frames.append(frame)
            }
        }
        return frames
    }
    
    func renderPickedImage(_ pickedImage: UIImage) -> UIImage {
        let flipedImage = flipImageVertically(originalImage: pickedImage)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pickedImage.cgImage!.width / 2, height: pickedImage.cgImage!.height / 2))
        let renderedImage = renderer.image { context in
            context.cgContext.draw(
                flipedImage.cgImage!,
                in: CGRect(x: 0, y: 0, width: pickedImage.cgImage!.width / 2, height: pickedImage.cgImage!.height / 2))
        }
        return renderedImage
    }
    
    func drawSeletedPixels(_ context: CGContext, grid: [String : [Int : [Int]]], pixelWidth: Double) {
        context.setLineWidth(0.2)
        
        for color in grid.keys {
            guard let locations = grid[color] else { return }
            for x in locations.keys {
                guard let locationX = locations[x] else { return }
                for y in locationX {
                    context.setFillColor(color.uicolor!.cgColor)
                    context.setStrokeColor(color.uicolor!.cgColor)
                    let xlocation = Double(x) * pixelWidth
                    let ylocation = Double(y) * pixelWidth
                    let rectangle = CGRect(x: xlocation, y: ylocation, width: pixelWidth, height: pixelWidth)
                    context.addRect(rectangle)
                    context.drawPath(using: .fillStroke)
                }
            }
        }
        context.strokePath()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension GalleryViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Array(pickerComponents)[component].value
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth / 3, height: 100))
        if (row == 0) {
            label.text = Array(pickerComponents)[component].key
            label.textAlignment = .center
        } else {
            label.text = "\(row)"
            label.textAlignment = .right
        }
        label.sizeToFit()
        return label
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
        
        // set title
        cell.titleTextField.text = data.title
        
        // selectedData outline
        if (coreData.selectedIndex == cell.index) {
            cell.spriteImage.layer.borderWidth = 1
        } else {
            cell.spriteImage.layer.borderWidth = 0
        }
        cell.spriteImage.layer.borderColor = UIColor.white.cgColor
        if let imageData = data.thumbnail {
            cell.spriteImage.image = UIImage(data: imageData)
        }
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = coreData.numsOfData - indexPath.row - 1
        
        if (coreData.selectedIndex == index) {
            print("change tab number")
        } else {
            coreData.changeSelectedIndex(index: index)
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
