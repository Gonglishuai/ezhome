//
//  ESDesignOtherMsgView.swift
//  EZHome
//
//  Created by shiyawei on 31/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESDesignOtherMsgViewDelegate {
    func showGradeDetailView()
}

class ESDesignOtherMsgView: UIView {

    @IBOutlet weak var controlStyleLabel: UILabel!
    ///评分
    @IBOutlet weak var gradeLabel: UILabel!
    ///参与评分人数
    @IBOutlet weak var gradeCountBtn: UIButton!
    @IBOutlet weak var rightImgViewIcon: UIImageView!
    
    @IBOutlet weak var headIconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    ///评价内容
    @IBOutlet weak var gradeDetailLabel: UILabel!
    @IBOutlet weak var evaluateView: UIView!
    
    var delegate : ESDesignOtherMsgViewDelegate?
    
    ///进入评分详情
    @IBAction func showGradeDetail(_ sender: UIButton) {
        delegate?.showGradeDetailView()
    }
    
    //    MARK:解析设计师数据
    func analysisUserModel(model:ESDesignerInfoModel) {
        
        var attrText = self.attrbutstring(differentStr: "擅长风格:", totalStr: "擅长风格:" + model.styleNames, color: UIColor.stec_tabbarNormalText())
        if model.styleNames == nil || model.styleNames.count == 0 {
            attrText = self.attrbutstring(differentStr: "擅长风格:", totalStr: "擅长风格:未设置", color: UIColor.stec_tabbarNormalText())
        }
        self.controlStyleLabel.attributedText = attrText
        
        
        
    }
    //    MARK:解析评论数据
    func analysiEvaluateModel(model:ESGradeModel) {
        self.gradeLabel.text = "业主评分：暂无"
        self.gradeCountBtn.setTitle("0人评价", for: .normal)
        self.gradeCountBtn.isUserInteractionEnabled = false
        if (model.paging?.total)! > 0 {
            self.gradeCountBtn.isUserInteractionEnabled = true
            self.gradeLabel.text = "业主评分：" + model.data!.avgCommentScore!
            self.gradeCountBtn.setTitle("\((model.paging!.total)!)人经评价", for: .normal)
            self.evaluateView.isHidden = false
            
            let data = model.data!.comments
            let evaluateInfo = data?.first as! CommentInfoRespBean
            
            let url = URL.init(string: evaluateInfo.customerImage!)
            
            self.headIconView.sd_setImage(with: url, placeholderImage: UIImage(named: "headerDeafult"))
            self.nameLabel.text = evaluateInfo.customerName
            self.gradeDetailLabel.text = evaluateInfo.comment
            
        }else {
            self.rightImgViewIcon.isHidden = true
            self.evaluateView.isHidden = true
            return
        }
        
        
    }
    
    func attrbutstring(differentStr:String,totalStr:String,color:UIColor) -> NSAttributedString {
        let attrstring:NSMutableAttributedString = NSMutableAttributedString(string:totalStr)
        
        let totalS = totalStr as NSString
        let location = totalS.range(of: differentStr).location as Int
        
        attrstring.addAttributes([NSAttributedStringKey.foregroundColor: color], range: NSRange.init(location: location, length: differentStr.count))
        
        return attrstring
    }
    
    static func getHeight(datas:Array<CommentInfoRespBean>) -> CGFloat {
        if datas.count == 0{
            return 92
        }
        return 180
    }
    
}
