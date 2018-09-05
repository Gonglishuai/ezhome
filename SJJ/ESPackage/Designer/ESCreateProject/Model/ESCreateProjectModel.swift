//
//  ESCreateProjectModel.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// 创建家装项目model
class ESCreateProjectModel: NSObject {
 
    static func createModel() -> [(title:String, grayIcon:String, blackIcon:String)] {
        
        let iconGroup:[(title:String, grayIcon:String, blackIcon:String)] =
            [("业主姓名","owner_name_gray","owner_name_black"),
             ("联系电话","phone_gray","phone_black"),
             ("小区地址","address_gray","address_black"),
             ("小区名称","community_name_gray","community_name_black"),
             ("房屋类型","create_project_housetype","create_project_housetype_black"),
             ("户型","create_project_roomtype","create_project_roomtype_black"),
             ("套内建筑面积(㎡)","house_area","house_area_black"),
             ("项目类型","project_type_gray","project_type_black")]
        
        return iconGroup
        
    }
    
    static func createAppointModel() ->[(title:String, grayIcon:String, blackIcon:String)] {
        
        let iconGroup:[(title:String, grayIcon:String, blackIcon:String)] =
            [("您的姓名","owner_name_gray","owner_name_black"),
             ("手机号码","phone_gray","phone_black"),
             ("套内建筑面积（㎡）","house_area","house_area_black"),
             ("装修预算（万）","decorate_budget_gray","decorate_budget_black"),
             ("房屋类型","create_project_housetype","create_project_housetype_black"),
             ("小区地址（省市区）","address_gray","address_black"),
             ("小区名称","community_name_gray","community_name_black")]
        
        return iconGroup
    }
    
    static func uploadDicForCreateProject()-> Dictionary<String,String> {
        return [ESCreateProjectUploadDic.OwnerName.rawValue:"",
                ESCreateProjectUploadDic.Phone.rawValue:"",
                ESCreateProjectUploadDic.ConsumerJid.rawValue:"",
                ESCreateProjectUploadDic.ComunityName.rawValue:"",
                ESCreateProjectUploadDic.HouseType.rawValue:"",
                ESCreateProjectUploadDic.RoomType.rawValue:"",
                ESCreateProjectUploadDic.HouseArea.rawValue:"",
                ESCreateProjectUploadDic.ProjectType.rawValue:"",
                ESCreateProjectUploadDic.Province.rawValue:"",
                ESCreateProjectUploadDic.ProvinceName.rawValue:"",
                ESCreateProjectUploadDic.City.rawValue:"",
                ESCreateProjectUploadDic.CityName.rawValue:"",
                ESCreateProjectUploadDic.District.rawValue:"",
                ESCreateProjectUploadDic.DistrictName.rawValue:"",
                ESCreateProjectUploadDic.SelectedType.rawValue:"5",
                ESCreateProjectUploadDic.FreeAuditFlag.rawValue:"1",
                ESCreateProjectUploadDic.Channel.rawValue:"app"]
    }
    
    static func uploadDicForFreeAppoint()-> Dictionary<String,String> {
        return [ESFreeAppointUploadDic.YourName.rawValue:"",
                ESFreeAppointUploadDic.Phone.rawValue:"",
                ESFreeAppointUploadDic.HouseArea.rawValue:"",
                ESFreeAppointUploadDic.DecorationBudget.rawValue:"",
                ESFreeAppointUploadDic.HouseType.rawValue:"",
                ESFreeAppointUploadDic.CommunityName.rawValue:"",
                ESFreeAppointUploadDic.ProvinceName.rawValue:"",
                ESFreeAppointUploadDic.Province.rawValue:"",
                ESFreeAppointUploadDic.City.rawValue:"",
                ESFreeAppointUploadDic.CityName.rawValue:"",
                ESFreeAppointUploadDic.District.rawValue:"",
                ESFreeAppointUploadDic.DistrictName.rawValue:"",
                ESFreeAppointUploadDic.FreeAuditFlag.rawValue:"0",
                ESFreeAppointUploadDic.DesignStyle.rawValue:"",
                ESFreeAppointUploadDic.Channel.rawValue:"app",
                ESFreeAppointUploadDic.SourceUrl.rawValue:"",
                ESFreeAppointUploadDic.SourceName.rawValue:"",
                ESFreeAppointUploadDic.SourceType.rawValue:""]
    }
}

struct ESAppointSuccessModel:Decodable {
    let success:Bool?
    let assetId:Int?
}
