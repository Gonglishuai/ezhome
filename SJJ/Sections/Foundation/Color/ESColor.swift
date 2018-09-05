//
//  ESColor.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/13.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

public class ESColor: NSObject {
    /// 通过RGBA获取颜色
    ///
    /// - Parameters:
    ///   - R: red
    ///   - G: green
    ///   - B: bule
    ///   - A: alph
    /// - Returns: 颜色
    public static func color(_ R: CGFloat, _ G: CGFloat, _ B: CGFloat, _ A: CGFloat) -> UIColor {
        return UIColor.init(red: R / 255.0, green: G / 255.0, blue: B / 255.0, alpha: A)
    }
    
    /// 获取16进制色值获取颜色
    ///
    /// - Parameters:
    ///   - hexColor: 色值
    ///   - alpha: alph
    /// - Returns: 颜色
    public static func color(hexColor: Int, alpha: CGFloat) -> UIColor {
        let r = CGFloat.init(((Float)((hexColor & 0xFF0000) >> 16)) / 255.0)
        let g = CGFloat.init(((Float)((hexColor & 0xFF00) >> 8)) / 255.0)
        let b = CGFloat.init(((Float)(hexColor & 0xFF)) / 255.0)
        
        return UIColor.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    public static func color(sample: ESColorSample) -> UIColor {
        return color(hexColor: sample.rawValue, alpha: 1.0)
    }
    
    /// UIColor 转 UIImage
    ///
    /// - Parameter color: 要转换的颜色
    /// - Returns: 颜色对应的UIImage
    public static func getImage(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


