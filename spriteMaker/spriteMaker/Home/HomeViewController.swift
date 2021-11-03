//
//  HomeViewController.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/08/05.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var menubarStackView: UIStackView!
    @IBOutlet weak var selectedMenubar: UIView!
    @IBOutlet weak var menubarConstraint: NSLayoutConstraint!
    @IBOutlet weak var button: UIButton!
    
    weak var superViewController: ViewController!
    weak var homeMenuPanelViewController: HomeMenuPanelViewController!
    var selectedTabIndex: Int!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        homeMenuPanelViewController = segue.destination as? HomeMenuPanelViewController
        homeMenuPanelViewController!.homeViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 20)
        setSideCorner(target: mainView, side: "all", radius: mainView.bounds.width / 20)
        setSideCorner(target: selectedMenubar, side: "all", radius: selectedMenubar.bounds.height / 2)
        setViewShadow(target: selectedMenubar, radius: 5, opacity: 0.7)
        setViewShadow(target: mainView, radius: 10, opacity: 0.3)
        selectedTabIndex = 0
        superViewController.selectedToggle = 0
        superViewController.setTogglePosition()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if (superViewController.coreData.hasIndexChanged) {
            updateData()
        }
    }
    
    func updateData() {
        self.superViewController.mainViewController.setLabelView(self.superViewController)
        DispatchQueue.main.async { [self] in
            print(superViewController.selectedToggle)
            superViewController.mainViewController.drawingCollectionViewCell.updateCanvasData()
            superViewController.mainViewController.drawingCollectionViewCell.removeLoadingImageView()
//            if (superViewController.selectedToggle == 0) {
//            } else if (superViewController.selectedToggle == 1) {
//                superViewController.mainViewController.testingCollectionViewCell.updateTestData()
//                superViewController.mainViewController.removeLabelView()
//            }
            superViewController.mainViewController.drawingCollectionViewCell.previewImageToolBar.setOffsetForSelectedFrame()
            superViewController.mainViewController.drawingCollectionViewCell.previewImageToolBar.setOffsetForSelectedLayer()
            superViewController.coreData.hasIndexChanged = false
        }
    }
    
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchMenuButton(_ sender: UIButton) {
        let menuPanelWidth = self.homeMenuPanelViewController.homeMenuPanelCV.bounds.width
        self.selectedTabIndex = self.menubarStackView.subviews.firstIndex(of: sender)
        self.homeMenuPanelViewController.homeMenuPanelCV.setContentOffset(
            CGPoint(x: menuPanelWidth * CGFloat(self.selectedTabIndex), y: 0), animated: true
        )
        moveMenuToggle()
    }
    
    func moveMenuToggle() {
        self.menubarConstraint.constant = (self.button.bounds.width + 10) * CGFloat(self.selectedTabIndex)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}



