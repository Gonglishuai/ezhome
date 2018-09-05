//
//  ESDesProjectListControllerViewController.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/15.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit

enum ESDesProjectType: String {
//    /// 无
//    case none = ""
    /// 全部
    case all = ""
    /// 设计装修中
    case inProgress = "1"
    /// 待评价
    case evaluate = "4"
    /// 交易完成
    case dealComplete = "5"
    /// 交易关闭
    case dealClose = "3"
}

public class ESDesProjectListController: UIViewController, ESDesProjectViewDelegate, ESDesProjectCellDelegate {

    private var projectType: ESDesProjectType = .all
    lazy var mainView: ESDesProjectView = {
        let view = ESDesProjectView(delegate: self)
        return view
    }()
    private var dataArray: [ESDesProjectListItem] = []
    private var limit: Int = 10
    private var offset: Int = 0
    
    init(type: ESDesProjectType) {
        super.init(nibName: nil, bundle: nil)
        self.projectType = type
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        requestData(more: false)
    }
    
    func requestData(more: Bool) {
        ESProgressHUD.show(in: self.view)
        ESDesProjectListDataManager.getProjectList(type: projectType, keyword: nil, limit: limit, offset: offset, success: { (array, count) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.mainView.endHeaderFresh()
                if !more {
                    self.dataArray.removeAll()
                }
                self.dataArray += array
                if array.count > 0 {
                    ESEmptyView.hideEmptyView(in: self.view)
                    self.mainView.endFooterFresh(noMore: self.dataArray.count >= count)
                    self.mainView.refreshMainView()
                } else {
                    self.mainView.endFooterFresh(noMore: true)
                    ESEmptyView.showEmptyView(in: self.mainView, image: "package_noData", text: "暂时还没有任何项目哦~")
                }
            }
        }) {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: "网络错误, 请稍后重试")
            }
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ESDesProjectViewDelegate
    func getItemNum(section: Int) -> Int {
        return dataArray.count
    }
    
    func selectItem(index: Int, section: Int) {
        let project = dataArray[index]
        if let assetId = project.assetId {
            let pkgViewTag = project.pkgViewFlag != nil ? String(project.pkgViewFlag!) : ""
            let vc = ESDesProjectDetailController(assetId: String(assetId), pkgViewTag: pkgViewTag)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func refreshProjectList() {
        offset = 0
        requestData(more: false)
    }
    
    func loadMoreProjectList() {
        offset += limit
        requestData(more: true)
    }
    
    // MARK: ESDesProjectCellDelegate
    func getViewModel(index: Int, section: Int, cellId: String, viewModel: ESViewModel) {
        if index >= dataArray.count {
            return
        }
        let project = dataArray[index]
        let itemModel = viewModel as! ESDesProjectListViewModel
        ESDesProjectListDataManager.manageData(data: project, vm: itemModel)
    }
    
    func phoneTextClick(phone: String) {
        ESDeviceUtil.callToSomeone(numberString: phone)
    }

}
