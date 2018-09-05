//
//  ESDesProjectSearchController.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESDesProjectSearchController: ESBasicViewController, UISearchBarDelegate, ESDesProjectViewDelegate, ESDesProjectCellDelegate {

    private var searchBar: ESSearchBar!
    private lazy var mainView: ESDesProjectView = {
        let view = ESDesProjectView(delegate: self)
        return view
    }()
    private var dataArray: [ESDesProjectListItem] = []
    private var limit: Int = 10
    private var offset: Int = 0
    private var keyword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ESColor.color(sample: .backgroundView)
        
        setupNavigationBarBack()
        setUpSearchbar()
        setupCustomRightItemWithTitle(title: "取消",
                                      color: ESColor.color(hexColor: 0x419DCB, alpha: 1.0),
                                      font: ESFont.font(name: .regular, size: 13.0))
        
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
          }
    }

    func setUpSearchbar() {
        searchBar = ESSearchBar(frame: CGRect(x: 0, y: 0, width: ESDeviceUtil.screen_w - 2 * 44 - 2 * 15, height: 44))
        searchBar.searchBarStyle = .prominent
        let fieldImage = ESColor.getImage(color: ESColor.color(sample: .separatorLine))
        searchBar.setSearchFieldBackgroundImage(fieldImage, for: .normal)
        
        let backImg = ESColor.getImage(color: UIColor.white)
        searchBar.setBackgroundImage(backImg, for: UIBarPosition.any, barMetrics: .default)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8.0, vertical: 0.0)
        searchBar.placeholder = "请输入业主姓名或手机号搜索"
        searchBar.delegate = self
        
        let view = UIView(frame: searchBar.frame)
        view.addSubview(searchBar)
        
        self.navigationItem.titleView = view
    }
    
    override func navigationBarRightAction() {
        print("cancel")
        searchBar.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func requestData(more: Bool) {
        ESProgressHUD.show(in: self.view)
        ESDesProjectListDataManager.getProjectList(type: .all, keyword: keyword, limit: limit, offset: offset, success: { (array, count) in
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
                self.mainView.endHeaderFresh()
                self.mainView.endFooterFresh(noMore: false)
                if more {
                    self.offset -= self.limit
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        keyword = searchBar.text ?? ""
        requestData(more: false)
    }
    
    func refreshProjectList() {
        if keyword != nil {
            offset = 0
            requestData(more: false)
        } else {
            mainView.endHeaderFresh()
        }
    }
    
    func loadMoreProjectList() {
        if keyword != nil {
            offset += limit
            requestData(more: true)
        } else {
            mainView.endFooterFresh(noMore: false)
        }
    }
    
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
