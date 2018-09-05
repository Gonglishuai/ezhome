//
//  ESProProjectDetailFooter.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/11.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit

protocol ESProProjectDetailFooterDelegate: NSObjectProtocol {
    func getFooterText() -> String?
    /// 点击申请退单
    func applyReturn()
}

class ESProProjectDetailFooter: UITableViewHeaderFooterView {
    weak var delegate: ESProProjectDetailFooterDelegate?
    private var height: Constraint?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = ESColor.color(sample: .backgroundView)
        
        addViews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFooterView(index: Int, last: Bool) {
        titleLabel.isHidden = !last
        titleLabel.text = delegate?.getFooterText()
        
        var h = 1.0
        if last {
            h = delegate?.getFooterText() == nil ? 49.0 : 70.5
        }
        height?.update(offset: h)
    }
    
    @objc private func tapText() {
        delegate?.applyReturn()
    }
    
    private func addViews() {
        contentView.addSubview(backView)
        backView.addSubview(titleLabel)
    }
    
    private func setConstraint() {
        backView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().priority(800)
            self.height = make.height.equalTo(0.1).constraint
        }
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalTo(150)
            make.bottom.equalToSuperview().offset(-15)
            make.centerX.equalToSuperview()
        }
    }
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .buttonBlue)
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESProProjectDetailFooter.tapText))
        label.addGestureRecognizer(tgr)
        return label
    }()

}
