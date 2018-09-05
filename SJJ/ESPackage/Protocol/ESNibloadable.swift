//
//  ESNibloadable.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/4.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import Foundation

/// 加载xib View
protocol ESNibloadable {
    
}

extension ESNibloadable where Self : UIView{
    /*
     static func loadNib(_ nibNmae :String = "") -> Self{
     let nib = nibNmae == "" ? "\(self)" : nibNmae
     return Bundle.main.loadNibNamed(nib, owner: nil, options: nil)?.first as! Self
     }
     */
    static func loadNib(_ nibNmae :String? = nil) -> Self{
        return Bundle.main.loadNibNamed(nibNmae ?? "\(self)", owner: nil, options: nil)?.first as! Self
    }
}
