//
//  constants.swift
//  DemoExpandingCollection
//
//  Created by Even_cheng on 2019/9/30.
//  Copyright © 2019 Even_cheng All rights reserved.
//
import UIKit
import Foundation
import Toast_Swift

public let kWindow: UIWindow = (UIApplication.shared.delegate as! AppDelegate).window!
public let kWindowBounds: CGRect = (UIApplication.shared.delegate as! AppDelegate).window?.bounds ?? UIScreen.main.bounds

extension UIView {
     public var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIView {
    
    public var currentViewController: UIViewController? {
    
        var vc = UIApplication.shared.delegate?.window!!.rootViewController
        while (true) {
            if vc!.isKind(of: UITabBarController.self) {
                vc = (vc as! UITabBarController).selectedViewController
            }
            if vc!.isKind(of: UINavigationController.self) {
                vc = (vc as! UINavigationController).visibleViewController
            }
            if vc?.presentedViewController != nil {
                vc = vc?.presentedViewController
            } else {
                break
            }
        }
        return vc
    }
}

extension UIView {
     public var size: CGSize {
        get {
            return frame.size
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }
}

extension UIView {
     public var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
}

extension UIView {
     public var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
}

extension UIView {
     public var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
}

extension UIView {
     public var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
}

extension UIView {
   public func addSubviews(_ subviews: [UIView]) {
       subviews.forEach({ self.addSubview($0) })
   }
   
   public func removeSubviews() {
       subviews.forEach({ $0.removeFromSuperview() })
   }
}

extension UIView {
    
    public func toastMessage(_ message: String?) {
    
        let msg = message ?? "提示"
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = UIColor.black
        self.makeToast(msg, duration: 2.0, position: .top, style: toastStyle)
    }
    
    public func toastSuccess(_ message: String?) {
    
        let msg = message ?? "成功"
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = UIColor.orange
        self.makeToast(msg, duration: 2.0, position: .top, style: toastStyle)
    }
    
    public func toastWarn(_ message: String?) {
        
        let msg = message ?? "警告"
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = UIColor.red
        self.makeToast(msg, duration: 1.0, position: .top, style: toastStyle)
    }
    
    public func toastError(_ message: String?) {
        
        let msg = message ?? "失败"
        var toastStyle = ToastStyle()
        toastStyle.backgroundColor = UIColor.red
        self.makeToast(msg, duration: 2.0, position: .top, style: toastStyle)
    }
    
}
