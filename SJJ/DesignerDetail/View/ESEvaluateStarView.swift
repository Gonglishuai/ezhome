//
//  ESStarView.swift
//  EZHome
//
//  Created by shiyawei on 6/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESEvaluateStarView: UIView {

    private  let defaultImage:UIImage = #imageLiteral(resourceName: "evaluate")
    private  let selectedImage:UIImage = #imageLiteral(resourceName: "evaluate_sel")
    

    
    func createStar(count:Int) {
        
        let iconW = defaultImage.size.width
        let iconH = defaultImage.size.height
        
        for i in 0..<5 {
            let imageView = UIImageView(frame: CGRect(x: (iconW + 8) * CGFloat(i), y: 0, width: iconW, height: iconH))
            self.addSubview(imageView)
            
            imageView.image = defaultImage
            
            imageView.tag = 10 + i
            
            if i <= count {
                imageView.image = selectedImage
            }
        }
    }
    

}
