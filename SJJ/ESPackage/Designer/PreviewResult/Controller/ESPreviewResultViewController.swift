//
//  ESPreviewResultViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/19.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

///上传发起预交底
enum ESPreviewResultUploadDic:String {
    case ErpId = "erpId" //ERP编号
    case ProjectId = "projectId"//项目编号 ,
    case Date = "preDate"//创建时间
    case CosumerName = "name"//消费者
    case Telephone = "mobile"//手机号
    case HouseArea = "houseSize"//房屋面积
    case HouseType = "houseType"//房屋类型
    case RoomType = "roomType"//户型
    case Adress = "address"//小区地址
    case CommunityName = "community"//小区名称
    case Province = "province"//省名
    case ProvinceCode = "provinceCode"//省 code
    case City = "city"//市名
    case CityCode = "cityCode"//市 code
    case District = "district"//区名
    case DistrictCode = "districtCode"//区 code
    case Mark = "remark"//备注
}

typealias ESPreviewResultBlock = ()->Void

class ESPreviewResultViewController: ESBasicViewController,ESRegionPickerViewDelegate, ESDatePickerViewDelegate {
    
    var cellBasicData = [(leftTitle:String, placeHold:String)]()
    var uploadDic:Dictionary<String,String> = [:]
    var currentRect:CGRect!
    var selDate = Date()
    
    private lazy var viewManager = ESPreviewResultViewManager()
    
    private var pickerView:ESRegionPickerView!
    private var selectRegion = ESSelectedRegion()
    
    private var housePickerView:MPPickerView!
    
    private var datePicker:ESDatePickerView!
    
    private var previewSuccessBlock:ESPreviewResultBlock?
    private var uploadModel:ESPreviewResultUploadModel?
    
    init(uploadModel:ESPreviewResultUploadModel, block:@escaping ESPreviewResultBlock) {
        super.init(nibName: nil, bundle: nil)
        self.uploadModel = uploadModel
        self.previewSuccessBlock = block
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Style
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initilizaUI()
        addNotifation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Init UI
    private func initData() {
        cellBasicData = ESPreviewResultModel.creatModel()
        uploadDic = ESPreviewResultModel.createUploadDic()
        if let model1 = uploadModel {
            uploadDic = ESPreviewResultModel.uploadDicValue(uploadDic: self.uploadDic, model: model1)
        }
        currentRect = CGRect.zero
    }
    
    private func initilizaUI() {
        
        setupNavigationTitleWithBack(title: "发起预交底")
        
        view.addSubview(viewManager.tableView)
        viewManager.tableView.delegate = self;
        viewManager.tableView.dataSource = self;
        
        let button = viewManager.completeButton(self)
        view.addSubview(button)
        
        let btnHeight = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        button.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.bottom.equalTo(view.snp.bottom)
            make.size.equalTo(CGSize(width: ScreenWidth, height: btnHeight))
        }
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
        viewManager.tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(button.snp.top)
        }
        addPickViewForAddress()
        addDateSelector()
    }
    
    private func addHousePickerView(_ plistName:String){
        view.endEditing(true)
        housePickerView = MPPickerView(frame: CGRect.init(x: 0, y: ScreenHeight, width: ScreenWidth, height: 220), plistName: plistName, compontCount: 1, linkage: false, optional: false, style: nil, finish: { (dict) in
            
            self.getHouceArea(dict as! [String : String],type: plistName)
            
            self.housePickerView.hiddenPickerView()
        })
        view.addSubview(housePickerView)
        housePickerView.show(in: view)
    }
    
    private func addDateSelector(){
        datePicker = ESDatePickerView(controller: self)
    }
    
    //MARK: - Network
    private func preConfirm(){

        uploadDic[ESPreviewResultUploadDic.HouseType.rawValue] = ESStringUtil.getHouseType(uploadDic[ESPreviewResultUploadDic.HouseType.rawValue])?.id ?? ""
        uploadDic[ESPreviewResultUploadDic.RoomType.rawValue] = ESStringUtil.getRoomType(uploadDic[ESPreviewResultUploadDic.RoomType.rawValue])?.id ?? ""
        
        ESProgressHUD.show(in: self.view)
        ESAppointApi.previewResult(uploadDic, success: { (data) in
            ESProgressHUD.hide(for: self.view)
            if let block = self.previewSuccessBlock {
                block()
            }
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            MBProgressHUD.showError(SHRequestTool.getErrorMessage(error), to: self.view)
        }
    }
    
    //MARK: - Actions
    func previewResultSuccess(block:@escaping ESPreviewResultBlock){
        self.previewSuccessBlock = block
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
    
    @objc func completeClick(){
        print(uploadDic )
        if ESPreviewResultModel.checkUploadDic(self, uploadDic: uploadDic) {
            preConfirm()
        }
    }
    
    //MARK: - ESDatePickerViewDelegate
    func confirmDate(date: Date) {
        selDate = date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let resultString = formatter.string(from: date)
        let cell = viewManager.getPreviewResultCell(0, tableView: viewManager.tableView)
        cell.setDateString(resultString)
        uploadDic[ESPreviewResultUploadDic.Date.rawValue] = resultString
    }
    
    private func selectDate(){
        print("选择时间")
        datePicker.show(mode: .dateAndTime, defaultDate: selDate, minDate: Date(), maxDate: nil)
    }
    
    private func selectHouseType(){
        print("选择房屋类型")
        addHousePickerView("HousingState")
    }
    
    private func selectHouseRoomType(){
        print("选择房屋hu型")
        addHousePickerView("HousingStyle")
    }
    
    private func selectCommunityAddress(){
        print("选择小区地址")
        self.pickerView.show(
            province: selectRegion.provinceCode,
            city: selectRegion.cityCode,
            district: selectRegion.districtCode)
    }
    
    private func addPickViewForAddress(){
        let pickerManager = ESRegionDataManager(type: .package)
        ESProgressHUD.show(in: self.view)
        
        ESRegionDataManager.initRegionData(manager: pickerManager, success: {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.pickerView = ESRegionPickerView(controller: self, manager: pickerManager)
            }
        }) {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: "网络错误, 请稍后重试")
            }
        }
    }
    //MARK: - ESRegionPickerViewDelegate
    func confirmAddress(info: ESSelectedRegion) {
        
        self.selectRegion = info
        
        self.uploadDic = ESAppointDataManager.fixPreviewMessage(info, uploadDic: self.uploadDic)
        
        let indexPath = IndexPath(item: 6, section: 0)
        let cell = viewManager.tableView.cellForRow(at: indexPath)as!ESPreviewResultTableViewCell
        cell.setCommuntyAddress(info)
    }
    
    private func getHouceArea(_ dict:[String:String], type:String){
        print(dict)
        let cell = viewManager.getFreeAppointFirstCell(type, collectionView: viewManager.tableView)
        cell.setHouseTypeAndBugdge(dict)
    }
}

extension ESPreviewResultViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section {
            return cellBasicData.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if 0 == indexPath.section {
            if cellBasicData.count == indexPath.row {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ESPreviewResultSecondTableViewCell", for: indexPath)as!ESPreviewResultSecondTableViewCell
                
                let model = uploadModel
                cell.setCellMark(isMark: false,address:model?.address)
                cell.setCellIndex(index: indexPath.row, vc: self)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ESPreviewResultTableViewCell", for: indexPath)as!ESPreviewResultTableViewCell
                
                cell.setCellIndex(index: indexPath.row, vc: self)
                
                if let model = uploadModel {
                    cell.setCellModel(model: model)
                }
                
                cell.setBasicData(model: cellBasicData[indexPath.row])
                
                return cell
            }
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESPreviewResultSecondTableViewCell", for: indexPath)as!ESPreviewResultSecondTableViewCell
            
            let model = uploadModel
            cell.setCellMark(isMark: true,address:model?.address)
            cell.setCellIndex(index: indexPath.row, vc: self)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        if 0 == indexPath.section {
            switch indexPath.row {
            case 0:
                selectDate()
                break
            case 4:
                selectHouseType()
                break
            case 5:
                selectHouseRoomType()
                break
            case 6:
                selectCommunityAddress()
                break
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESPreviewResultSectionHeader")as!ESPreviewResultSectionHeader
        if 0 == section {
            view.sectionLeftLabel.text = "ERP编号"
            if let model = uploadModel {
                view.sectionLeftLabel.text = "ERP编号  \(model.erpId)"
            }
        } else {
            view.sectionLeftLabel.text = "备注说明"
        }
        return view
    }
}
