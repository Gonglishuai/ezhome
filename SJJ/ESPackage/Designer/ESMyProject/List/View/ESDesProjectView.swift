//
//  ESDesProjectView.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit
//import MJRefresh

protocol ESDesProjectViewDelegate: ESTableViewProtocol {
    func refreshProjectList()
    func loadMoreProjectList()
}

class ESDesProjectView: UIView, UITableViewDelegate, UITableViewDataSource {

    private weak var delegate: ESDesProjectViewDelegate?
    private var tableView: UITableView!
    
    private let header = MJRefreshNormalHeader()
    private let footer = MJRefreshBackNormalFooter()
    
    init(delegate: ESDesProjectViewDelegate?) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
        setUpTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = ESColor.color(sample: .backgroundView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ESDesProjectCell.self, forCellReuseIdentifier: "ESDesProjectCell")
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        self.addSubview(tableView)
        
        header.setRefreshingTarget(self, refreshingAction: #selector(ESDesProjectView.headerFresh))
        header.isAutomaticallyChangeAlpha = true
        self.tableView.mj_header = header
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(ESDesProjectView.footerFresh))
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
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getItemNum(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESDesProjectCell") as! ESDesProjectCell
        cell.delegate = delegate as? ESDesProjectCellDelegate
        cell.updateCell(index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectItem?(index: indexPath.row, section: indexPath.section)
    }
}


