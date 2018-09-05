//
//  ESERPMatchEmptyCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESERPMatchEmptyCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.white
        
        addSubviews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        self.contentView.addSubview(alertLabel)
    }
    
    private func setConstraint() {
        alertLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80)
            make.bottom.equalToSuperview().offset(-80)
            make.height.equalTo(21)
            make.centerX.equalToSuperview()
        }
    }
    
    lazy var alertLabel: UILabel = {
        let label = UILabel()
        label.text = "暂未查询到ERP项目"
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: .regular, size: 15.0)
        return label
    }()
}
