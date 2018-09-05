//
//  ESERPMatchView.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

protocol ESERPMatchViewDelegate: ESTableViewProtocol {
    func nextButtonClick()
    func isEmpty() -> Bool
}

class ESERPMatchView: UIView, UITableViewDelegate, UITableViewDataSource {

    private weak var delegate: ESERPMatchViewDelegate?
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ESERPMatchCell.self, forCellReuseIdentifier: "ESERPMatchCell")
        tableView.register(ESERPMatchBottomCell.self, forCellReuseIdentifier: "ESERPMatchBottomCell")
        tableView.register(ESERPMatchEmptyCell.self, forCellReuseIdentifier: "ESERPMatchEmptyCell")
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 30, right: 0)
        return tableView
    }()
    
    init(delegate: ESERPMatchViewDelegate?) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.delegate = delegate
        setUpTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshView() {
        if let empty = delegate?.isEmpty() {
            nextBtn.isEnabled = !empty
        }
        tableView.reloadData()
    }
    
    @objc func nextBtnClick(sender: UIButton) {
        delegate?.nextButtonClick()
    }
    
    private func setUpTableView() {
        self.addSubview(topView)
        self.addSubview(tableView)
        self.addSubview(nextBtn)
        
        topView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(46)
        }
        topLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(18.5)
        }
        
        nextBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(49)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(nextBtn.snp.top)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = delegate?.getItemNum(section: section)
        return num ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let empty = delegate?.isEmpty(), empty == false  {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ESERPMatchCell") as! ESERPMatchCell
                cell.delegate = delegate as? ESERPMatchCellDelegate
                cell.updateCell(index: indexPath.row, section: indexPath.section)
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESERPMatchEmptyCell") as! ESERPMatchEmptyCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESERPMatchBottomCell") as! ESERPMatchBottomCell
            cell.delegate = delegate as? ESERPMatchBottomCellDelegate
            return cell
        }
    }
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        view.addSubview(topLabel)
        return view
    }()
    
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.text = "根据业主手机号查询到的ERP项目信息，请选择"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    private lazy var nextBtn: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.backgroundColor = UIColor.clear
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        let normal = ESColor.getImage(color: ESColor.color(sample: .buttonBlue))
        let disabled = ESColor.getImage(color: ESColor.color(sample: .separatorLine))
        button.setBackgroundImage(normal, for: .normal)
        button.setBackgroundImage(normal, for: .highlighted)
        button.setBackgroundImage(disabled, for: .disabled)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.addTarget(self, action: #selector(ESERPMatchView.nextBtnClick(sender:)), for: .touchUpInside)
        return button
    }()
}
