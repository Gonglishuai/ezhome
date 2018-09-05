//
//  ESGathringSectionFooterView.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESGathringSectionFooterView: UITableViewHeaderFooterView {

    lazy var dateLabel: UILabel = {
        var label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColor)
        label.font = ESFont.font(name: ESFont.ESFontName.medium, size: 12)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let backView = UIView()
        backView.backgroundColor = ESColor.color(sample: .backgroundView)
        
        backgroundView = backView
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.top.equalTo(6)
            make.size.equalTo(CGSize(width: 200, height: 17))
        }
    }
   
    
    func setDateLabel(model:ESGatheringDetailsSubSubModel, role:ESRole){
        switch role {
        case .designer:
            dateLabel.text = "\(model.createDate ?? "--") 发起"
            break
        case .proprietor(action: _, agreeContract: _, entry: _):
            dateLabel.text = "设计师发起 \(model.createDate ?? "--")"
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
