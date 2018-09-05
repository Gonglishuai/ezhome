//
//  ESGatheringCouponTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESGatheringCouponTableViewCell: UITableViewCell {

    @IBOutlet weak var rightCostLabel: UILabel!
    @IBOutlet weak var leftCostLabel: UILabel!
    
    @IBOutlet weak var returnNumberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showCoupon(tableView:UITableView, model:ESGatheringDetailsSubSubModel) {
        
        returnNumberLabel.isHidden = true

        if let amount = model.discountAmount,amount > 0.0 {
            rightCostLabel.text = String(format: "￥%.2f", amount)
        } else {
            rightCostLabel.text = "--"
        }

        let coupon = model.discountNames ?? []
        
        var maxY:CGFloat = 44
        
        for i in 0..<coupon.count {
            
            let button = customButton(titlte: coupon[i])
            self.contentView.addSubview(button)
            let buttonH = button.frame.size.height - 5
            let buttonW = button.frame.size.width + 20
            
            button.frame = CGRect(x: 0, y: maxY + (buttonH) * CGFloat(i) , width: buttonW, height: buttonH)

            var frame1 = button.frame
            frame1.origin.x = ScreenWidth - 30 - buttonW
            button.frame = frame1
            
            setButtonlayer(button: button)
            
            maxY = button.frame.maxY
        }
        
        let line = UIView()
        self.contentView.addSubview(line)
        line.backgroundColor = ESColor.color(sample: .separatorLine)
        line.frame = CGRect(x: 30, y: maxY + 17, width: ScreenWidth - 60, height: 0.5)
        
        tableView.rowHeight = line.frame.maxY + 0.5
    }
    
    
    func showManJian(tableView:UITableView, model:ESGatheringDetailsSubSubModel) {
        leftCostLabel.text = "返现金额"
        
        if let cashBackAmount  =  model.cashBackAmount,cashBackAmount > 0.0 {
            returnNumberLabel.isHidden = false
            rightCostLabel.text = String(format: "￥%.2f", cashBackAmount)
        } else {
            returnNumberLabel.isHidden = true
            rightCostLabel.text = "--"
        }
        
        let coupon = model.cashBackNames ?? []//["满20000，返现1000"]

        var maxY:CGFloat = 44
        for i in 0..<coupon.count {
            
            let button = customButton(titlte: coupon[i])
            self.contentView.addSubview(button)
            let buttonH = button.frame.size.height - 5
            let buttonW = button.frame.size.width + 20
            
            button.frame = CGRect(x: 0, y: maxY + (buttonH) * CGFloat(i) , width: buttonW, height: buttonH)
            
            var frame1 = button.frame
            frame1.origin.x = ScreenWidth - 30 - buttonW
            button.frame = frame1
            
            setButtonlayer(button: button)
            
            maxY = button.frame.maxY
        }
        
        let line = UIView()
        self.contentView.addSubview(line)
        line.backgroundColor = ESColor.color(sample: .separatorLine)
        line.frame = CGRect(x: 30, y: maxY + 17, width: ScreenWidth - 60, height: 0.5)
        
        tableView.rowHeight = line.frame.maxY + 0.5
    }
    
    private func customButton(titlte:String)->UIButton {
        
        let button  = UIButton()
        button.setTitleColor(ESColor.color(sample: ESColorSample.buttonRed), for: .normal)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 10)
        button.setTitle(titlte, for: .normal)
        
        button.sizeToFit()
        
        return button
    }
    
    func setButtonlayer(button:UIButton){
        button.layer.masksToBounds = true
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 2
        button.layer.borderColor = ESColor.color(sample: .buttonRed).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
