//
//  ESFont.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/13.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

public class ESFont: NSObject {
    enum ESFontName: String {
        case regular = "PingFangSC-Regular"
        case light   = "PingFangSC-Light"
        case medium  = "PingFangSC-Medium"
        case smedium  = "PingFangSC-Semibold"
    }
    
    static func font(name: ESFontName, size: CGFloat) -> UIFont {
        let font: UIFont? = UIFont.init(name: name.rawValue, size: size)
        guard let esfont = font else {
            return UIFont.systemFont(ofSize: size)
        }
        return esfont
    }
}

extension UIFont {
    
}
