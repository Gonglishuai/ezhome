//
//  ESCaseTableViewCell.swift
//  EZHome
//
//  Created by shiyawei on 1/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESCaseTableViewCell: UITableViewCell {
    @IBOutlet weak var backImgView: UIImageView!
    ///点赞数量
    @IBOutlet weak var spotCount: UILabel!
    ///评论
    @IBOutlet weak var commentCount: UILabel!
    ///标题
    @IBOutlet weak var titleLabel: UILabel!
    ///副标题
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var centerLabel: UILabel!
    
    @IBOutlet weak var balckBakcView: UIView!
//    var _isShowCenterLabel = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        centerLabel.layer.cornerRadius = centerLabel.frame.size.height / 2
        centerLabel.backgroundColor = ESColor.color(hexColor: 0x000000, alpha: 0.5)
//        centerLabel.clipsToBounds = true
        
        ///渐变色
        let topColor = ESColor.color(hexColor: 0x000000, alpha: 0)
        let bottomColor = ESColor.color(hexColor: 0x000000, alpha: 1)
        let gradientColors = [topColor.cgColor, bottomColor.cgColor]
        //创建CAGradientLayer对象并设置参数
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)

        gradientLayer.frame = balckBakcView.bounds
        balckBakcView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.commentCount.isHidden = true
    }

   //数据解析
    func analysisListModel(model:ESDesignCaseList) {
        self.titleLabel.text = model.designName
        
        if let urlStr = model.designCover {
            let url = NSURL.init(string: urlStr)
            self.backImgView.sd_setImage(with: url! as URL)
        }
        
        
        
        self.spotCount.text = model.favoriteCount
        
        self.subTitleLabel.text = "\(model.style ?? "") \(model.roomType ?? "") \(model.area ?? "")"
        
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
