//
//  ESChargebackDetailSecondTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/26.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESChargebackDetailSecondTableViewCell: UITableViewCell {
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thridLabel: UILabel!
    @IBOutlet weak var frithLabel: UILabel!
    
    @IBOutlet weak var firstDot: UIView!
    @IBOutlet weak var secondDot: UIView!
    @IBOutlet weak var thridDot: UIView!
    @IBOutlet weak var frithDot: UIView!
    
    @IBOutlet weak var firstW: NSLayoutConstraint!
    @IBOutlet weak var firstH: NSLayoutConstraint!
    
    @IBOutlet weak var secondW: NSLayoutConstraint!
    @IBOutlet weak var secondH: NSLayoutConstraint!
    
    @IBOutlet weak var thirdW: NSLayoutConstraint!
    @IBOutlet weak var thirdH: NSLayoutConstraint!
    
    @IBOutlet weak var frithH: NSLayoutConstraint!
    @IBOutlet weak var frithW: NSLayoutConstraint!
    
    @IBOutlet weak var firstGap: NSLayoutConstraint!
    
    @IBOutlet weak var secondGap: NSLayoutConstraint!
    
    
    var titleLabel = UILabel()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        firstDot.layer.masksToBounds = true
        firstDot.layer.cornerRadius = 3
        
        secondDot.layer.masksToBounds = true
        secondDot.layer.cornerRadius = 3
        
        thridDot.layer.masksToBounds = true
        thridDot.layer.cornerRadius = 3
        
        frithDot.layer.masksToBounds = true
        frithDot.layer.cornerRadius = 3
      
        let gap = (ScreenWidth - 54 * 4 - 30) / 3
        
        firstGap.constant = gap
        secondGap.constant = gap
        
    }
    
    func setChargebackStatus(_ model:ESChargebackDetailsModel){
        
        let status = model.refundStatus ?? 10
        
        switch status {
        case 10:
            firstLabel.textColor = ESColor.color(sample: .buttonGreen)
            firstDot.backgroundColor =  ESColor.color(sample: .buttonGreen)
            firstW.constant = 10
            firstH.constant = 10
            firstDot.layer.cornerRadius = 5

            break
        case 20:
            secondLabel.textColor = ESColor.color(sample: .buttonGreen)
            secondDot.backgroundColor =  ESColor.color(sample: .buttonGreen)
            secondW.constant = 10
            secondH.constant = 10
            secondDot.layer.cornerRadius = 5

            break
        case 30:
            thridLabel.textColor = ESColor.color(sample: .buttonGreen)
            thridDot.backgroundColor =  ESColor.color(sample: .buttonGreen)
            thirdW.constant = 10
            thirdH.constant = 10
            thridDot.layer.cornerRadius = 5

            break
        case 40:
            frithLabel.textColor = ESColor.color(sample: .buttonGreen)
            frithDot.backgroundColor =  ESColor.color(sample: .buttonGreen)
            frithH.constant = 10
            frithW.constant = 10
            frithDot.layer.cornerRadius = 5
            
            break
        default:
            break
        }
    }
}
