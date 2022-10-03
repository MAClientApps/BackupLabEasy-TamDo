//
//  Extension.swift
//  Restore Master Pro
//
//  Created by Online on 22/09/22.
//

import Foundation
import UIKit
import ProgressHUD


var restoreStoryboard = UIStoryboard(name: "Main", bundle: nil)

@IBDesignable
class MyGradientView: UIView {
    
    @IBInspectable var color1: UIColor = .red {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var color2: UIColor = .yellow {
        didSet { setNeedsDisplay() }
    }

    private var gradientLayer: CAGradientLayer!
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() -> Void {
        // use self.layer as the gradient layer
        gradientLayer = self.layer as? CAGradientLayer
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
    }
}

@IBDesignable
class ShadowView: UIView {
    //Shadow
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 3, height: 3) {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 15.0 {
        didSet {
            self.updateView()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 20 {
        didSet {
            self.updateView()
        }
    }

    //Apply params
    func updateView() {
        self.layer.shadowColor = self.shadowColor.cgColor
        self.layer.shadowOpacity = self.shadowOpacity
        self.layer.shadowOffset = self.shadowOffset
        self.layer.shadowRadius = self.shadowRadius
        self.layer.cornerRadius = self.cornerRadius
    }
}

extension UIView {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
   
    
   
}

extension UIViewController{
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showHud() {
        ProgressHUD.animationType = .systemActivityIndicator
        ProgressHUD.colorProgress = .systemBlue
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.colorBackground = .clear
        ProgressHUD.show()
    }

    func hideHUD() {
        ProgressHUD.dismiss()
    }
    
    
    func alert(message: String, title: String = "") {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(OKAction)
      self.present(alertController, animated: true, completion: nil)
    }
}
// Screen width.
public var screenWidth: CGFloat {
  return UIScreen.main.bounds.width
}


extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
  
  func dropShadowed(cornerRadius:CGFloat, corners: UIRectCorner, borderColor: UIColor, borderWidth:CGFloat, shadowColor:UIColor) {
      let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
      layer.mask?.shadowPath = path.cgPath
      layer.shadowColor = shadowColor.cgColor
      layer.shadowOffset = CGSize(width: -1, height: 1)
      layer.shadowOpacity = 0.5
      layer.shadowRadius = 8
      layer.cornerRadius = cornerRadius
      
      if corners.contains(.topLeft) || corners.contains(.topRight) {
          layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
      }
      if corners.contains(.bottomLeft) || corners.contains(.bottomRight) {
          layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
      }
      layer.borderColor = borderColor.cgColor
      layer.borderWidth = borderWidth
      layer.shadowPath =  nil//path.cgPath
      layer.masksToBounds = false
      layer.shouldRasterize = true
      layer.rasterizationScale = UIScreen.main.scale
  }
  
  
  var globalFrame: CGRect? {
      let rootView = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController?.view
      return self.superview?.convert(self.frame, to: rootView)
  }
}

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow?{
        return windows.first(where: {$0.isKeyWindow})
    }
}

extension UIColor {
  
  /// color with hax string
  ///
  /// - Parameter hexString: hexString description
  convenience init(hexString:String) {
      var hexString:String = hexString.trimmingCharacters(in: CharacterSet.whitespaces)
      
      if (hexString.hasPrefix("#")) { hexString.remove(at: hexString.startIndex) }
      
      var color:UInt64 = 0
      Scanner(string: hexString).scanHexInt64(&color)
      
      let mask = 0x000000FF
      let r = Int(color >> 16) & mask
      let g = Int(color >> 8) & mask
      let b = Int(color) & mask
      
      let red   = CGFloat(r) / 255.0
      let green = CGFloat(g) / 255.0
      let blue  = CGFloat(b) / 255.0
      
      self.init(displayP3Red: red, green: green, blue: blue, alpha: 1)
      //self.init(red:red, green:green, blue:blue, alpha:1)
  }
  
  
  static let themeColor = UIColor(hexString: "#000000")
  static let themeFontColor = UIColor(hexString: "#3096F3")
  static let themeFontLightColor = UIColor(hexString: "#8C98A9")
}


public enum VC_TYPE:Int {
  case Dummy = 5
  case Home = 0
  case Menu = 1
  case Cart = 2
  case Profile = 3
}

extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds

        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}


//@IBDesignable
//class Blur: UIImageView {
//
//    @IBInspectable var blurImage:UIImage?{
//        didSet{
//            updateImage(imageBlur: blurImage!)
//        }
//    }
//    func updateImage(imageBlur:UIImage){
//        let imageToBlur:CIImage = CIImage(image: imageBlur)!
//        let blurFilter:CIFilter = CIFilter(name: "CIGaussianBlur")!
//        blurFilter.setValue(imageToBlur, forKey: "inputImage")
//        let resultImage:CIImage = blurFilter.value(forKey: "outputImage")! as! CIImage
//        self.image = UIImage(ciImage: resultImage)
//    }
//}
