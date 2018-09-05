//
//  ESSelectButtonTableViewCell.swift
//  Consumer
//
//  Created by jiang on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESSelectButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    fileprivate var tapBlock: ((_ location: String) -> Void)?
    @IBOutlet weak var lineLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lineLabel.backgroundColor = UIColor.stec_lineGray()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setBlock(weekend: Bool, block:((_ location: String) -> Void)?) {
        if weekend {
            leftButtonClicked(UIButton())
        } else {
            rightButtonClicked(UIButton())
        }
        self.tapBlock = block;
    }
    
    @IBAction func leftButtonClicked(_ sender: UIButton) {
        self.leftButton.titleLabel?.textColor = UIColor.stec_titleText()
        self.leftButton.setImage(UIImage.init(named: "erp_btn_sel"), for: UIControlState.normal)
        self.rightButton.titleLabel?.textColor = UIColor.stec_subTitleText()
        self.rightButton.setImage(UIImage.init(named: "erp_btn"), for: UIControlState.normal)
        if (tapBlock != nil) {
            tapBlock!("left")
        }
    }
    
    @IBAction func rightButtonClicked(_ sender: UIButton) {
        self.rightButton.titleLabel?.textColor = UIColor.stec_titleText()
        self.rightButton.setImage(UIImage.init(named: "erp_btn_sel"), for: UIControlState.normal)
        self.leftButton.titleLabel?.textColor = UIColor.stec_subTitleText()
        self.leftButton.setImage(UIImage.init(named: "erp_btn"), for: UIControlState.normal)
        if (tapBlock != nil) {
            tapBlock!("right")
        }
    }
}
