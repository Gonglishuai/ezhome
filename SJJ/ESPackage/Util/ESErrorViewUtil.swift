
//
//  ESErrorViewUtil.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/11.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import Foundation

class ESErrorViewUtil:NSObject {
    
    var noDataView:NoDataView!
    
    /// 展示无数据View
    ///
    /// - Parameter superView: UIView

    func showNoDataView(in superView:UIView){
        noDataView = NoDataView.creat(withImgName: "nodata_datas", title: "啊哦~暂时没有数据~", buttonTitle: "", block: nil)
        
        noDataView.frame = CGRect(x: 0, y: 0, width: superView.frame.size.width, height: superView.frame.size.height)

        superView.addSubview(noDataView!)
       
        superView.bringSubview(toFront: noDataView!)
    }
    
    /// 可自行添加自定义的 error View（设置默认展示的图片，标题，按钮，以及回调）
    ///
    /// - Parameters:
    ///   - superView: 一般为 VC.View 或 tableView 等
    ///   - imgName: String
    ///   - title: String
    ///   - buttonTitle: String
    ///   - block: (()->Void)?

     func showErrorView(in superView:UIView, imgName:String, title:String, buttonTitle:String?, block:(()->Void)?){

        noDataView = NoDataView.creat(withImgName: imgName, title: title, buttonTitle: buttonTitle ?? "", block: block ?? nil)
        
        noDataView.frame = CGRect(x: 0, y: 0, width: superView.frame.size.width, height: superView.frame.size.height)
        
        superView.addSubview(noDataView!)
        
        superView.bringSubview(toFront: noDataView!)
    }
    
    /// 隐藏/移除EErrorView
    func hiddenErrorView(){
        
        if (noDataView != nil) {
            noDataView.removeFromSuperview()
            noDataView = nil
        }
    }
}
