//
//  ESChargebackDetalFourthTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/26.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESChargebackDetalFourthTableViewCell: UITableViewCell {
    
    var reasonLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(self.titleView)
        
        contentView.addSubview(reasonLabel)
        reasonLabel.textColor = ESColor.color(sample: .mainTitleColor)
        reasonLabel.font = ESFont.font(name: .regular, size: 13)
        reasonLabel.numberOfLines = 0
        
        reasonLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView.snp.left).offset(16)
            make.top.equalTo(self.titleView.snp.bottom).offset(15)
            make.right.equalTo(contentView.snp.right).offset(-16)
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
        }
    }
    
    func setCellElementModel(_ model:ESChargebackDetailsModel){
        reasonLabel.attributedText = ESStringUtil.returnNSMutableAttributedString(model.remark ?? "--", space: 5)
       
    }
    
    
    func setCellModel(_ model:ESOfferDetailModel){
        reasonLabel.attributedText = ESStringUtil.returnNSMutableAttributedString(model.remark ?? "--", space: 5)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    //MARK:lazy
    lazy var titleView:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 40))
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: ScreenWidth, height: 40))
        label.text = "退款原因"
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = ESFont.font(name: ESFont.ESFontName.regular, size: 13)
        
        view.addSubview(label)
        
        return view
        
    }()
    
}
