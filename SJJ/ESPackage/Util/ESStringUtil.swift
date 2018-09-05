//
//  ESStringUtil.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit
import Foundation

public class ESStringUtil: NSObject {
    
    /// 判断字符串是否为nil或者为""
    ///
    /// - Parameter string: 待校验的字符串
    /// - Returns: 是否为空
    public static func isEmpty(_ string: String?) -> Bool {
        if let str = string {
            if str.count > 0 {
                return false
            }
        }
        return true
    }
    
    /// 计算带行间距的文字height
    ///
    /// - Parameters:
    ///   - string: String
    ///   - font: UIFont
    ///   - width: CGFloat
    ///   - space: CGFloat
    /// - Returns: CGFloat
    public static func returnStringHeight(_ string:String?, font:UIFont, width:CGFloat, space:CGFloat) ->CGFloat {
        guard let tmpString = string,tmpString != "" else {
            return 0
        }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        label.font = font
        label.numberOfLines = 0
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = space
        
        let attributeStr = NSMutableAttributedString(string: tmpString, attributes: [NSAttributedStringKey.paragraphStyle : paragraph])
        label.attributedText = attributeStr
        label.sizeToFit()
        
        return label.frame.size.height
    }
    
    
    /// 返回 NSMutableAttributedString
    ///
    /// - Parameters:
    ///   - string: String
    ///   - space: CGFloat
    /// - Returns: NSMutableAttributedString
    public static func returnNSMutableAttributedString(_ string:String, space:CGFloat) ->NSMutableAttributedString {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = space
        
        let attributeStr = NSMutableAttributedString(string: string, attributes: [NSAttributedStringKey.paragraphStyle : paragraph])
        
        return attributeStr
    }
    
    /// 获取阿拉伯数字对应的汉子小写数字
    ///
    /// - Parameter number: 数字
    /// - Returns: 汉子小写数字
    public static func getChineseNum(number: Int) -> String {
        var result = ""
        switch number {
        case 0:
            result = "零"
        case 1:
            result = "一"
        case 2:
            result = "二"
        case 3:
            result = "三"
        case 4:
            result = "四"
        case 5:
            result = "五"
        case 6:
            result = "六"
        case 7:
            result = "七"
        case 8:
            result = "八"
        case 9:
            result = "九"
        case 10:
            result = "十"
        default:
            result = ""
        }
        
        return result
    }
    
    /// 套餐（转化 “北舒套餐” 到对应的 Id 用于传给后台）
    ///
    /// - Parameter budget: String
    /// - Returns: String
    static func getPackageId(_ package:String)-> String{
        
        var packageId = ""
        switch package {
        case "北舒套餐":
            packageId = "1"
            break
        case "西镜套餐":
            packageId = "2"
            break
        case "南韵套餐":
            packageId = "3"
            break
        default:
            break
        }
        return packageId
    }
    
    /// 户型 （id，描述 转换相应的元组）
    ///
    /// - Parameter type: String
    /// - Returns: (id, 描述)
    static func getRoomType(_ text: String?)-> (id: String?, value: String?)? {
        
        var roomtype: (String?, String?)?
        
        if let txt = text {
            switch txt {
            case "零居", "L0B0":
                roomtype = ("L0B0", "零居")
                break
            case "一居一卫", "L1B1":
                roomtype = ("L1B1", "一居一卫")
                break
            case "二居二卫", "L2B2":
                roomtype = ("L2B2", "二居二卫")
                break
            case "二居一卫", "L2B1":
                roomtype = ("L2B1", "二居一卫")
                break
            case "三居一卫", "L3B1":
                roomtype = ("L3B1", "三居一卫")
                break
            case "三居二卫", "L3B2":
                roomtype = ("L3B2", "三居二卫")
                break
            case "四居二卫", "L4B2":
                roomtype = ("L4B2", "四居二卫")
                break
            default:
                break
            }
        }
        return roomtype
    }
    
    
    /// 房屋类型 （id，描述 转换相应的元组）
    ///
    /// - Parameter type: String
    /// - Returns: (id, 描述)
    static func getHouseType(_ text: String?) -> (id: String?, value: String?)? {
        
        var houseType: (String?, String?)?
        
        if let txt = text {
            switch txt {
            case "新房", "1":
                houseType = ("1", "新房")
                break
            case "老房", "0":
                houseType = ("0", "老房")
                break
            default:
                break
            }
        }
        return houseType
    }
    
    static func timestampToTimeStr(_ timestamp: String?) -> String? {
        var timeStr: String?
        if let times = timestamp, !times.isEmpty {
            let timeStamp = Int(times)
            let timeInterval: TimeInterval = TimeInterval(timeStamp ?? 0)
            let date = Date(timeIntervalSince1970: timeInterval / 1000)
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            dateformatter.timeZone = TimeZone(secondsFromGMT: 0)
            timeStr = dateformatter.string(from: date)
            //设置源日期时区
            let sourceTimeZone = TimeZone(abbreviation: "GMT")
            //设置转换后的目标日期时区
            let destinationTimeZone = TimeZone.current
            //得到源日期与世界标准时间的偏移量
            let sourceGMTOffset = sourceTimeZone?.secondsFromGMT(for: date) ?? 0
            //目标日期与本地时区的偏移量
            let destinationGMTOffset = destinationTimeZone.secondsFromGMT(for: date)
            //得到时间偏移量的差值
            let inerval = TimeInterval(destinationGMTOffset - sourceGMTOffset)
            //转为现在时间
            let destinationDateNow = Date(timeInterval: inerval, since: date)
            timeStr = dateformatter.string(from: destinationDateNow)
        }
        return timeStr
    }
    
    static func timeStrToTimestamp(_ timeStr: String?) -> String? {
        var timestamp: String?
        if let times = timeStr, !times.isEmpty {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let date = dateformatter.date(from: times)
            let dateStamp = date?.timeIntervalSince1970
            let time = Int(dateStamp ?? 0) * 1000
            timestamp = (dateStamp != nil) ? String(time) : nil
        }
        return timestamp
    }
    
}

extension ESStringUtil {
    public enum ESImageType {
        case HD
        case HD_WW
        case Large
        case Large_WW
    }
    
    public static func getAlyImage(_ type: ESImageType, _ url: String?) -> String {
        switch type {
        case .HD:
            return url ?? "" + "?x-oss-process=style/hd"
        case .HD_WW:
            return url ?? "" + "?x-oss-process=style/hd_ww"
        case .Large:
            return url ?? "" + "?x-oss-process=style/large"
        case .Large_WW:
            return url ?? "" + "?x-oss-process=style/large_ww"
        }
    }
}
