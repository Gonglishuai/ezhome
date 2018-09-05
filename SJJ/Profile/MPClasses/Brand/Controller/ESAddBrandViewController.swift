//
//  ESAddBrandViewController.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

/// 添加品牌
class ESAddBrandViewController: ESBasicViewController {
    
    var addBrandsBlock:((_ brands:ESBrandBigTytpe)->Void)?
    
    ///推荐品牌 最外层大 list
    var originalAddedBrandObjects = ESBrandBigTytpe()
    
    private lazy var mainView = ESAddBrandMainView(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        requestDataForCatalogs()
        setMainViewData()
    }
    
    //MARK: - InitUI
    func initializeUI() {
        
        setupNavigationTitleWithBack(title: "添加品牌")
        setupNavigationBarRightWithImage(image: ESPackageAsserts.bundleImage(named: "nav_search"))
        
        view.addSubview(mainView)
        
        mainView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    //MARK: - Network
    func requestDataForCatalogs(){//获取分类
        ESProgressHUD.show(in: view)
        ESBrandApi.getBrandsCatagorys(success: { (data) in
            
            ESProgressHUD.hide(for: self.view)
            
            let catagory = try?JSONDecoder().decode([ESBrandsCatalogsModel].self, from: data)
            
            if let result = catagory {
                self.mainView.setTypeListViewData(catagorys: result)
            }
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: SHRequestTool.getErrorMessage(error))
        }
    }
    
    func setMainViewData(){
        if originalAddedBrandObjects.isEmpty {
            mainView.setBottomButtonColor(color: ESColor.color(hexColor: 0xCFCFCF, alpha: 1), enable: false)
        } else {
            mainView.setBottomButtonColor(color: ESColor.color(sample: .buttonBlue), enable: true)
        }
        mainView.addingBrandObjects = originalAddedBrandObjects
        mainView.requestDataForBrands(catLevel: "1", catId: "0")
    }
    
    //MARK: - Actions
    override func navigationBarRightAction() {
        let vc = ESSearchBrandViewController()
        vc.originalAddedBrandObjects = originalAddedBrandObjects
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ESAddBrandViewController:ESAddBrandMainViewProtocol{
    func addBrands(brands: ESBrandBigTytpe) {
        if let block = addBrandsBlock {
            block(brands)
        }
        navigationController?.popViewController(animated: true)
    }
}

