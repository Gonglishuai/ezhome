//
//  ESSearchBrandViewController.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESSearchBrandViewController: ESBasicViewController,UISearchBarDelegate {
    ///推荐品牌 最外层大 list
    var originalAddedBrandObjects = ESBrandBigTytpe()
    var addBrandsBlock:((_ brands:ESBrandBigTytpe)->Void)?

    private var searchBar:ESSearchBar!
    private lazy var mainView = ESSearchBransMainView(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        initilizeUI()
        setUpSearchbar()
    }
    
    //MARK: - InitUI
    private func initilizeUI(){
        setupNavigationBarBack()
        setupCustomRightItemWithTitle(title: "取消", color: ESColor.color(sample: .buttonBlue), font: ESFont.font(name: .regular, size: 14))
        
        view.addSubview(mainView)
        
        mainView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        mainView.hasAddedBrands = originalAddedBrandObjects
        if originalAddedBrandObjects.isEmpty {
            mainView.setBottomButtonColor(color: ESColor.color(hexColor: 0xCFCFCF, alpha: 1), enable: false)
            
        } else {
            mainView.setBottomButtonColor(color: ESColor.color(sample: .buttonBlue), enable: true)
        }
        mainView.addingBrandObjects = originalAddedBrandObjects
    }
    
    private func setUpSearchbar() {
        searchBar = ESSearchBar(frame: CGRect(x: 0, y: 0, width: ESDeviceUtil.screen_w - 2 * 44 - 2 * 15, height: 44))
        searchBar.searchBarStyle = .prominent
        let fieldImage = ESColor.getImage(color: ESColor.color(sample: .separatorLine))
        searchBar.setSearchFieldBackgroundImage(fieldImage, for: .normal)
        
        let backImg = ESColor.getImage(color: UIColor.white)
        searchBar.setBackgroundImage(backImg, for: UIBarPosition.any, barMetrics: .default)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8.0, vertical: 0.0)
        searchBar.placeholder = "请输入关键字"
        searchBar.delegate = self
        
        let view = UIView(frame: searchBar.frame)
        view.addSubview(searchBar)
        
        self.navigationItem.titleView = view
    }
    
    //MARK: - Actions
    override func navigationBarRightAction() {
        searchBar.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    override func navigationBarBackAction() {
        searchBar.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let keyword = searchBar.text ?? ""
        mainView.requestDataForBrands(ketword: keyword)
    }
    
    func popBack(){
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: ESCreateBrandListViewController.self){
                navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
}

extension ESSearchBrandViewController:ESSearchBransMainViewProtocol{
    func addBrands(brands: ESBrandBigTytpe) {
        if let block = addBrandsBlock {
            block(brands)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ESSearchedBrands"), object: nil, userInfo: ["brands":brands])
        popBack()
    }
}
