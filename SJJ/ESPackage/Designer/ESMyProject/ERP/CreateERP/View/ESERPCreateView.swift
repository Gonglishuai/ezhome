//
//  ESERPCreateView.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESERPCreateViewDelegate: ESTableViewProtocol {
    func confirmButtonClick()
    func confirmEnabled() -> Bool
    func didSelectedItem(_ index: Int)
}

class ESERPCreateView: UIView, UITableViewDelegate, UITableViewDataSource {

    private weak var delegate: ESERPCreateViewDelegate?
    
    init(delegate: ESERPCreateViewDelegate?) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
        setUpTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView() {
        tableView.reloadData()
        confirmBtn.isEnabled = delegate?.confirmEnabled() ?? false
    }
    
    private func setUpTableView() {
        self.addSubview(tableView)
        self.addSubview(confirmBtn)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top)
        }
        confirmBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            let height = CGFloat(49)
            make.height.equalTo(height.scalValue)
        }
    }
    
    @objc func confirmBtnClick(sender: UIButton) {
        delegate?.confirmButtonClick()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getItemNum(section: section) ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESERPCreateCell") as! ESERPCreateCell
        cell.delegate = delegate as? ESERPCreateCellDelegate
        cell.updateCell(indexPath.row, indexPath.section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.endEditing(true)
        delegate?.didSelectedItem(indexPath.row)
    }
    
    private lazy var sectionHeader: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ESDeviceUtil.screen_w, height: 46.5))
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        let label = UILabel(frame: CGRect(x: 15, y: 18, width: 95, height: 19))
        label.text = "请填写项目信息"
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: .regular, size: 13.0)
        view.addSubview(label)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tvc = UITableViewController(style: .grouped)
        let view = tvc.tableView!
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        view.delegate = self
        view.dataSource = self
        view.estimatedRowHeight = 50.0
        view.rowHeight = UITableViewAutomaticDimension
        view.keyboardDismissMode = .onDrag
        view.separatorStyle = .none
        view.register(ESERPCreateCell.self, forCellReuseIdentifier: "ESERPCreateCell")
        return view
    }()
    
    private lazy var confirmBtn: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.backgroundColor = UIColor.clear
        button.setTitle("确认创建", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        let normal = ESColor.getImage(color: ESColor.color(sample: .buttonBlue))
        let disabled = ESColor.getImage(color: ESColor.color(sample: .buttonDisable))
        button.setBackgroundImage(normal, for: .normal)
        button.setBackgroundImage(normal, for: .highlighted)
        button.setBackgroundImage(disabled, for: .disabled)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.addTarget(self, action: #selector(ESERPCreateView.confirmBtnClick(sender:)), for: .touchUpInside)
        return button
    }()
}
