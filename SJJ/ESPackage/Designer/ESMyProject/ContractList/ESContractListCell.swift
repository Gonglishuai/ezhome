//
//  ESContractListCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESContractListCell: UITableViewCell {
    
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

    func updateCell(text: String?) {
        titleLabel.text = text
    }
    
    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(imgView)
    }
    
    private func setConstraint() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().priority(800)
            make.height.equalTo(55)
            make.right.equalTo(imgView.snp.left).offset(-15)
        }
        imgView.snp.makeConstraints { (make) in
            make.width.equalTo(5)
            make.height.equalTo(10)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 14.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    private lazy var imgView: UIImageView = {
        let view = UIImageView()
        view.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return view
    }()
}
