//
//  ESCreateBrandListViewController.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit


typealias ESBrandBigTytpe = [ESBrandGoodsModel]//[String:[ESBrandGoodsModel]]

/// 创建品牌清单
class ESCreateBrandListViewController: ESBasicViewController {

    @objc var fixBrandList:Bool = false
    
    private lazy var mainView = ESCreateBrandListMainView(delegate: self)
    private var brandId = ""

    ///推荐品牌 最外层大 list
    private var hasAddedBrandObjects = ESBrandBigTytpe()
    
    //MARK: - Init
    @objc public init(brandId: String) {
        super.init(nibName: nil, bundle: nil)
        self.brandId = brandId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        NotificationCenter.default.addObserver(self, selector: #selector(searchedResult(noti:)), name: NSNotification.Name(rawValue: "ESSearchedBrands"), object: nil)
    }
    
    @objc private func searchedResult(noti:Notification){
        hasAddedBrandObjects = noti.userInfo!["brands"] as! ESBrandBigTytpe
        mainView.reloadTableView(brandList: hasAddedBrandObjects, scrollToBottom: true)
    }
    
    //MARK: - Init UI
    func initializeUI() {
        
        if fixBrandList {
            setupNavigationTitleWithBack(title: "修改品牌清单")
            mainView.setCreateButtonTitle(title: "修改")
            requestForBrandList()
        } else {
            setupNavigationTitleWithBack(title: "创建品牌清单")
        }
        
        view.addSubview(mainView)
        
        mainView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    //MARK: - Network
    func reaustForCreatBrandList(upload: Dictionary<String, Any>){//创建品牌清单
        print("上传参数====\(upload)")
        ESProgressHUD.show(in: mainView)
        ESBrandApi.createBrandList(upload, success: { (data) in
            
            ESProgressHUD.hide(for: self.mainView)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "brandRecommendChange"), object: nil, userInfo: nil)
            self.navigationController?.popViewController(animated: true)
            
        }) { (error) in
            self.showErrorToast(error: error)
        }
    }
    
    func requestForBrandList() {//获取要修改的品牌清单
        
        ESProgressHUD.show(in: mainView)

        ESBrandApi.getBrandList(brandList: brandId, success: { (data) in
            
            ESProgressHUD.hide(for: self.mainView)
            
            let brands = try?JSONDecoder().decode(ESFixRecommendBrandModel.self, from: data)
            
            if let list = brands {
                self.hasAddedBrandObjects = ESBrandDataManager.fixBrandsToNeeded(nowBrand: list)
                self.brandId = list.recommendsBrandId ?? ""
                self.mainView.setBrandListName(name: list.name ?? "", description: list.description ?? "")
                self.mainView.reloadTableView(brandList: self.hasAddedBrandObjects, scrollToBottom: false)
            }
        }) { (error) in
            self.showErrorToast(error: error)
        }
    }
    
    func requestForFixBrandList(upload: Dictionary<String, Any>) {//修改的品牌清单
        
        var upoadDic = upload
        
        upoadDic["recommendsBrandId"] = brandId
        print("上传参数====\(upoadDic)")

        ESProgressHUD.show(in: mainView)
        
        ESBrandApi.fixBrandList(parm: upoadDic, success: { (data) in
            
            for vc in (self.navigationController?.viewControllers)! {
                if vc.isKind(of: ESRecommendViewController.self){
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }) { (error) in
            self.showErrorToast(error: error)
        }
    }

    private func showErrorToast(error:Error){
        ESProgressHUD.hide(for: self.mainView)
        ESProgressHUD.showText(in: self.mainView, text: SHRequestTool.getErrorMessage(error))
    }
}

extension ESCreateBrandListViewController:ESCreateBrandListMainViewDelegate {
   
    func creatBrandList(upload: Dictionary<String, Any>) {
        print("创建")
        if fixBrandList {
            requestForFixBrandList(upload: upload)
        } else {
            reaustForCreatBrandList(upload: upload)
        }
    }
    
    func deleteBrand(cellIndexPath: IndexPath) {
        
        hasAddedBrandObjects.remove(at: cellIndexPath.row)
    }
    
    func addBrand(){//TODO: - 添加品牌
        self.view.endEditing(true)
        let vc = ESAddBrandViewController()
        vc.originalAddedBrandObjects = hasAddedBrandObjects
        vc.addBrandsBlock = {[weak self] (brands:ESBrandBigTytpe) in
            guard let `self` = self else {
                return
            }
            self.hasAddedBrandObjects = brands
            self.mainView.reloadTableView(brandList: brands, scrollToBottom: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
