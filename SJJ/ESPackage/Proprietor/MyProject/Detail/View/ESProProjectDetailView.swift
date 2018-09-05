//
//  ESProProjectDetailView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProProjectDetailViewDelegate: ESTableViewProtocol, NSObjectProtocol {
    func getCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell?
}

class ESProProjectDetailView: UIView, UITableViewDelegate, UITableViewDataSource {

    private weak var delegate: ESProProjectDetailViewDelegate?
    var tableView: UITableView!
    
    init(delegate: ESProProjectDetailViewDelegate?) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
        setUpTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = ESColor.color(sample: .backgroundView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ESProProjectOrderDetailCell.self, forCellReuseIdentifier: "ESProProjectOrderDetailCell")
        tableView.register(ESProProjectRejectCancelCell.self, forCellReuseIdentifier: "ESProProjectRejectCancelCell")
        tableView.register(ESProProjectDesignerCell.self, forCellReuseIdentifier: "ESProProjectDesignerCell")
        tableView.register(ESProProjectContractCell.self, forCellReuseIdentifier: "ESProProjectContractCell")
        tableView.register(ESProProjectCostInfoCell.self, forCellReuseIdentifier: "ESProProjectCostInfoCell")
        tableView.register(ESProProjectPreviewInfoCell.self, forCellReuseIdentifier: "ESProProjectPreviewInfoCell")
        tableView.register(ESProProjectDeliveryInfoCell.self, forCellReuseIdentifier: "ESProProjectDeliveryInfoCell")
        tableView.register(ESProProjectDetailHeader.self, forHeaderFooterViewReuseIdentifier: "ESProProjectDetailHeader")
        tableView.register(ESProProjectDetailFooter.self, forHeaderFooterViewReuseIdentifier: "ESProProjectDetailFooter")
        tableView.estimatedRowHeight = 200.0
        tableView.estimatedSectionHeaderHeight = 50
        tableView.estimatedSectionFooterHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        self.addSubview(tableView)
        
        
        tableView.snp.makeConstraints { (make) in
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
        }
    }
    
    func refreshMainView() {
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESProProjectDetailHeader") as! ESProProjectDetailHeader
        header.delegate = self.delegate as? ESProProjectDetailHeaderDelegate
        header.updateHeaderView(index: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionNum = delegate?.getSectionNum!() ?? 0
        let last = section + 1 == sectionNum
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESProProjectDetailFooter") as! ESProProjectDetailFooter
        footer.delegate = self.delegate as? ESProProjectDetailFooterDelegate
        footer.updateFooterView(index: section, last: last)
        return footer
    }

//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        let sectionNum = delegate?.getSectionNum!() ?? 0
//        let last = section + 1 == sectionNum
//        ret
//    }
}
