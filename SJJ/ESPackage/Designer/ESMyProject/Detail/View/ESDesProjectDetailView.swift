//
//  ESDesProjectDetailView.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit

protocol ESDesProjectDetailViewDelegate: ESTableViewProtocol {
    func matchERPBtnClick()
    func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell?
}

class ESDesProjectDetailView: UIView, UITableViewDelegate, UITableViewDataSource {

    private weak var delegate: ESDesProjectDetailViewDelegate?
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = ESColor.color(hexColor: 0xF9F9F9, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ESDesProjectDetailHeader.self, forHeaderFooterViewReuseIdentifier: "ESDesProjectDetailHeader")
        tableView.register(ESDesProjectOrderDetailCell.self, forCellReuseIdentifier: "ESDesProjectOrderDetailCell")
        tableView.register(ESDesProjectCostInfoCell.self, forCellReuseIdentifier: "ESDesProjectCostInfoCell")
        tableView.register(ESDesProjectContractCell.self, forCellReuseIdentifier: "ESDesProjectContractCell")
        tableView.register(ESDesProjectPreviewCell.self, forCellReuseIdentifier: "ESDesProjectPreviewCell")
        tableView.register(ESDesProjectQuoteInfoCell.self, forCellReuseIdentifier: "ESDesProjectQuoteInfoCell")
        tableView.register(ESDesProjectDeliveryInfoCell.self, forCellReuseIdentifier: "ESDesProjectDeliveryInfoCell")
//        tableView.estimatedRowHeight = 200.0
        tableView.estimatedSectionHeaderHeight = 54
//        tableView.estimatedSectionFooterHeight = 0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private var tableViewBottom: Constraint?
    
    init(delegate: ESDesProjectDetailViewDelegate?) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
        setUpTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpTableView() {
        self.addSubview(matchBtn)
        self.addSubview(tableView)
        self.addSubview(bottomAlertView)
        
        matchBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            let height = CGFloat(49)
            make.height.equalTo(height.scalValue)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            self.tableViewBottom = make.bottom.equalToSuperview().constraint
        }
        bottomAlertView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
        }
        bottomAlertLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(38)
            make.bottom.equalToSuperview().priority(800)
        }
    }
    
    func updateView(matchERP: Bool, bottomAlert: (Bool, String?)) {
        let height = CGFloat(49)
        let bottom = matchERP ? -height.scalValue : 0
        self.tableViewBottom?.update(offset: bottom)
        bottomAlertView.isHidden = !bottomAlert.0
        bottomAlertLabel.text = bottomAlert.1
        tableView.reloadData()
    }
    
    @objc private func matchBtnClick(sender: UIButton) {
        delegate?.matchERPBtnClick()
    }
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate?.getSectionNum!() ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getItemNum(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = delegate?.getCell(tableView: tableView, indexPath: indexPath)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 480.0
        } else {
            return 200.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectItem?(index: indexPath.row, section: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let num = delegate?.getSectionNum!() {
            if num == section + 1 {
                return 80.0
            }
            return 0.1
        }
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESDesProjectDetailHeader") as! ESDesProjectDetailHeader
        header.delegate = delegate as? ESDesProjectDetailHeaderDelegate
        header.updateHeaderView(index: section)
        return header
    }
    
    private lazy var matchBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setTitle("关联ERP项目", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        let normal = ESColor.getImage(color: ESColor.color(sample: .buttonBlue))
        let disabled = ESColor.getImage(color: ESColor.color(sample: .separatorLine))
        button.setBackgroundImage(normal, for: .normal)
        button.setBackgroundImage(normal, for: .highlighted)
        button.setBackgroundImage(disabled, for: .disabled)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.addTarget(self, action: #selector(ESDesProjectDetailView.matchBtnClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomAlertView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xFFF5E5, alpha: 1.0)
        view.isHidden = true
        view.addSubview(bottomAlertLabel)
        return view
    }()
    
    private lazy var bottomAlertLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
        label.font = ESFont.font(name: .regular, size: 12.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
}
