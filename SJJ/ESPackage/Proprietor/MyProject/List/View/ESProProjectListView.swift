//
//  ESProProjectListView.swift
//  Consumer
//
//  Created by Jiao on 2018/1/7.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProProjectListViewDelegate: ESTableViewProtocol {
    func refreshProjectList()
    func loadMoreProjectList()
}

class ESProProjectListView: UIView, UITableViewDelegate, UITableViewDataSource {

    private weak var delegate: ESProProjectListViewDelegate?
    var tableView: UITableView!
    
    private let header = MJRefreshNormalHeader()
    private let footer = MJRefreshBackNormalFooter()
    
    init(delegate: ESProProjectListViewDelegate?) {
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
        tableView.register(ESProProjectListCell.self, forCellReuseIdentifier: "ESProProjectListCell")
        tableView.register(ESProProjectListHeader.self, forHeaderFooterViewReuseIdentifier: "ESProProjectListHeader")
        tableView.register(ESProProjectListFooter.self, forHeaderFooterViewReuseIdentifier: "ESProProjectListFooter")
        tableView.estimatedRowHeight = 200.0
        tableView.estimatedSectionHeaderHeight = 50
        tableView.estimatedSectionFooterHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        self.addSubview(tableView)
        
        header.setRefreshingTarget(self, refreshingAction: #selector(ESProProjectListView.headerFresh))
        header.isAutomaticallyChangeAlpha = true
        self.tableView.mj_header = header
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(ESProProjectListView.footerFresh))
        footer.isAutomaticallyChangeAlpha = true
        self.tableView.mj_footer = footer
        
        tableView.snp.makeConstraints { (make) in
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
        }
    }
    
    @objc private func headerFresh() {
        delegate?.refreshProjectList()
    }
    
    @objc private func footerFresh() {
        delegate?.loadMoreProjectList()
    }
    
    func endHeaderFresh() {
        header.endRefreshing()
    }
    
    func endFooterFresh(noMore: Bool) {
        if noMore {
            footer.endRefreshingWithNoMoreData()
        }else {
            footer.endRefreshing()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESProProjectListCell") as! ESProProjectListCell
        cell.delegate = self.delegate as? ESProProjectListCellDelegate
        cell.updateCell(index: indexPath.row, section: indexPath.section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESProProjectListHeader") as! ESProProjectListHeader
        header.delegate = self.delegate as? ESProProjectListHeaderDelegate
        header.updateHeaderView(index: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESProProjectListFooter") as! ESProProjectListFooter
        footer.delegate = self.delegate as? ESProProjectListFooterDelegate
        footer.updateFooterView(index: section)
        return footer
    }
}
