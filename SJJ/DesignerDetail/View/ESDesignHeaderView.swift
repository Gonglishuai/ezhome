//
//  ESDesignHeaderView.swift
//  EZHome
//
//  Created by shiyawei on 31/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESDesignHeaderViewDelegate {
    func attentionAction()
    func chatOnlineAction()
    func makeAppointmentAction()
}

class ESDesignHeaderView: UIView {

    @IBOutlet weak var headerImgView: UIImageView!
    ///资深
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoBackView: UIView!
    ///经验
    @IBOutlet weak var experienceLabel: UILabel!
    ///关注数
    @IBOutlet weak var attentionLabel: UILabel!
    ///设计费
    @IBOutlet weak var designFeeLabel: UILabel!
    ///量房费
    @IBOutlet weak var quantityFeeLabel: UILabel!
    ///关注
    @IBOutlet weak var attentionBtn: UIButton!
    @IBOutlet weak var btnBackView: UIView!
    ///在线沟通
    @IBOutlet weak var contactBtn: UIButton!
    ///立即预约
    @IBOutlet weak var appointmentBtn: UIButton!
    
    @IBOutlet weak var contactRifhtContrsint: NSLayoutConstraint!
    
    private var attationCount:String?
    
    
    var delegate:ESDesignHeaderViewDelegate?
    
    //var userModel = ESDesignerInfoModel()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.headerImgView.layer.masksToBounds = true
        self.headerImgView.layer.cornerRadius = 28.5
        
        self.contactBtn.layer.cornerRadius = 4
        self.contactBtn.layer.borderWidth = 1
        self.contactBtn.layer.borderColor = (UIColor.stec_lightBlueText()).cgColor
        self.contactBtn.layer.masksToBounds = true;
        
        self.appointmentBtn.layer.masksToBounds = true;
        self.appointmentBtn.layer.cornerRadius = 4
        
        self.attentionBtn.layer.borderWidth = 1;
        self.attentionBtn.layer.borderColor = (UIColor.stec_lightBlueText()).cgColor
        self.attentionBtn.layer.cornerRadius = 4
        self.attentionBtn.layer.masksToBounds = true;
        
        
        let role = JRKeychain.loadSingleUserInfo(.type) as String
        
        if role == "designer"  {
            self.appointmentBtn.isHidden = true

            self.contactRifhtContrsint.constant = 0
        }
        
        
    }
    //MARK:关注
    func addAttioned() {
        attentionBtn.setTitle("取消关注", for: .normal)
        attentionBtn.setTitleColor(UIColor.stec_lightBlueText(), for: .normal)
        attentionBtn.backgroundColor = UIColor.stec_whiteText()
        
        if let attationCount = self.attationCount  {
            let count = Int(attationCount)! + 1
            self.attationCount = "\(count)"
            let attentionA = self.attrbutstring(differentStr: "\(count)", totalStr: "关注 " + "\(count)") as NSAttributedString
            self.attentionLabel.attributedText = attentionA
        }
        
    }
    //    MARK;取消关注
    func cancelAttioned() {
        attentionBtn.setTitle("+ 关注", for: .normal)
        attentionBtn.setTitleColor(UIColor.stec_whiteText(), for: .normal)
        attentionBtn.backgroundColor = UIColor.stec_lightBlueText()
        if let attationCount = self.attationCount  {
            let count = Int(attationCount)! - 1
            self.attationCount = "\(count)"
            let attentionA = self.attrbutstring(differentStr: "\(count)", totalStr: "关注 " + "\(count)") as NSAttributedString
            self.attentionLabel.attributedText = attentionA
        }
    }
    
  ///解析设计师数据
    func analysisUserModel(model:ESDesignerInfoModel) {
        
        
        
        if let imgUrl = model.avatar {
            let url = NSURL.init(string: imgUrl)
            self.headerImgView.sd_setImage(with: url! as URL)
        }
        
        self.nameLabel.text = model.nickName
        if ESLoginManager.shared().isLogin {
            if model.isFollowing == "0"{
                self.cancelAttioned()
            } else {
                self.addAttioned()
            }
        }else {
            self.addAttioned()
        }
        
        if model.isRealName == "2" {
            self.typeLabel.isHidden = false
        }else {
            self.typeLabel.isHidden = true
        }
        
        self.attationCount = model.follows
        if let count = model.follows {
            
            let attentionA = self.attrbutstring(differentStr: count, totalStr: "关注 " + count) as NSAttributedString
            self.attentionLabel.attributedText = attentionA
        }
        
        if model.experience == nil || model.experience.count == 0 {
            
//            self.experienceLabel.text = nil
            self.experienceLabel.isHidden = true
            var rect = self.attentionLabel.frame
            rect.origin.x = 0
            self.attentionLabel.frame = rect
            
        }else {
            let experStrA = self.attrbutstring(differentStr: model.experience, totalStr: model.experience + " 年经验") as NSAttributedString
            self.experienceLabel.attributedText = experStrA
        }
        
        
        
        if model.measurementPrice == nil || model.measurementPrice.count == 0 {
            self.quantityFeeLabel.text = "量房费：尚未填写"
        }else {
            self.quantityFeeLabel.text = "量房费：" + model.measurementPrice + "元"
        }
        
        if model.designPriceMin == nil || model.designPriceMin.count == 0 || model.designPriceMax == nil || model.designPriceMax.count == 0 {
            self.designFeeLabel.text = "设计费：尚未填写"
        }else {
            if let princeMin = model.designPriceMin,let priceMax = model.designPriceMax  {
                self.designFeeLabel.text = "设计费：\(princeMin)~\(priceMax)元/m²"
            }
        }
        
    }
    
    
    
    
    ///关注事件
    @IBAction func attentionAction(_ sender: UIButton) {
        delegate?.attentionAction()
    }
    ///在线沟通
    @IBAction func chatOnlineAction(_ sender: UIButton) {
        delegate?.chatOnlineAction()
    }
    ///立即预约
    @IBAction func makeAppointmentAction(_ sender: UIButton) {
        delegate?.makeAppointmentAction()
    }
    
    
    
    func attrbutstring(differentStr:String,totalStr:String) -> NSAttributedString {
        let attrstring:NSMutableAttributedString = NSMutableAttributedString(string:totalStr)
        
        let totalS = totalStr as NSString
        let location = totalS.range(of: differentStr).location as Int
        
        attrstring.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], range: NSRange.init(location: location, length: differentStr.count))
        
        return attrstring
    }
   

}
