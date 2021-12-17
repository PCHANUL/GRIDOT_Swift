//
//  Gradient.swift
//  spriteMaker
//
//  Created by 박찬울 on 2021/06/01.
//

import UIKit

class GradientSliderView: UIView {
    var slider: UISlider!
    var sliderGradient: Gradient!
    var BGGradient: CAGradientLayer!
    var selectedColor: UIColor!
    var changeColorFunc: ((_: UIColor)->())!
    var sliderColor: UIColor {
        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0;
        let sValue: CGFloat, vSat: CGFloat, vBri: CGFloat, newColor: UIColor;

        selectedColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        sValue = CGFloat(slider.value)
        vSat = (sat / 2) * sValue
        vBri = (bri / 2) * sValue
        newColor = UIColor.init(
            hue: hue, saturation: min(sat + vSat, 1),
            brightness: min(bri + vBri, 1), alpha: alpha
        )
        return newColor
    }
    
    override func awakeFromNib() {
        initSlider()
        initSliderGesture()
        clipsToBounds = true
    }
    
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint
        let widthOfSlider: CGFloat
        let newValue: CGFloat
        
        pointTapped = gestureRecognizer.location(in: self)
        widthOfSlider = slider.frame.size.width
        print(pointTapped.x)
        newValue = (pointTapped.x - frame.size.width / 2) * (CGFloat(slider.maximumValue) * 2) / widthOfSlider
        slider.setValue(Float(newValue), animated: true)
        changeColorFunc(sliderColor)
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .moved:
                changeColorFunc(sliderColor)
            case .ended:
                break
            default:
                break
            }
        }
    }
    
    func initSlider() {
        let sliderThumbImage = getThumbImage()
        slider = UISlider(frame: CGRect.zero)
        slider.setThumbImage(sliderThumbImage, for: .normal)
        slider.setThumbImage(sliderThumbImage, for: .highlighted)
        slider.maximumValue = 1
        slider.minimumValue = -1
        slider.minimumTrackTintColor = UIColor.clear
        slider.maximumTrackTintColor = UIColor.clear
        self.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        slider.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        slider.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        slider.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func initSliderGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(sliderTapped(gestureRecognizer:))
        )
        slider.addGestureRecognizer(tapGestureRecognizer)
        slider.addTarget(self, action: #selector(onSliderValChanged), for: .valueChanged)
    }
    
    func getThumbImage() -> UIImage {
        let width = self.bounds.height
        let thumb = UIView(frame: CGRect(x: 0, y: 0, width: width / 4, height: width))
        let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: width * 2, height: width))
        
        setViewShadow(target: thumb, radius: 3, opacity: 0.5)
        thumb.backgroundColor = .white
        thumb.center = CGPoint(
            x: thumbView.frame.size.width  / 2,
            y: thumbView.frame.size.height / 2
        )
        thumbView.addSubview(thumb)
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { context in
            thumbView.layer.render(in: context.cgContext)
        }
    }
    
    func changeSliderGradientColor(_ color: UIColor) {
        let subLayers = layer.sublayers!
        
        selectedColor = color
        if subLayers.count == 1 {
            sliderGradient = Gradient(color: selectedColor)
            BGGradient = sliderGradient.gl
            layer.insertSublayer(BGGradient, at: 0)
            BGGradient.frame = bounds
        } else {
            let oldLayer = subLayers[0]
            sliderGradient = Gradient(color: selectedColor)
            BGGradient = sliderGradient.gl
            layer.replaceSublayer(oldLayer, with: BGGradient)
            BGGradient.frame = bounds
        }
        setNeedsLayout()
        setNeedsDisplay()
    }
}


class Gradient {
    var gl: CAGradientLayer!
    
    init(color: UIColor) {
        self.gl = CAGradientLayer()
        setColor(color: color)
    }
    
    func setColor(color: UIColor) {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        
        let vSat = sat / 2
        let vBri = bri / 2
        let colorB = UIColor(
            hue: hue, saturation: min(sat - vSat, 1),
            brightness: min(bri - vBri, 1), alpha: alpha
        )
        let colorL = UIColor(
            hue: hue, saturation: min(sat + vSat, 1),
            brightness: min(bri + vBri, 1), alpha: alpha
        )
        self.gl.colors = [colorB.cgColor, colorL.cgColor]
        
        let endPointX = 0.5 - ((1 - bri) / vBri)
        self.gl.startPoint = CGPoint(x: 0, y: 0)
        self.gl.endPoint = CGPoint(x: endPointX > 0 ? endPointX : 0.5, y: 0)
        
        print(colorB, colorL, endPointX)
    }
}
