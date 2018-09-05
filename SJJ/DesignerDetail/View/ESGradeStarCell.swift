 //
//  ESGradeStarCell.swift
//  EZHome
//
//  Created by shiyawei on 1/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESGradeStarCell: UITableViewCell {
    @IBOutlet weak var totalScoreLabel: UILabel!
    ///专业度
    @IBOutlet weak var specialtyLabel: UILabel!
    @IBOutlet weak var specialtyStarView: ESEvaluateStarView!
    ///满意度
    @IBOutlet weak var satisfactionLabel: UILabel!
    @IBOutlet weak var satisfactionStarView: ESEvaluateStarView!
    ///交付时效
    @IBOutlet weak var workpieceLabel: UILabel!
    @IBOutlet weak var workpieceStarView: ESEvaluateStarView!
    
    
    @IBOutlet weak var tagsView: ESCollectionView!
    
    var datas = Array<String>()
    var counts = Array<String>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

    func analysisUserModel(model:ESGradeListModel) {
        
        if let score = model.avgCommentScore {
            self.totalScoreLabel.text = "业主评分 " + score
        }
        
        if let count =  model.avgProfession {
            specialtyStarView.createStar(count: count)

        }
        if let AttitudeCount =  model.avgAttitude{

            satisfactionStarView.createStar(count: AttitudeCount)

        }
        if let PunctCount =  model.avgPunctuality {

            workpieceStarView.createStar(count: PunctCount)
        }
        if let arr = model.commentTags {
            for model:CommentTagCountRespBean in arr {
                self.datas.append(model.name!)
                self.counts.append("\((model.count)!)")
            }
            
            self.tagsView.setDatas(self.datas, counts: self.counts)
        }else {
            self.tagsView.isHidden = true
        }
        
        
    }
    
    static func getHeight(model:ESGradeModel) -> CGFloat {
        var count = 0
        if let arr = model.data?.commentTags  {
            count = arr.count / 3
        }        
        
        
        return 150 + CGFloat((count + 1) * 30)
    }


}
