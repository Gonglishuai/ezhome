//
//  ESProgressHUD.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit
//import MBProgressHUD

public class ESProgressHUD: MBProgressHUD {

    @discardableResult
    static public func show(in view: UIView) -> ESProgressHUD {
        var esHUD = hud(for: view)
        if esHUD == nil {
            esHUD = ESProgressHUD(view: view)
            view.addSubview(esHUD!)
        }
        
        esHUD?.removeFromSuperViewOnHide = true
        esHUD?.show(animated: true)
        
        return esHUD!
    }
    
    @discardableResult
    static public func hide(for view: UIView) -> Bool {
        guard let esHUD = hud(for: view) else {
            return false
        }
        esHUD.removeFromSuperViewOnHide = true
        esHUD.hide(animated: true)
        return true
    }
    
    @discardableResult
    static public func hud(for view: UIView) -> ESProgressHUD? {
        let collection = view.subviews.reversed()
        for subView in collection {
            if subView is ESProgressHUD {
                return subView as? ESProgressHUD
            }
        }
        return nil
    }
    
    static public func showText(in view: UIView, text: String) {
        
        let esHUD = showAdded(to: view, animated: true)
        esHUD.mode = .text
        esHUD.label.text = text
        esHUD.label.adjustsFontSizeToFitWidth = true
        esHUD.label.minimumScaleFactor = 0.5
        esHUD.margin = 30.0
        esHUD.offset = CGPoint(x: esHUD.offset.x, y: 0)
        esHUD.removeFromSuperViewOnHide = true
        esHUD.hide(animated: true, afterDelay: 1.5)
    }
}
