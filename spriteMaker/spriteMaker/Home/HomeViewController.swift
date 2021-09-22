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
    var selectedMenuIndex: Int!
    var isFirstLoad: Bool!
    var toastLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        homeMenuPanelViewController = segue.destination as? HomeMenuPanelViewController
        homeMenuPanelViewController?.superViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSideCorner(target: backgroundView, side: "all", radius: backgroundView.bounds.width / 20)
        setSideCorner(target: mainView, side: "all", radius: mainView.bounds.width / 20)
        setSideCorner(target: selectedMenubar, side: "all", radius: selectedMenubar.bounds.width / 8)
        setViewShadow(target: selectedMenubar, radius: 5, opacity: 0.7)
        setViewShadow(target: mainView, radius: 10, opacity: 0.3)
        selectedMenuIndex = 1
        isFirstLoad = true
    }
    
    override func viewDidLayoutSubviews() {
        // gallery가 첫 화면이 되도록 설정
        if (isFirstLoad) {
            moveMenuToggle()
            self.homeMenuPanelViewController.homeMenuPanelCV.contentOffset.x = self.homeMenuPanelViewController.homeMenuPanelCV.bounds.width
            isFirstLoad = false
        }
    }
    
    func setLabelView(_ targetView: UIViewController) {
        toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2 - 100, width: 300, height: 200))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        //            toastLabel.font = font
        toastLabel.textAlignment = .center
        toastLabel.text = "로딩중"
        toastLabel.alpha = 0.8
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        targetView.view.addSubview(toastLabel)
    }
    
    func removeLabelView() {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 1,
                delay: 1,
                options: .curveEaseOut,
                animations: { self.toastLabel.alpha = 0.0 },
                completion: {(isCompleted) in self.toastLabel.removeFromSuperview() }
            )
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setLabelView(self.superViewController)
        
        DispatchQueue.main.async {
            self.superViewController.mainViewController.drawingCollectionViewCell.updateCanvasData()
            self.superViewController.mainViewController.testingCollectionViewCell.updateTestData()
            self.removeLabelView()
        }
    }
    
    @IBAction func tappedCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchMenuButton(_ sender: UIButton) {
        let menuPanelWidth = self.homeMenuPanelViewController.homeMenuPanelCV.bounds.width
        self.selectedMenuIndex = self.menubarStackView.subviews.firstIndex(of: sender)
        self.homeMenuPanelViewController.homeMenuPanelCV.setContentOffset(
            CGPoint(x: menuPanelWidth * CGFloat(self.selectedMenuIndex), y: 0), animated: true
        )
        moveMenuToggle()
    }
    
    func moveMenuToggle() {
        self.menubarConstraint.constant = (self.button.bounds.width + 10) * CGFloat(self.selectedMenuIndex - 1)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}



