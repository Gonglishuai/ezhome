//
//  ESViewFactory.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit


/// 创建一些可复用的UIView
struct ESUIViewFactory {
    
    /// 一个 UITableView (默认设置一些属性)
    ///
    /// - Returns: UITableView
    static func tableView(_ type:UITableViewStyle)-> UITableView {
        
        let tableView = UITableView(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), style: type)
        
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = ESColor.color(sample: .backgroundView)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }
    
    
    /// 一个 UICollectionView (默认设置一些属性)
    ///
    /// - Returns: UICollectionView
    static func collectionView() -> UICollectionView {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.keyboardDismissMode = .onDrag

        return collectionView
    }
    
    /// 一个 UIButton (默认底部蓝色button)
    ///
    /// - Returns: UIButton
    static func button(_ title:String = "确定")-> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: ScreenHeight - 50, width: ScreenWidth, height: 50))
        
        button.backgroundColor = ESColor.color(sample: .buttonBlue)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font  = ESFont.font(name: ESFont.ESFontName.regular, size: 16)
        button.setTitle(title, for: .normal)
        
        return button
    }
    
    /// a main UILabel (字号：PingFangSC-Regular 16，颜色：#2D2D34 100%)
    ///
    /// - Returns: UILabel
    static func mainLabel()-> UILabel {
        let label = UILabel()
        
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: .regular, size: 16)
        
        return label
    }
    
    
    /// 灰色细线
    ///
    /// - Returns: UIView
    static func line()-> UIView{
        let line = UIView()
        line.backgroundColor = ESColor.color(sample: .separatorLine)
        return line
    }

}
