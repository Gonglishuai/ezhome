//
//  ESCreateProjectViewManager.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// view mangager or helper for CreateProject

class ESCreateProjectViewManager: NSObject {
    
    lazy var tableView: UITableView = {
        
        let tableView = ESUIViewFactory.tableView(.plain)
        
        tableView.rowHeight = 53
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 10
        
        tableView.register(ESCreateProjectTableViewCell.self, forCellReuseIdentifier: "ESCreateProjectTableViewCell")
        tableView.register(SectionFooterForCreateProject.self, forHeaderFooterViewReuseIdentifier: "SectionFooterForCreateProject")
        
        tableView.tableHeaderView = tableHeaderView
        return tableView
    }()
    
    lazy var tableHeaderView: UIView = {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 53))
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        
        var label = UILabel()
        view.addSubview(label)
        
        label.text = "客户资料"
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: ESFont.ESFontName.medium, size: 14)
        
        label.snp.makeConstraints({ (make) in
            make.left.equalTo(20)
            make.centerY.equalTo(view.snp.centerY)
            make.size.equalTo(CGSize(width: 80, height: 20))
        })
        
        return view
    }()
    
    func conformCreateProject(_ target:ESCreateProjectViewController) -> UIButton {
        
        let button = ESUIViewFactory.button("确认创建")
        
        button.addTarget(target, action: #selector(target.createProject), for: .touchUpInside)
        
        return button
    }
    
    func getCreateProjectCell(_ type:String,collectionView:UITableView)-> ESCreateProjectTableViewCell{
        var itemIndex = 7
        if type == "HousingState" {
            itemIndex = 4
        } else if type == "HousingStyle"{
            itemIndex = 5
        }
        let indexPath = IndexPath(item: 0, section: itemIndex)
        let cell = collectionView.cellForRow(at: indexPath)as!ESCreateProjectTableViewCell
        return cell
    }
 
    func checkCreateProjectUploadDic(_ target:ESCreateProjectViewController, uploadDic:Dictionary<String,String>)-> Bool {
        
        if uploadDic[ESCreateProjectUploadDic.OwnerName.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请您输入业主姓名")
            return false
        }
        
        let phone = uploadDic[ESCreateProjectUploadDic.Phone.rawValue]
        if phone == "" {
            ESProgressHUD.showText(in: target.view, text: "请您输入联系电话")
            return false
        }
        
        if !ESFormCheck.isPhoneNum(phone) {
            ESProgressHUD.showText(in: target.view, text: "请您输入合适的联系电话")
            return false

        }
        
        if uploadDic[ESCreateProjectUploadDic.ProvinceName.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请您选择小区地址")
            return false
        }
        
        if uploadDic[ESCreateProjectUploadDic.ComunityName.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请您输入小区名称")
            return false
        }
        
        if uploadDic[ESCreateProjectUploadDic.HouseType.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请您选择房屋类型")
            return false
        }
        
        if uploadDic[ESCreateProjectUploadDic.RoomType.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请您选择户型")
            return false
        }
        
        let houseArea = uploadDic[ESCreateProjectUploadDic.HouseArea.rawValue] ?? ""
        if houseArea == "" {
            ESProgressHUD.showText(in: target.view, text: "请您输入套内建筑面积")
            return false
        }
        
        if Double(houseArea) == 0.0 {
            ESProgressHUD.showText(in: target.view, text: "啊哦~您填写的面积有误")
            return false
        }
        
        if uploadDic[ESCreateProjectUploadDic.ProjectType.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请您选择项目类型")
            return false
        }
                
        return true
    }

}

 class SectionFooterForCreateProject:UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 10)
        let view = UIView()//frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 53))
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        self.backgroundView = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
