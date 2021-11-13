//
//  ViewMethods.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/05/29.
//

import UIKit

// view에 그림자 생성 (마스크 비활성)
func setViewShadow(target: UIView, radius: CGFloat, opacity: Float) {
    target.layer.masksToBounds = false
    target.layer.shadowColor = UIColor.black.cgColor
    target.layer.shadowOffset = CGSize(width: 0, height: 0)
    target.layer.shadowRadius = radius
    target.layer.shadowOpacity = opacity
}

func setViewShadowWithColor(target: UIView, radius: CGFloat, opacity: Float, color: UIColor) {
    target.layer.masksToBounds = false
    target.layer.shadowColor = color.cgColor
    target.layer.shadowOffset = CGSize(width: 0, height: 0)
    target.layer.shadowRadius = radius
    target.layer.shadowOpacity = opacity
}

func addInnerShadow(_ targetView: UIView, rect: CGRect, radius: CGFloat) {
    if (targetView.layer.sublayers != nil) { return }
    let innerShadow = CALayer()
    innerShadow.frame = rect
    
    let path = UIBezierPath(roundedRect: innerShadow.frame.insetBy(dx: -5, dy: -5), cornerRadius: radius)
    let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius: radius).reversing()
    
    path.append(cutout)
    innerShadow.shadowPath = path.cgPath
    innerShadow.masksToBounds = true
    innerShadow.shadowColor = UIColor.black.cgColor
    innerShadow.shadowOffset = CGSize(width: 0, height: 0)
    innerShadow.shadowOpacity = 0.2
    innerShadow.shadowRadius = 5
    innerShadow.cornerRadius = radius - 10
    targetView.layer.addSublayer(innerShadow)
}

func setSideCorner(target: UIView, side: String, radius: CGFloat) {
    target.clipsToBounds = true
    target.layer.cornerRadius = radius
    switch side {
    case "top":
        target.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    case "bottom":
        target.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    case "left":
        target.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    case "right":
        target.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    case "all":
        return
    default:
        return
    }
}

func setSelectedViewOutline(_ target: UIView, _ isSelected: Bool) {
    if (isSelected) {
        target.layer.borderWidth = 1
    } else {
        target.layer.borderWidth = 0
    }
    target.layer.borderColor = UIColor.white.cgColor
}

func presentPickerAlertController(_ presentTarget: UIViewController, _ pickerView: UIPickerView, title: String?, message: String?, complete: ((_ vc: UIViewController) -> Void)? = nil) {
    let vc = UIViewController()
    vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 10, height: 100)
    vc.view.addSubview(pickerView)
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    alert.setValue(vc, forKey: "contentViewController")
    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { UIAlertAction in
        if (complete != nil) { complete!(vc) }
    }))
    presentTarget.present(alert, animated: true, completion: nil)
}

func popupErrorMessage(targetVC: UIViewController, title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
    targetVC.present(alert, animated: true, completion: nil)
}

class LoadingAlert {
    weak var targetVC: UIViewController?
    var alert: UIAlertController
    
    init(targetVC: UIViewController) {
        self.targetVC = targetVC
        self.alert = UIAlertController(title: "Loading", message: "", preferredStyle: .alert)
    }
    
    func startLoading() {
        if (targetVC == nil) { return }
        targetVC!.present(alert, animated: true, completion: nil)
    }
    
    func stopLoading() {
        DispatchQueue.main.async { [self] in
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

class SpinnerLoadingAlert: LoadingAlert {
    override func startLoading() {
        setAlert()
        super.startLoading()
    }
    
    func setAlert() {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.startAnimating()
        
        alert.view.widthAnchor.constraint(equalToConstant: 120).isActive = true
        alert.view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        alert.view.addSubview(activityView)
        
        activityView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor).isActive = true
        activityView.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor, constant: 20).isActive = true
    }
}

class ProgressBarLoadingAlert: LoadingAlert {
    let maxCount: Int
    var count: Int
    var loadingViewWidthContraint: NSLayoutConstraint!
    
    init(targetVC: UIViewController, maxCount: Int) {
        self.maxCount = maxCount
        self.count = 0
        super.init(targetVC: targetVC)
    }
    
    override func startLoading() {
        setAlert()
        super.startLoading()
    }
    
    func setAlert() {
        let activityView = UIView(frame: CGRect(x: 0, y: 300, width: 200, height: 10))
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.backgroundColor = .white
        
        alert.title = "Loading\n\(count) / \(maxCount)"
        alert.view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        alert.view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        alert.view.addSubview(activityView)
        
        activityView.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor, constant: 30).isActive = true
        activityView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        loadingViewWidthContraint = activityView.widthAnchor.constraint(equalToConstant: 0)
        loadingViewWidthContraint.isActive = true
    }
    
    func addCount() {
        DispatchQueue.main.async { [self] in
            count += 1
            alert.title = "Loading\n\(count) / \(maxCount)"
            loadingViewWidthContraint.constant = CGFloat(round(Double(count) * Double(200 / Double(maxCount))))
        }
    }
}
