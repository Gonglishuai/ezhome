//
//  ESDesProjectDetailHeader.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/27.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

protocol ESDesProjectDetailHeaderDelegate: NSObjectProtocol {
    
    /// 获取header相应的视觉模型
    ///
    /// - Parameters:
    ///   - index: 索引
    ///   - viewModel: 视觉模型
    func getModel(index: Int, viewModel: ESDesProjectDetailHeaderViewModel)
    
    /// 点击副标题
    ///
    /// - Parameter index: 索引
    func subTitleClick(index: Int)
}

class ESDesProjectDetailHeader: UITableViewHeaderFooterView {
    
    weak var delegate: ESDesProjectDetailHeaderDelegate?
    private var model = ESDesProjectDetailHeaderViewModel()
    private var index: Int = 0
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = ESColor.color(hexColor: 0xF9F9F9, alpha: 1.0)
        
        addViews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHeaderView(index: Int) {
        self.index = index
        delegate?.getModel(index: index, viewModel: model)
        
        titleLabel.text = model.title.text ?? ""
        titleLabel.textColor = model.title.color
        titleLabel.font = model.title.font
        
        subTitleLabel.isUserInteractionEnabled = model.subTitle.canClick
        subTitleLabel.text = model.subTitle.text ?? ""
        subTitleLabel.textColor = model.subTitle.color
        subTitleLabel.font = model.subTitle.font
    }
    
    @objc private func tapSubTitle(sender: UITapGestureRecognizer) {
        delegate?.subTitleClick(index: self.index)
    }
    
    private func addViews() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subTitleLabel)
    }
    
    private func setConstraint() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(23)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(21)
            make.width.greaterThanOrEqualTo(60)
            make.bottom.equalToSuperview().offset(-10).priority(800)
        }
        subTitleLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(30)
            make.width.greaterThanOrEqualTo(50)
            make.top.equalToSuperview().offset(18)
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESDesProjectDetailHeader.tapSubTitle(sender:)))
        label.addGestureRecognizer(tgr)
        return label
    }()
}
