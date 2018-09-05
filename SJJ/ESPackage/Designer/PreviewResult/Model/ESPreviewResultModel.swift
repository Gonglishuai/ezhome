//
//  ESPreviewResultModel.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/19.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPreviewResultModel: NSObject {
    
    static func creatModel()->[(leftTitle:String, placeHold:String)] {
        
        let titleGroup = [("预交底时间","请选择时间"),
                          ("业主姓名",""),
                          ("联系电话",""),
                          ("套内建筑面积","请输入套餐内建筑面积"),
                          ("房屋类型","请选择房屋类型"),
                          ("房屋户型","请选择房屋户型"),
                          ("小区地址","请选择省市区"),
                          ("小区名称","请输入小区名称")]
        return titleGroup
        
    }
    
    static func createUploadDic()-> Dictionary<String,String> {
        return [ESPreviewResultUploadDic.Date.rawValue:"",
                ESPreviewResultUploadDic.CosumerName.rawValue:"",
                ESPreviewResultUploadDic.Telephone.rawValue:"",
                ESPreviewResultUploadDic.HouseArea.rawValue:"",
                ESPreviewResultUploadDic.HouseType.rawValue:"",
                ESPreviewResultUploadDic.RoomType.rawValue:"",
                ESPreviewResultUploadDic.Adress.rawValue:"",
                ESPreviewResultUploadDic.CommunityName.rawValue:"",
                ESPreviewResultUploadDic.Province.rawValue:"",
                ESPreviewResultUploadDic.ProvinceCode.rawValue:"",
                ESPreviewResultUploadDic.City.rawValue:"",
                ESPreviewResultUploadDic.CityCode.rawValue:"",
                ESPreviewResultUploadDic.District.rawValue:"",
                ESPreviewResultUploadDic.DistrictCode.rawValue:"",
                ESPreviewResultUploadDic.ErpId.rawValue:"",
                ESPreviewResultUploadDic.ProjectId.rawValue:"",
                ESPreviewResultUploadDic.Mark.rawValue:""]
    }
    
    static func uploadDicValue(uploadDic:Dictionary<String,String>, model:ESPreviewResultUploadModel)->Dictionary<String,String> {
        
        var dict = uploadDic
        
        dict[ESPreviewResultUploadDic.CosumerName.rawValue] = model.name
        
        dict[ESPreviewResultUploadDic.Telephone.rawValue] = model.mobile
        
        dict[ESPreviewResultUploadDic.HouseArea.rawValue] = model.houseSize
        
        dict[ESPreviewResultUploadDic.HouseType.rawValue] = model.houseType
        
        dict[ESPreviewResultUploadDic.RoomType.rawValue] = model.roomType
        
        dict[ESPreviewResultUploadDic.Province.rawValue] = model.province
        
        dict[ESPreviewResultUploadDic.ProvinceCode.rawValue] = model.provinceCode
        
        dict[ESPreviewResultUploadDic.CityCode.rawValue] = model.cityCode
        
        dict[ESPreviewResultUploadDic.City.rawValue] = model.city
        
        dict[ESPreviewResultUploadDic.District.rawValue] = model.district
        
        dict[ESPreviewResultUploadDic.DistrictCode.rawValue] = model.districtCode
        
        dict[ESPreviewResultUploadDic.ErpId.rawValue] = model.erpId
        
        dict[ESPreviewResultUploadDic.ProjectId.rawValue] = model.projectId
        
        dict[ESPreviewResultUploadDic.CommunityName.rawValue] = model.community
        
        dict[ESPreviewResultUploadDic.Adress.rawValue] = model.address
        
        return dict
    }
    
    static func checkUploadDic(_ target:ESPreviewResultViewController, uploadDic:Dictionary<String,String>) -> Bool{
        
        if uploadDic[ESPreviewResultUploadDic.Date.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请选择预交底时间")
            return false
        }
        
        if uploadDic[ESPreviewResultUploadDic.CosumerName.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请填写您的姓名")
            return false
        }
        
        let phone = uploadDic[ESPreviewResultUploadDic.Telephone.rawValue]
        if phone == "" {
            ESProgressHUD.showText(in: target.view, text: "请填写您的手机号")
            return false
        }
        
        if !ESFormCheck.isPhoneNum(phone) {
            ESProgressHUD.showText(in: target.view, text: "请您输入合适的联系电话")
            return false
            
        }
        
        let houseArea = uploadDic[ESPreviewResultUploadDic.HouseArea.rawValue] ?? ""
        if houseArea == "" {
            ESProgressHUD.showText(in: target.view, text: "请填写您的套内建筑面积")
            return false
        }
        
        if Double(houseArea) == 0.0 {
            ESProgressHUD.showText(in: target.view, text: "啊哦~您填写的面积有误")
            return false
        }
        
        if uploadDic[ESPreviewResultUploadDic.HouseType.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请选择您的房屋类型")
            return false
        }
        
        if uploadDic[ESPreviewResultUploadDic.RoomType.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请选择您的房屋户型")
            return false
        }
        
        if uploadDic[ESPreviewResultUploadDic.Province.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请选择您的小区地址")
            return false
        }
        
        if uploadDic[ESPreviewResultUploadDic.CommunityName.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请填写您的小区名称")
            return false
        }
        
        if uploadDic[ESPreviewResultUploadDic.Adress.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请填写您的详细地址")
            return false
        }
        
        return true
    }
    
}
