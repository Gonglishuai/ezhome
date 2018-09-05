//
//  ESUIImageView+extension.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    
     /// 给 UIImageView 设置web图片，可设置默认UIImage
     ///
     /// - Parameters:
     ///   - urlString: String
     ///   - placeHold: UIImage
     func imageWith(_ urlString:String, placeHold:UIImage = #imageLiteral(resourceName: "default_banner")){
        let url = URL.init(string: urlString)
        self.kf.setImage(with: url, placeholder: placeHold, options: nil, progressBlock: nil, completionHandler: nil)
        
    }
}

