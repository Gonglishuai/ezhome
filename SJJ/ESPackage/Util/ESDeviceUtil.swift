//
//  ESDeviceUtil.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

public struct ESDeviceUtil {
    static let screen_w = UIScreen.main.bounds.size.width
    
    static let screen_h = UIScreen.main.bounds.size.height
    
    static let navibar_h = CGFloat(64.0)
    
    /// 打电话
    ///
    /// - Parameter numberString: String
    static func callToSomeone(numberString:String?){
        
        guard let number = numberString,number.count > 1 else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL.init(string: "tel:\(number)")!, options: [ : ], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL.init(string: "tel:\(number)")!)
        }
    }
}
