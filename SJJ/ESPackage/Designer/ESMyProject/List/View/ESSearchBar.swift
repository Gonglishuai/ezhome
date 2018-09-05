//
//  ESSearchBar.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESSearchBar: UISearchBar {

    var contentInset: UIEdgeInsets? {
        didSet {
            self.layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // view是searchBar中的唯一的直接子控件
        for view in self.subviews {
            // UISearchBarBackground与UISearchBarTextField是searchBar的简介子控件
            for subview in view.subviews {
                
                // 找到UISearchBarTextField
                if subview is UITextField {
                    
                    // 更改字体大小及圆角
                    let textField = subview as! UITextField
                    textField.font = ESFont.font(name: .regular, size: 12.0)
                    textField.layer.cornerRadius = 6.0
                    textField.layer.masksToBounds = true
                    
                    if let textFieldContentInset = contentInset { // 若contentInset被赋值
                        // 根据contentInset改变UISearchBarTextField的布局
                        subview.frame = CGRect(x: textFieldContentInset.left, y: textFieldContentInset.top, width: self.bounds.width - textFieldContentInset.left - textFieldContentInset.right, height: self.bounds.height - textFieldContentInset.top - textFieldContentInset.bottom)
                    } else { // 若contentSet未被赋值
                        // 设置UISearchBar中UISearchBarTextField的默认边距
                        let top: CGFloat = (self.bounds.height - 28.0) / 2.0
                        let bottom: CGFloat = top
                        let left: CGFloat = 8.0
                        let right: CGFloat = left
                        contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
                    }
                }
            }
        }
    }
}
