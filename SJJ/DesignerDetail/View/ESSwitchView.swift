//
//  ESSwitchView.swift
//  EZHome
//
//  Created by shiyawei on 31/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

enum ESSwitchViewType {
    case planType
    case caseType
}

protocol ESSwitchViewDelegate {
    func didSelectedIndex(index:Int)
}

class ESSwitchView: UIView {

    var items = NSMutableArray()
    var type:ESSwitchViewType!
    
    var w = CGFloat()
    var delegate:ESSwitchViewDelegate?
    
    func setUIView() {
        
        items = ["效果图","3D案例"]
        w = ScreenWidth / CGFloat(items.count)
        var index = 0
       
        
        for item in items {
            
            let label = UILabel(frame: CGRect(x: (CGFloat(index) * w), y: 12, width: w, height: 21))
            label.textAlignment = NSTextAlignment.center
            label.font = UIFont.systemFont(ofSize: 15)
            label.text = item as? String
            self.addSubview(label)
            
            let subLabel = UILabel(frame: CGRect(x: (CGFloat(index) * w), y: 33, width: w, height: 17))
            subLabel.textAlignment = NSTextAlignment.center
            subLabel.font = UIFont.systemFont(ofSize: 15)
            subLabel.text = "(" + "**" + ")"
            subLabel.tag = 200 + index
            self.addSubview(subLabel)
            
            let btn = UIButton(frame: CGRect(x: (CGFloat(index) * w), y: 2, width: w, height: 56))
            btn.tag = 100 + index
            btn.addTarget(self, action: #selector(ESSwitchView.switchChanged(btn:)), for: .touchUpInside)
            
            self.addSubview(btn)
            index += 1
        }
        
//        let view = self.viewWithTag(100)
        
        self.addSubview(self.lineView)
        self.lineView.frame = CGRect(x: w / 4, y: 56, width: w / 2, height: 3)
        
    }
    
    //    MARK:publick
    func changeSliderFrame(index:Int)  {
        self.lineView.frame = CGRect(x: CGFloat(index) * w + w / 4, y: 56, width: w / 2, height: 3)
    }
    
    //刷新案例数字
    func resetCountLabel(type:ESSwitchViewType,count:String) {
        switch type {
        case .planType:
            let label = self.viewWithTag(200) as! UILabel
            label.text = "(\(count))"
        case .caseType:
            let label = self.viewWithTag(201) as! UILabel
            label.text = "(\(count))"
        default:
           return
        }
        
    }
    
    //    MARK:private
    @objc func switchChanged(btn:UIButton) {
        let index = btn.tag - 100

//        changeSliderFrame(index: index)
        delegate?.didSelectedIndex(index: index)

    }
    
    //    MARK:懒加载
    lazy var selectedView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.stec_lightBlueText()
        return view
    }()
    
    lazy var lineView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.stec_lightBlueText()
        view.layer.cornerRadius = 1.5
        view.layer.masksToBounds = true
        return view
    }()
    


}
