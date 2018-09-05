//
//  ESPackageAsserts.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import Foundation

open class ESPackageAsserts: NSObject {
    
    static var hostBundle: Bundle {
//        let podBundle = Bundle(for: ESPackageAsserts.self)
//        let bundleURL = podBundle.url(forResource: "ESPackage", withExtension: "bundle")
//        return podBundle
        //加入主工程师时，打开下面
//        return Bundle(url: bundleURL!)!
        return .main
    }
    
    open class func bundleImage(named name: String) -> UIImage {
        if let image = UIImage(named: name, in: hostBundle, compatibleWith: nil) {
            return image
        } else {
            return UIImage()
        }
    }
}
