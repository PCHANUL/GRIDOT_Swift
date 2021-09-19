//
//  MainViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/09/19.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var MainCollectionView: UICollectionView!
    var superViewController: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrawingCollectionViewCell", for: indexPath) as! DrawingCollectionViewCell
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestingCollectionViewCell", for: indexPath) as! TestingCollectionViewCell
            return cell
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let view = superViewController.mainContainerView!
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
}

class DrawingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var panelContainerView: UIView!
    @IBOutlet weak var scrollNav: UIView!
    @IBOutlet weak var scrollNavBar: UIView!
    @IBOutlet weak var panelWidthContraint: NSLayoutConstraint!
    
    @IBOutlet weak var sideButtonView: UIView!
    @IBOutlet weak var topSideBtn: UIView!
    @IBOutlet weak var midSideBtn: UIView!
    @IBOutlet weak var botSideBtn: UIView!
    @IBOutlet weak var topSideBtnImage: UIImageView!
    @IBOutlet weak var midSideBtnImage: UIImageView!
    @IBOutlet weak var botSideBtnImage: UIImageView!
    
    @IBOutlet weak var sideButtonViewGroup: UIView!
    var canvas: Canvas!
    
    var panelConstraint: NSLayoutConstraint!
    var sideButtonGroupConstraint: NSLayoutConstraint!
    var sideButtonToCanvasConstraint: NSLayoutConstraint!
    var sideButtonToGroupConstraint: NSLayoutConstraint!
    var currentSide: String!
    var prevToolIndex: Int!
    
    var scrollPosition: CGFloat!
    var scrollPanelNum: CGFloat!
    var scrollBeganPos: CGFloat!
    var scrollMovedPos: CGFloat!
    
    override func awakeFromNib() {
        currentSide = "left"
        setSideCorner(target: sideButtonView, side: "all", radius: sideButtonView.bounds.width / 4)
        setSideCorner(target: topSideBtn, side: "all", radius: topSideBtn.bounds.width / 4)
        setSideCorner(target: midSideBtn, side: "all", radius: midSideBtn.bounds.width / 4)
        setSideCorner(target: botSideBtn, side: "all", radius: botSideBtn.bounds.width / 4)
        
        scrollPosition = 0
        scrollPanelNum = 0
        scrollBeganPos = 0
        scrollMovedPos = 0
    }
    
    override func layoutSubviews() {
        scrollNav.isHidden = (panelContainerView.frame.height > (panelContainerView.frame.width * 0.9))
        let heightRatio = panelContainerView.frame.height / (panelContainerView.frame.width + 20)
        let height = scrollNav.bounds.height * heightRatio
        let heightConstraint = scrollNavBar.heightAnchor.constraint(equalToConstant: height)
        
        heightConstraint.priority = UILayoutPriority(500)
        heightConstraint.isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toolbox":
            prepareToolBox(segue)
        default:
            return
        }
    }
    
    func prepareToolBox(_ segue: UIStoryboardSegue) {
        let destinationVC = segue.destination as? PanelContainerViewController
        panelContainerViewController = destinationVC
        
        let numsOfPixels = 16
        let lengthOfOneSide = viewController.bounds.width * 0.9
        canvas = Canvas(lengthOfOneSide, numsOfPixels, panelContainerViewController)
        self.timeMachineVM = TimeMachineViewModel(canvas, undoBtn, redoBtn)
        canvas.timeMachineVM = self.timeMachineVM
        canvas.frame = CGRect(x: 0, y: 0, width: lengthOfOneSide, height: lengthOfOneSide)
        canvas.backgroundColor = .darkGray
        canvasView.addSubview(canvas)
        
        panelContainerViewController.canvas = canvas
        panelContainerViewController.superViewController = self
    }
    
}

class TestingCollectionViewCell: UICollectionViewCell {
    
}
