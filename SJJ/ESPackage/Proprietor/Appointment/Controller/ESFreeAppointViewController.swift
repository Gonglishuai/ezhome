//
//  ESFreeAppointViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

enum ESFreeAppointUploadDic:String {
    case YourName = "consumerName"
    case Phone = "consumerMobile"
    case HouseArea = "houseArea"//建筑面积
    case DecorationBudget = "decorationBudget"//装修预算
    case HouseType = "houseType"
    case CommunityName = "communityName"//小区名称
    case Province = "province"//省
    case ProvinceName = "provinceName"//省
    case City = "city"//市code
    case CityName = "cityName"//
    case District = "district"//区code
    case DistrictName = "districtName"//区code
    case SelectedType = "selectedType"//类型   套餐：5  个性化：7  其他：6
    case PkgType = "pkgType"//套餐类型
    case FreeAuditFlag = "freeAuditFlag"//免审核标志
    case DesignStyle = "designStyle"//装修风格
    case Channel = "channel"//平台
    case SourceUrl = "sourceUrl"//来源
    case SourceName = "sourceName"//来源名称
    case SourceType = "sourceType"//来源类型
}

/// 业主免费预约
class ESFreeAppointViewController: ESBasicViewController,ESRegionPickerViewDelegate {
    
    var selectedType:Int?//外部需要传    套餐：5  个性化：7  其他：6
    var pkgType:Int?//外部需要传
    @objc var sourceName:String = ""
    @objc var sourceUrl:String = ""
    @objc var sourceType:String = ""
    
    var cellData = [(title:String, grayIcon:String, blackIcon:String)]()
    var uploadDic:Dictionary<String,String> = [:]
    var selectedCount = 0
    var selectedStyleArray:Array<Int>!
    var currentRect:CGRect = CGRect.zero
    
    private var viewManager = ESFreeAppointViewManager()
    private var iconWH:CGFloat = 0
    private var decorationStyle = [ESAppointDecorateStyleModel]()
    
    private var pickerView:ESRegionPickerView!
    private var selectRegion = ESSelectedRegion()
    
    private var housePickerView:MPPickerView!
    
    ///设置套餐预约的类型
    @objc public func setSelectedType(_ info:Dictionary<String,String>){
        
        let selectedType = info["selectedType"] ?? nil
        if let type = selectedType, type != "" {
            self.selectedType = Int(type)
        }
        
        let packageType = info["packageType"] ?? nil
        if let type = packageType, type != "" {
            self.pkgType = Int(type)
        }
    }
    
    //MARK: - Life style
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizaUI()
        addNotifation()
        getDecorationStyle()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - InitUI
    private func initData(){
        cellData = ESCreateProjectModel.createAppointModel()
        uploadDic = ESCreateProjectModel.uploadDicForFreeAppoint()
        iconWH = 65.scalValue
        
        if let selectType = selectedType {
            uploadDic[ESFreeAppointUploadDic.SelectedType.rawValue] = "\(selectType)"
        } else {
            uploadDic[ESFreeAppointUploadDic.SelectedType.rawValue] = ""
        }
        
        if let pkgType = pkgType {
            uploadDic[ESFreeAppointUploadDic.PkgType.rawValue] = "\(pkgType)"
        }
        if !sourceName.isEmpty {
            uploadDic[ESFreeAppointUploadDic.SourceName.rawValue] = sourceName
        }
        if !sourceUrl.isEmpty {
            uploadDic[ESFreeAppointUploadDic.SourceUrl.rawValue] = sourceUrl
        }
        if !sourceType.isEmpty {
            uploadDic[ESFreeAppointUploadDic.SourceType.rawValue] = sourceType
        }
    }
    
    private func initilizaUI() {
        
        initData()
        setupNavigationTitleWithBack(title: "免费预约")
        
        view.addSubview(viewManager.collectionView)
        viewManager.collectionView.delegate = self
        viewManager.collectionView.dataSource = self
        
        let button = viewManager.orderImmediately(self)
        view.addSubview(button)
        
        let btnHeight:CGFloat = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        button.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(btnHeight)
        }
        button.backgroundColor = ESColor.color(hexColor: 0x2696c4, alpha: 1)
        
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
        addPickViewForAddress()
    }
    
    private func addHousePickerView(_ plistName:String){
        view.endEditing(true)
        
        housePickerView = MPPickerView(frame: CGRect.init(x: 0, y: ScreenHeight, width: ScreenWidth, height: 220), plistName: plistName, compontCount: 1, linkage: false, optional: false, style: nil, finish: {[weak self] (dict) in
            guard let `self` = self else{return}
            self.getHouceArea(dict as! [String : String],type: plistName)
            self.housePickerView.hiddenPickerView()
            
        })
        view.addSubview(housePickerView)
        housePickerView.show(in: view)
    }
    
    private func addPickViewForAddress(){
        let pickerManager = ESRegionDataManager(type: .package)
        ESProgressHUD.show(in: self.view)
        
        ESRegionDataManager.initRegionData(manager: pickerManager, success: {
            ESProgressHUD.hide(for: self.view)
            self.pickerView = ESRegionPickerView(controller: self, manager: pickerManager)
        }) {
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: "网络错误, 请稍后重试")
        }
    }
    //MARK: - Network
    private func getDecorationStyle(){
        ESAppointDataManager.getDecorationStyle({ (style) in
            self.decorationStyle = style
            self.selectedStyleArray = []
            for _ in style {
                self.selectedStyleArray.append(0)
            }
            self.viewManager.collectionView.reloadData()
            
        }) {(error) in
            ESProgressHUD.showText(in: self.view, text: SHRequestTool.getErrorMessage(error))
        }
    }
    
    private func appointImmediately(){
        print(uploadDic)
        ESProgressHUD.show(in: view)
        ESAppointApi.appoint(uploadDic, success: { (data) in
            
            ESProgressHUD.hide(for: self.view)
            let appointResult = try?JSONDecoder().decode(ESAppointSuccessModel.self, from: data)
            
            if let result  = appointResult {
                if let success = result.success {
                    if success {
                        self.showAppointResultView(true)
                    } else {
                        self.showAppointResultView(false)
                    }
                }
            } else {
                self.showAppointResultView(false)
            }
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: SHRequestTool.getErrorMessage(error))
        }
    }
    
    //MARK: - Actions
    private func addNotifation(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardShow(_ notice:Notification) {
        let upHeight = ESCGRectUtil.getUpHeight(currentRect, notice: notice)
        if upHeight != 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.viewManager.collectionView.frame = CGRect(x: 0, y: upHeight, width: ScreenWidth, height: ScreenHeight - 50)
            })
        }
    }
    
    @objc private func keyboardHidden(_ notice:Notification){
        currentRect = CGRect.zero
        self.viewManager.collectionView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 50)
    }
    
    func showDecorationBudget() {
        addHousePickerView("PackageDecorationBudget")
    }
    
    func showHouseType() {
        addHousePickerView("HousingState")
    }
    
    func showCommunityAddress() {
        view.endEditing(true)
        self.pickerView.show(
            province: selectRegion.provinceCode,
            city: selectRegion.cityCode,
            district: selectRegion.districtCode)
    }
    
    //MARK: - ESRegionPickerViewDelegate
    func confirmAddress(info: ESSelectedRegion) {
        
        self.selectRegion = info
        
        self.uploadDic = ESAppointDataManager.fixAppointMessage(info, uploadDic: self.uploadDic)
        
        let indexPath = IndexPath(item: 5, section: 0)
        let cell = viewManager.collectionView.cellForItem(at: indexPath)as!ESFreeAppointFirstCollectionViewCell
        cell.setCommuntyAddress(info)
    }
    
    private func getHouceArea(_ dict:[String:String], type:String){
        print(dict)
        let cell = viewManager.getFreeAppointFirstCell(type, collectionView: viewManager.collectionView)
        cell.setHouseTypeAndBugdge(dict)
    }
    
    @objc func orderImmediately(){
        uploadDic[ESFreeAppointUploadDic.DesignStyle.rawValue] = ESAppointDataManager.compentDesignStyle(self.decorationStyle, selectedStyleArray: selectedStyleArray)
        
        if ESAppointDataManager.checkInputedMessage(uploadDic, target: self) {
            appointImmediately()
        }
    }
    
    func showAppointResultView(_ success:Bool){
        let errorView = ESAlertView()
        if success {
            errorView.setShowingElement(ESPackageAsserts.bundleImage(named: "appoint_success"), mainTitle: "启禀大人，预约成功啦~", subTitle: "稍后装修管家会联系您哦~")
            errorView.knownButtonClickBlock({
                self.navigationController?.popToRootViewController(animated: true)
            })
        } else {
            errorView.setShowingElement(ESPackageAsserts.bundleImage(named: "consumer_appoint_fail"), mainTitle: "禀告大人，出错了", subTitle: "没有预约成功，再试一下")
        }
        errorView.showViewAlterView()
    }
}

extension ESFreeAppointViewController:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if 0 == section {
            return 7
        }
        return decorationStyle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if 0 == indexPath.section {
            return CGSize(width: ScreenWidth, height: 68)
        } else {
            return CGSize(width: iconWH, height: 97.scalValue)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if 0 == indexPath.section {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESFreeAppointFirstCollectionViewCell", for: indexPath)as!ESFreeAppointFirstCollectionViewCell
            
            cell.setCreateProjectModel(model: cellData[indexPath.row], cellIndex: indexPath.row,vc: self)
            
//            cell.setCommuntyAddress(self.selectRegion)
            
            var content: String?
            switch indexPath.row {
            case 0:
                content = uploadDic[ESFreeAppointUploadDic.YourName.rawValue]
            case 1:
                content = uploadDic[ESFreeAppointUploadDic.Phone.rawValue]
            case 2:
                content = uploadDic[ESFreeAppointUploadDic.HouseArea.rawValue]
            case 3:
                content = uploadDic[ESFreeAppointUploadDic.DecorationBudget.rawValue]
            case 4:
                content = ESStringUtil.getHouseType(uploadDic[ESFreeAppointUploadDic.HouseType.rawValue])?.value
            case 5:
                content = "\(selectRegion.province)\(selectRegion.city)\(selectRegion.district)"
            case 6:
                content = uploadDic[ESFreeAppointUploadDic.CommunityName.rawValue]
            default:
                break
            }
            cell.setTextFieldContent(content)
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESFreeAppointSelectStyleCollectionViewCell", for: indexPath)as!ESFreeAppointSelectStyleCollectionViewCell
            
            cell.setCreateProjectModel(cellIndex: indexPath.row, vc: self)
            
            if !decorationStyle.isEmpty {
                let model = decorationStyle[indexPath.row]
                cell.setStyleModel(model)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if 0 == section {
            return CGSize(width: ScreenWidth, height: 116)
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if 0 == section {
            return CGSize(width: ScreenWidth, height: 68)
        } else {
            return CGSize(width: ScreenWidth, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ESFreeAppointFirstSectionHeader", for: indexPath)
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ESFreeAppointSectionFooterCollectionReusableView", for: indexPath)as!ESFreeAppointSectionFooterCollectionReusableView
            if indexPath.section == 1 {
                view.sectionFooterImage.isHidden = true
            } else {
                view.sectionFooterImage.isHidden = false
            }
            return view
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if 0 == section {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if 0 == section {
            return CGFloat.leastNormalMagnitude
        }
        return 20.scalValue
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if 0 == section {
            return CGFloat.leastNormalMagnitude
        }
        return 23.scalValue
    }
}
