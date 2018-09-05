//
//  ESBaseTableView.swift
//  EZHome
//
//  Created by shiyawei on 2/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit



class ESBaseTableView: UITableView {

    var tView:Any?
    
    var showPullRefresh = Bool()
    var showPushMore = Bool()
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        showPullRefresh = false
        showPushMore = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    //    MARK:显示
    func showTopView() {
        
    }
    //    MARK:隐藏
    func hideTopView() {
        
    }
    //    MARK:
    func beginRefreshing() {
        
    }

    func endRefreshing() {
        
    }
    
    func beginLoadMore() {
        
    }
    
    func endLoadMore() {
        
    }
}
