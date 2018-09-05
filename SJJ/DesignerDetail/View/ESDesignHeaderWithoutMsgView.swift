//
//  ESDesignHeaderWithoutMsgView.swift
//  EZHome
//
//  Created by shiyawei on 1/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESDesignHeaderWithoutMsgViewDelegate {
    ///预约事件
    func makeAppointAction()
    ///在线联系
    func contactOnlineAction()
}

class ESDesignHeaderWithoutMsgView: UIView {

    @IBOutlet weak var headerImgView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var contactBtn: UIButton!
    
    @IBOutlet weak var appointmentBtn: UIButton!
    
    @IBOutlet weak var contactRightWidth: NSLayoutConstraint!
    var delegate:ESDesignHeaderWithoutMsgViewDelegate!
    
    func loadView() {
        
        self.headerImgView.layer.masksToBounds = true
        self.headerImgView.layer.cornerRadius = 28.5
        
        self.contactBtn.layer.cornerRadius = 4
        self.contactBtn.layer.borderWidth = 1
        self.contactBtn.layer.borderColor = (UIColor.stec_lightBlueText()).cgColor
        self.contactBtn.layer.masksToBounds = true;
        
        self.appointmentBtn.layer.masksToBounds = true;
        self.appointmentBtn.layer.cornerRadius = 4
        
        let role = JRKeychain.loadSingleUserInfo(.type) as String
        
        if role == "designer"  {
            self.appointmentBtn.isHidden = true
            
            self.contactRightWidth.constant = 20
        }
    }
    
    func analysisUserModel(model:ESDesignerInfoModel) {
        self.nameLabel.text = model.nickName
        if let imgUrl = model.avatar {
            let url = NSURL.init(string: imgUrl)
            self.headerImgView.sd_setImage(with: url! as URL)
        }
        if model.isRealName == "2" {
            self.typeLabel.isHidden = false
        }else {
            self.typeLabel.isHidden = true
        }
    }
    
    //在线沟通事件
    @IBAction func contactAction(_ sender: UIButton) {
        self.delegate.contactOnlineAction()
    }
    
    //立即预约事件
    @IBAction func appointmentAction(_ sender: UIButton) {
        self.delegate.makeAppointAction()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
