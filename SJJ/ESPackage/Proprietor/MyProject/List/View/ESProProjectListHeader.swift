//
//  ESProProjectListHeader.swift
//  Consumer
//
//  Created by Jiao on 2018/1/7.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProProjectListHeaderDelegate: NSObjectProtocol {
    
    func getModel(index: Int, viewModel: ESESProProjectListHeaderViewModel)
}

class ESProProjectListHeader: UITableViewHeaderFooterView {

    weak var delegate: ESProProjectListHeaderDelegate?
    private var model = ESESProProjectListHeaderViewModel()
    

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = ESColor.color(sample: .backgroundView)
        
        addViews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHeaderView(index: Int) {
        delegate?.getModel(index: index, viewModel: model)
        projectIdLabel.text = "项目编号: \(model.projectId ?? "--")"
        timeLabel.text = "预约时间: \(model.publishTime ?? "--")"
    }
    
    private func addViews() {
        contentView.addSubview(backView)
    }
    
    private func setConstraint() {
        backView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1).priority(800)
            make.height.equalTo(46.5)
        }
        projectIdLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(16.5)
            make.centerY.equalToSuperview()
        }
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(16.5)
            make.centerY.equalToSuperview()
        }
    }
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(projectIdLabel)
        view.addSubview(timeLabel)
        return view
    }()
    
    private lazy var projectIdLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.textAlignment = .right
        return label
    }()
}
