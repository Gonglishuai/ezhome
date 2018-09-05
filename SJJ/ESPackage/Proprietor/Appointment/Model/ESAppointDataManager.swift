//
//  ESAppointDataManager.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESAppointDataManager: NSObject {
    
    ///获取装修风格
    static func getDecorationStyle(_ success:@escaping (_ style:[ESAppointDecorateStyleModel])->Void, failed:@escaping (_ error:Error)->Void){
        
        ESAppointApi.getDecorationStyle({ (responseData) in
            let style = try?JSONDecoder().decode([ESAppointDecorateStyleModel].self, from: responseData)
            if let realStyle = style {
                success(realStyle)
            }
        }) { (error) in
            failed(error)
        }
    }
    
    /// 预交底
    static func fixPreviewMessage(_ info:ESSelectedRegion, uploadDic:Dictionary<String,String>)->Dictionary<String,String>{
        var dic = uploadDic
        
        dic[ESPreviewResultUploadDic.Province.rawValue] = info.province
        dic[ESPreviewResultUploadDic.ProvinceCode.rawValue] = info.provinceCode
        dic[ESPreviewResultUploadDic.City.rawValue] = info.city
        dic[ESPreviewResultUploadDic.CityCode.rawValue] = info.cityCode
        dic[ESPreviewResultUploadDic.District.rawValue] = info.district
        dic[ESPreviewResultUploadDic.DistrictCode.rawValue] = info.districtCode
        
        return dic
    }
    
    ///修改预约信息
    static func fixAppointMessage(_ info:ESSelectedRegion, uploadDic:Dictionary<String,String>)->Dictionary<String,String>{
        
        var dic = uploadDic
        
        dic[ESCreateProjectUploadDic.Province.rawValue] = info.provinceCode
        dic[ESCreateProjectUploadDic.ProvinceName.rawValue] = info.province
        dic[ESCreateProjectUploadDic.City.rawValue] = info.cityCode
        dic[ESCreateProjectUploadDic.CityName.rawValue] = info.city
        dic[ESCreateProjectUploadDic.DistrictName.rawValue] = info.district
        dic[ESCreateProjectUploadDic.District.rawValue] = info.districtCode
        
        return dic
    }
    
    static func checkInputedMessage(_ dict:Dictionary<String,String>, target:UIViewController) -> Bool{
        
        if dict[ESFreeAppointUploadDic.YourName.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请输入您的姓名")
            return false
        }
        
        let phone = dict[ESFreeAppointUploadDic.Phone.rawValue]
        if phone == "" {
            ESProgressHUD.showText(in: target.view, text: "请输入您的手机号")
            return false
        }
        
        if !ESFormCheck.isPhoneNum(phone) {
            ESProgressHUD.showText(in: target.view, text: "请您输入合适的联系电话")
            return false
            
        }
        
        let houseArea = dict[ESFreeAppointUploadDic.HouseArea.rawValue] ?? ""
        if houseArea == "" {
            ESProgressHUD.showText(in: target.view, text: "请输入您的房屋面积")
            return false
        }
        
        if Double(houseArea) == 0.0 {
            ESProgressHUD.showText(in: target.view, text: "啊哦~您填写的面积有误")
            return false
        }
        
        if dict[ESFreeAppointUploadDic.DecorationBudget.rawValue] == "" && !(target is ESAppointTableVC) {
            ESProgressHUD.showText(in: target.view, text: "请选择您的装修预算")
            return false
        }
        
        if dict[ESFreeAppointUploadDic.HouseType.rawValue] == "" && !(target is ESAppointTableVC){
            ESProgressHUD.showText(in: target.view, text: "请选择您的房屋类型")
            return false
        }
        
        if dict[ESFreeAppointUploadDic.DistrictName.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请选择您的小区地址")
            return false
        }
        
        if dict[ESFreeAppointUploadDic.CommunityName.rawValue] == "" {
            ESProgressHUD.showText(in: target.view, text: "请输入您的小区名称")
            return false
        }
        
        if dict[ESFreeAppointUploadDic.DesignStyle.rawValue] == "" && !(target is ESAppointTableVC){
            ESProgressHUD.showText(in: target.view, text: "请选择装修风格")
            return false
        }
        
        return true
        
    }
    
    
    static func compentDesignStyle(_ decorationStyle:[ESAppointDecorateStyleModel],selectedStyleArray:Array<Int>)-> String{
        var designArray = [String]()
        for i in 0..<decorationStyle.count {
            if selectedStyleArray[i] == 1 {
                let model = decorationStyle[i]
                designArray.append(model.styleEnglish ?? "")
            }
        }
        let designStyle = designArray.joined(separator: ",")
        return designStyle
    }
}
