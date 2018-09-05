//
//  ESStarView.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

typealias tapActionBlock = ((_ index:Int)->Void)

class ESStarView: UIView {
    
    //TODO: -  修改图片
    private  let defaultImage:UIImage = #imageLiteral(resourceName: "evaluate")
    private let selectedImage:UIImage = #imageLiteral(resourceName: "evaluate_sel")

    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        let iocnWH = 15.scalValue
        let iconX = iocnWH + 5.scalValue
        
  
        for i in 0..<5 {
            
            let imageView = UIImageView(frame: CGRect(x: iconX * CGFloat(i), y: 0, width: iocnWH, height: iocnWH))
            self.addSubview(imageView)
            
            imageView.image = defaultImage
            imageView.isUserInteractionEnabled = true
            
            imageView.tag = 10 + i
            
            if 0 == i {
                imageView.image = selectedImage
            }

            let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod(tap:)))
            imageView.addGestureRecognizer(tap)
        }
        
    }
    
    @objc func tapMethod(tap:UITapGestureRecognizer){
        
        let index = (tap.view?.tag)! - 10
        
        for i in 0..<5 {
            let imageView:UIImageView = self.viewWithTag(10 + i) as! UIImageView
            if i <= index {
                imageView.image = selectedImage
            } else {
                imageView.image = defaultImage
            }
        }
        
        if let block = self.tapAction {
            block(index + 1)
        }
    }
    private var tapAction:tapActionBlock?
    func tapBlock(_ block:@escaping tapActionBlock){
        self.tapAction = block
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
