//
//  ESTableViewCellProtocol.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/22.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit


/// TableView公共协议
@objc
protocol ESTableViewProtocol {
    
    /// 获取组数
    ///
    /// - Returns: 组数
    @objc optional func getSectionNum() -> Int
    
    
    /// 获取item数
    ///
    /// - Returns: item数
    func getItemNum(section: Int) -> Int
    
    /// 选择一个item
    ///
    /// - Parameters:
    ///   - index: item索引
    ///   - section: 组索引
    @objc optional func selectItem(index: Int, section: Int)
}


/// TableViewCell公共协议
protocol ESTableViewCellProtocol {
    
    /// 获取cell对应的模型信息
    ///
    /// - Parameters:
    ///   - index: item索引
    ///   - section: 组索引
    ///   - viewModel: cell绑定的模型
    func getViewModel(index: Int, section: Int, cellId: String, viewModel: ESViewModel)
}


