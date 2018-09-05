//
//  ESCaseListView.swift
//  EZHome
//
//  Created by shiyawei on 7/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
protocol ESCaseListViewRefreshDelegate {
    func loadMore()
}
class ESCaseListView: UIView,UITableViewDelegate,UITableViewDataSource {
    let tableF = MJRefreshAutoNormalFooter()
    
    var delegate:ESCaseListViewRefreshDelegate?
    var sDelegate:ESPlanListViewScrollDelegate?
    
    var caseListDatas = Array<ESDesignCaseList>()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: frame.size.height)
        self.addSubview(self.tableView)
    }
    @objc func footerRefresh() {
        self.delegate?.loadMore()
    }
    
    func endRefresh(index:Int) {
        self.tableView.mj_footer.endRefreshing()
        if index == 0 {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        }
    }
    func analysisCaseListModel(array:Array<ESDesignCaseList>) {
        self.caseListDatas = array
        self.tableView.reloadData()
    }
    func hidenTopView() {
        self.tableView.tableHeaderView = nil
    }
    ///显示无数据页面
    func showTopView() {
        self.tableView.tableHeaderView = self.topView
    }
    //    MARK : UITableViewDelegate,UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.caseListDatas.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 211
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESCaseTableViewCell", for: indexPath) as! ESCaseTableViewCell
        
        cell.centerLabel.isHidden = false
        cell.analysisListModel(model: self.caseListDatas[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.caseListDatas[indexPath.row]
        
        var info = ["brandId":""]
        info["caseId"] = model.assetId
        info["caseType"] = "3d"
        
        MGJRouter.openURL("/Case/CaseDetail/PackageRoom", withUserInfo: info, completion: nil)
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        sDelegate?.didscrollView(y: scrollView.contentOffset.y)
    }
    
    //    MARK:懒加载
    lazy var tableView:UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        
        view.register(UINib.init(nibName: "ESCaseTableViewCell", bundle: nil), forCellReuseIdentifier: "ESCaseTableViewCell")
        
        view.alwaysBounceVertical = false
        
        tableF.setRefreshingTarget(self, refreshingAction: #selector(self.footerRefresh))
        tableF.setTitle("上拉加载更多...", for: .idle)
        tableF.setTitle("加载更多...", for: .refreshing)
        tableF.setTitle("已加载全部...", for: .noMoreData)
        tableF.stateLabel.font = UIFont.systemFont(ofSize: 15)
        
        view.mj_footer = tableF
        
        return view
    }()
    lazy var topView:ESTableViewNoDataView = {
        let view = Bundle.main.loadNibNamed("ESTableViewNoDataView", owner: nil, options: nil)?.first as! ESTableViewNoDataView
        view.frame = self.tableView.bounds
        view.titleLabel.text = "当前还没有3D案例~"
        return view
    }()
}
