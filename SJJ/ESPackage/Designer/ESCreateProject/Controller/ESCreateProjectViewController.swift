//
//  ESCreateProjectViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

enum ESCreateProjectUploadDic:String {
    case OwnerName = "consumerName"//消费者姓名
    case Phone = "consumerMobile"//联系电话
    case ConsumerJid = "consumerJid"//消费者Jid
    case DesignerJid = "designerJid"//设计师 Jid
    case ComunityName = "communityName"//小区地址
    case HouseType = "houseType"//房屋类型
    case RoomType = "roomType"//户型
    case HouseArea = "houseArea"//房屋面积
    case ProjectType = "pkgType"//套餐类型
    case Province = "province"//省 code
    case ProvinceName = "provinceName"//省名
    case City = "city"//市 code
    case CityName = "cityName"//市名
    case District = "district"//区 code
    case DistrictName = "districtName"//区名
    case SelectedType = "selectedType"//类型
    case FreeAuditFlag = "freeAuditFlag"//免审核标志
    case Channel = "channel"//平台
}
/// 创建家装项目
public class ESCreateProjectViewController: ESBasicViewController, ESRegionPickerViewDelegate {
    
    var uploadDic:Dictionary<String,String> = [:]
    var cellData = [(title:String, grayIcon:String, blackIcon:String)]()
    var currentRect:CGRect = CGRect.zero
    
    private lazy var viewManager = ESCreateProjectViewManager()
    private var pickerView:ESRegionPickerView!
    private var selectRegion = ESSelectedRegion()
    
    private var housePickerView:MPPickerView!
    private var packageList = [String]()
    private var consumerInfo:Dictionary<String,String>?
    
    //MARK: - Life style
    override public func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initilizeUI()
        addNotifation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc public func setConsumerInfo(_ info:Dictionary<String,String>){
        self.consumerInfo  = info;
        print("创建家装项目info：\(info)")
    }
    
    //MARK: - Init UI
    private func initData(){
        cellData = ESCreateProjectModel.createModel()
        uploadDic = ESCreateProjectModel.uploadDicForCreateProject()
        if let info = consumerInfo {
            uploadDic[ESCreateProjectUploadDic.OwnerName.rawValue] = info["name"]
            uploadDic[ESCreateProjectUploadDic.Phone.rawValue] = info["mobile_number"]
            uploadDic[ESCreateProjectUploadDic.ConsumerJid.rawValue] = info["member_id"]
        }
        uploadDic[ESCreateProjectUploadDic.DesignerJid.rawValue] = JRKeychain.loadSingleUserInfo(UserInfoCode.jId)
    }
    
    private func initilizeUI() {
        
        setupNavigationTitleWithBack(title: "创建家装项目")
        
        view.addSubview(viewManager.tableView)
        viewManager.tableView.delegate = self
        viewManager.tableView.dataSource = self
        
        let confirmBtn = viewManager.conformCreateProject(self)
        view.addSubview(confirmBtn)

        let btnHeight = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        confirmBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(btnHeight)
        }
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            confirmBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
        addPickViewForAddress()
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
    
    private func addHousePickerView(_ plistName:String){
        view.endEditing(true)
        
        housePickerView = MPPickerView(frame: CGRect.init(x: 0, y: ScreenHeight, width: ScreenWidth, height: 220), plistName: plistName, compontCount: 1, linkage: false, optional: false, style: nil, finish: {[weak self] (dict) in
            guard let `self` = self else {return}
            
            self.getHouceArea(dict as! [String : String],type: plistName)
            
            self.housePickerView.hiddenPickerView()
        })
        view.addSubview(housePickerView)
        housePickerView.show(in: view)
    }
    
    //MARK: - Network
    private func confirmCreateProject(){
        
        ESProgressHUD.show(in: view)
        ESAppointApi.creatProject(uploadDic, success: { (data) in
            ESProgressHUD.hide(for: self.view)
            
            let creatResult = try? JSONDecoder().decode(ESAppointSuccessModel.self, from: data)
            
            let errorView = ESAlertView()
            
            if let result = creatResult {
                if let success = result.success {
                    if success {
                        errorView.setShowingElement(#imageLiteral(resourceName: "consumer_appoint_sucess"), mainTitle: "创建成功", subTitle: "", buttonTitle: "知道了")
                        errorView.knownButtonClickBlock({
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                    }
                }
            }
            errorView.showViewAlterView()
            
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            MBProgressHUD.showError(SHRequestTool.getErrorMessage(error), to: self.view)
        }
    }
    
    private func requestData(){
        
        ESProgressHUD.show(in: view)
        ESPackageEntranceApi.getPackageList({ (responseData) in
            
            ESProgressHUD.hide(for: self.view)
            let packageList = try?JSONDecoder().decode([ESPackageListModel].self, from: responseData)
            
            if let model = packageList {
                for model1 in model {
                    self.packageList.append(model1.pkgName ?? "")
                }
                self.showProjectType()
            }
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: SHRequestTool.getErrorMessage(error))
        }
    }
    
    //MARK: - Action
    override func navigationBarBackAction() {
        navigationController?.popToRootViewController(animated: true)
    }

    private func addNotifation(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardShow(_ notice:Notification) {
        let upHeight = ESCGRectUtil.getUpHeight(currentRect, notice: notice)
        if upHeight != 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.viewManager.tableView.frame = CGRect(x: 0, y: upHeight, width: ScreenWidth, height: ScreenHeight - 50)
            })
        }
    }
    
    @objc private func keyboardHidden(_ notice:Notification){
        currentRect = CGRect.zero
        self.viewManager.tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 50)
    }
    
    @objc func createProject() {
        if viewManager.checkCreateProjectUploadDic(self,uploadDic: uploadDic) {
            print(uploadDic)
            confirmCreateProject()
        }
    }
    
    func showHouseAddress() {
        print("选择地址")
        view.endEditing(true)
        self.pickerView.show(
            province: selectRegion.provinceCode,
            city: selectRegion.cityCode,
            district: selectRegion.districtCode)
    }
    
    func showProjectType() {
        view.endEditing(true)
        print("选择项目")
        if !packageList.isEmpty {
            housePickerView = MPPickerView(frame: CGRect.init(x: 0, y: ScreenHeight, width: ScreenWidth, height: 220), title: "", arrayDataSource: packageList, finish: { [weak self] (dict) in
                guard let `self` = self else {return}
                
                self.getHouceArea(dict as! [String : String],type: "")
                
                self.housePickerView.hiddenPickerView()
            })
            view.addSubview(housePickerView)
            housePickerView.show(in: view)
        } else {
            requestData()
        }
    }
    
    func showHouseType() {
        print("选择房屋类型")
        addHousePickerView("HousingState")
    }
    
    func showRoomType() {
        print("选择户型")
        addHousePickerView("HousingStyle")
    }
    
    private func getHouceArea(_ dict:[String:String], type:String){
        print(dict)
        let cell = viewManager.getCreateProjectCell(type, collectionView: viewManager.tableView)
        cell.setHouseTypeAndBugdge(dict)
    }
    
    //MARK: - ESRegionPickerViewDelegate
    func confirmAddress(info: ESSelectedRegion) {
        
        self.selectRegion = info
        
        self.uploadDic = ESAppointDataManager.fixAppointMessage(info, uploadDic: self.uploadDic)
        
        let indexPath = IndexPath(item: 0, section: 2)
        let cell = viewManager.tableView.cellForRow(at: indexPath)as!ESCreateProjectTableViewCell
        cell.setCommuntyAddress(info)
    }
    
}
//MARK: - UITableViewDelegate, UITableViewDataSource
extension ESCreateProjectViewController:UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return cellData.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ESCreateProjectTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ESCreateProjectTableViewCell") as! ESCreateProjectTableViewCell!
        
        cell.setCreateProjectModel(model: cellData[indexPath.section],cellIndex: indexPath.section,vc: self)
        
        if let info = consumerInfo {//set default info
            if 0 == indexPath.section {
                cell.changeTheCellStyle(false)
                cell.sourceTextFiled.text = info["name"]
            } else if 1 == indexPath.section {
                cell.changeTheCellStyle(false)
                cell.sourceTextFiled.text = info["mobile_number"]
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionFooterForCreateProject")as!SectionFooterForCreateProject
        return view
    }
}
