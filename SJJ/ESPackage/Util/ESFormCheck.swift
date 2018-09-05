//
//  ESFormCheck.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/14.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public class ESFormCheck: NSObject {
    
    /// 校验是否为手机号
    ///
    /// - Parameter phone: 手机号
    /// - Returns: 结果
    static func isPhoneNum(_ phone: String?) -> Bool {
        let cjr = "^1\\d{10}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", cjr)
        if predicate.evaluate(with: phone) {
            return true
        }
        return false
    }
    
    
    ///限制房屋面积的输入
    static func checkHouseSizeForm(textField: UITextField, range: NSRange, string: String)->Bool {
        
        let originText : NSString = textField.text as NSString? ?? ""
        
        let resultText = originText.replacingCharacters(in: range, with: string)
        
        
        if resultText.count > 7 && resultText.count > originText.length {//限制位数 7位
            return false
        }
        
        if originText == "",string == "." {//第一个不让输入 ‘.’
            textField.text = "0."
            return false
        }
        if originText == "0", string != "." {//输入第一个数为'0'的话，下一个数只能为'.'
            if string.isEmpty {
                return true
            }
            return false
        }
        if originText.contains("."), string == "."{//不能输入两个点
            return false
        }
        
        if resultText.count > 4, Double(resultText)! > 9999.99{//最大 9999.99
            return false
        }
        
        if resultText.contains(".") { // 小数点后最多能输入两位
            
            let ran = originText.range(of: ".")
            
            if range.location > ran.location {
                if originText.pathExtension.count > 1, string != "" {
                    return false
                }
            }
        }
        return true
    }
    
    ///修改输入的房屋面积
    static func fixInputedHouseSize(text:String) -> String {
        
        if text != "", Float(text) == 0.0 {
            return ""
        }
        
        var houseSize:NSString = NSString(string: text)
        
        if houseSize.contains(".00") {
            houseSize = "\(houseSize.integerValue)" as NSString
            return houseSize as String
        }
        
        if houseSize.hasSuffix(".0") {
            houseSize = "\(houseSize.integerValue)" as NSString
        }
        
        return houseSize as String
    }
}
