//
//  ESCGRectUtil.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

struct ESCGRectUtil {
    
    
    /// get UIView 相对屏幕的 CGRect
    ///
    /// - Parameter view: UIView
    /// - Returns: CGRect
    static func getRelativeCGrect(view:UIView)-> CGRect{
       
        if let delegate = UIApplication.shared.delegate {
            if let window = delegate.window {
                let rect = view.convert(view.bounds, to: window)
                return rect
            }
        }
        return CGRect.zero
    }
    
    
    /// get UIView 升起高度
    ///
    /// - Parameters:
    ///   - currentRect: CGRect
    ///   - notice: Notification
    /// - Returns: CGFloat
    static func getUpHeight(_ currentRect:CGRect, notice:Notification) ->CGFloat{
        
        let nsValue = notice.userInfo![UIKeyboardFrameEndUserInfoKey]as!NSValue
        let keyboardY = nsValue.cgRectValue.origin.y
        var upHeight:CGFloat = 0
        let maxY = currentRect.maxY
        
        if maxY > keyboardY {
            upHeight = keyboardY -  maxY - currentRect.size.height
        }
        return upHeight
    }
}

