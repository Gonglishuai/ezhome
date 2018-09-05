//
//  ESProProjectListFooter.swift
//  Consumer
//
//  Created by Jiao on 2018/1/7.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProProjectListFooterDelegate: NSObjectProtocol {
    func projectDetailClick(index: Int)
}
class ESProProjectListFooter: UITableViewHeaderFooterView {

    weak var delegate: ESProProjectListFooterDelegate?    
    private var index: Int = 0
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = ESColor.color(sample: .backgroundView)
        
        addViews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFooterView(index: Int) {
        self.index = index
    }
    
    @objc func detailLabelTap() {
        delegate?.projectDetailClick(index: index)
    }
    
    private func addViews() {
        contentView.addSubview(backView)
    }
    
    private func setConstraint() {
        backView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0.5)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().priority(800)
            make.height.equalTo(48.5)
        }
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(detailLabel)
        return view
    }()
    
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 14.0)
        label.textColor = ESColor.color(sample: .buttonBlue)
        label.text = "查看项目详情"
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESProProjectListFooter.detailLabelTap))
        label.addGestureRecognizer(tgr)
        return label
    }()
}
