//
//  ESERPCreateController.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESERPCreateController: ESBasicViewController, ESERPCreateViewDelegate, ESERPCreateCellDelegate, ESRegionPickerViewDelegate, ESServiceStorePickerViewDelegate {
    
    private var pickerView: ESRegionPickerView!
    private var storePicker: ESServiceStorePickerView!
    private var selectRegion = ESSelectedRegion()
    private var selectStore = ESServiceStore()
    private var assetId: String = ""
    private var form: ESERPCreateModel = ESERPCreateModel()
    private var canCommit: Bool = false
    
    init(assetId: String, model: ESPackageBaseInfo) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        form.phoneNum = model.consumerMobile!
        form.customerName = model.consumerName ?? ""
        form.province = model.provinceName ?? ""
        form.provinceCode = model.provinceCode ?? ""
        form.city = model.cityName ?? ""
        form.cityCode = model.cityCode ?? ""
        form.district = model.districtName ?? ""
        form.districtCode = model.districtCode ?? ""
        form.community = model.communityName ?? ""        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationTitleWithBack(title: "创建ERP项目")
        let pickerManager = ESRegionDataManager(type: .package)
        
        ESProgressHUD.show(in: self.view)
        ESRegionDataManager.initRegionData(manager:pickerManager, success: {
            ESServiceStoreManager.getStoreList(success: { (list) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    self.view.addSubview(self.mainView)
                    self.mainView.snp.makeConstraints { (make) in
                        make.left.right.bottom.equalToSuperview()
                        if #available(iOS 11.0, *) {
                            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                        }else {
                            make.top.equalTo(self.topLayoutGuide.snp.bottom)
                        }
                    }
                    
                    self.pickerView = ESRegionPickerView(controller: self, manager: pickerManager)
                    self.storePicker = ESServiceStorePickerView(controller: self, dataArr: list)
                }
            }, failure: {
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: "网络错误, 请稍后重试")
                }
            })
        }) {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: "网络错误, 请稍后重试")
            }
        }
    }

    // MARK: - ESERPCreateViewDelegate
    func confirmButtonClick() {
        if !ESFormCheck.isPhoneNum(form.designer) {
            ESProgressHUD.showText(in: self.view, text: "请输入正确的手机号码!")
            return
        }
        
        ESProgressHUD.show(in: self.view)
        ESERPCreateDataManager.createERP(assertId: assetId, form: form, success: {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: "创建成功")
                if let vc = ESPackageManager.refreshDesProjectDetail(self.navigationController) {
                    vc.requestData()
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        DispatchQueue.main.async {
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                    }
                }
            }
        }) { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
            }
        }
    }
    
    func confirmEnabled() -> Bool {
        return canCommit
    }
    
    func didSelectedItem(_ index: Int) {
        let model = itemModels[index]
        switch model.key {
        case .region:
            self.pickerView.show(
                province: selectRegion.provinceCode,
                city: selectRegion.cityCode,
                district: selectRegion.districtCode)
        case .store:
            self.storePicker.show(storeCode: selectStore.code)
        default:
            break
        }
    }
    
    // MARK: - ESRegionPickerViewDelegate
    func confirmAddress(info: ESSelectedRegion) {
        self.selectRegion = info
        form.province = info.province
        form.provinceCode = info.provinceCode
        form.city = info.city
        form.cityCode = info.cityCode
        form.district = info.district
        form.districtCode = info.districtCode
        canCommit = ESERPCreateDataManager.check(form)
        mainView.updateView()
    }
    
    // MARK: - ESServiceStorePickerViewDelegate
    func confirmStore(info: ESServiceStore) {
        selectStore = info
        form.serviceStore = info.code ?? ""
        canCommit = ESERPCreateDataManager.check(form)
        mainView.updateView()
    }
    
    // MARK: - ESERPCreateCellDelegate
    func textFieldComplete(viewModel: ESERPCreateViewModel) {
        ESERPCreateDataManager.manageData(vm: viewModel, data: form)
        canCommit = ESERPCreateDataManager.check(form)
        mainView.updateView()
    }
    
    func getItemNum(section: Int) -> Int {
        return itemModels.count
    }
    
    func getViewModel(_ index: Int) -> ESERPCreateViewModel {
        var model = itemModels[index]
        switch index {
        case 0:
            model.itemContent = form.customerName
        case 1:
            model.itemContent = form.phoneNum
        case 2:
            model.itemContent = String(format: "%@%@%@", form.province, form.city, form.district)
        case 3:
            model.itemContent = form.community
        case 4:
            model.itemContent = form.address
        case 5:
            model.itemContent = form.designer
        case 6:
            model.itemContent = selectStore.name
        default:
            break
        }
        return model
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private lazy var mainView: ESERPCreateView = {
        let view = ESERPCreateView(delegate: self)
        return view
    }()
    
    private lazy var itemModels: [ESERPCreateViewModel] = {
        let models = ESERPCreateDataManager.getItemViewModel()
        return models
    }()
}
