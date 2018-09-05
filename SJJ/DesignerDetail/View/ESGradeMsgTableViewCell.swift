//
//  ESGradeMsgTableViewCell.swift
//  EZHome
//
//  Created by shiyawei on 1/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESGradeMsgTableViewCell: UITableViewCell {

    @IBOutlet weak var headImgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var homeLabel: UILabel!
    
    @IBOutlet weak var tagsView: ESCollectionView!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func analysisUserModel(model:CommentInfoRespBean) {
        self.nameLabel.text = model.customerName
        self.detailLabel.text = model.comment
        self.homeLabel.text = model.community
        
        let detailLabelH = ESGradeMsgTableViewCell.calculateHeight(text: model.comment! as NSString, font: self.detailLabel.font)
        self.homeLabel.frame = CGRect(x: self.homeLabel.frame.origin.x, y: self.homeLabel.frame.origin.y, width: self.homeLabel.frame.size.width, height: detailLabelH)
        
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="yyyy-MM-dd"
        let date = NSDate(timeIntervalSince1970: TimeInterval(model.createDate! / 1000))
        self.timeLabel.text = dfmatter.string(from: date as Date)
        
        if let arr = model.tags {
            self.tagsView.datas = arr
        }else {
            self.tagsView.isHidden = true
            self.tagsView.frame = CGRect.zero
        }
        
    }
    
    static func calculateHeight(text:NSString,font:UIFont) -> CGFloat {
        let maxSize = CGSize(width: ScreenWidth - 40, height: 1000)
        let size = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin , attributes: [NSAttributedStringKey.font: font], context: nil).size
        return size.height
    }
    
    static func getHeight(model:CommentInfoRespBean) -> CGFloat {
        
        let maxSize = CGSize(width: ScreenWidth - 40, height: 1000)
        let str = model.comment! as NSString
        let font = UIFont.systemFont(ofSize: 15)
        let size = str.boundingRect(with: maxSize, options: .usesLineFragmentOrigin , attributes: [NSAttributedStringKey.font: font], context: nil).size
        let count = (model.tags?.count)! / 3
        let countH = (count + 1) * 30
        return 116 + size.height + CGFloat(countH)
    }
    
}
