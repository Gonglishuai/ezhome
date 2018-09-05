//
//  ESAgreementViewController.swift
//  Consumer
//
//  Created by jiang on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

/// 录入合同信息
class ESAgreementViewController: ESBasicViewController,ESRegionPickerViewDelegate, ESDatePickerViewDelegate {
    
    var AgreeAgreementBlock: (() -> Void)?
    
    private var pickerView:ESRegionPickerView!
    private var selectRegion = ESSelectedRegion()
    private var housePickerView:MPPickerView!
    private var datePicker:ESDatePickerView!
    private var tableView:UITableView!
    private var myIndexPath: IndexPath!
    var upload = ESAgreementModel()
    private var dataArray: [[String]] = []
    private var actDataArray: [[String]] = []
    private var placeHolderArray: [[String]] = []
    var currentRect:CGRect!
    
    //MARK: - Life Style
    override func viewDidLoad() {
        super.viewDidLoad()
        currentRect = CGRect.zero
        setupNavigationTitleWithBack(title: "录入合同信息")

        myIndexPath = IndexPath.init(row: 0, section: 0)
        var dataSection1 = ["业主姓名"]
        dataSection1.append("联系电话")
        dataSection1.append("套内建筑面积")
        dataSection1.append("户　　型")
        dataSection1.append("房屋类型")
        dataSection1.append("小区地址")
        dataSection1.append("小区名称")
        dataSection1.append("")
        dataSection1.append("合同金额")
        dataSection1.append("签约日期")
        dataSection1.append("开工日期")
        dataSection1.append("工期天数")
        dataSection1.append("周末是否开工")
        dataSection1.append("竣工日期")
        dataArray = [dataSection1, [""]];
        
        initData()
        
        var placeSection1 = ["请输入业主姓名"]
        placeSection1.append("请输入业主电话")
        placeSection1.append("请填写套内建筑面积")
        placeSection1.append("请选择户型")
        placeSection1.append("请选择房屋类型")
        placeSection1.append("请选择省市区")
        placeSection1.append("请输入小区名称")
        placeSection1.append("请输入详细地址，需精确到单元-门牌号")
        placeSection1.append("请务必根据图纸报价审核结果填写")
        placeSection1.append("请选择签约日期")
        placeSection1.append("请选择开工日期")
        placeSection1.append("请输入工期天数")
        placeSection1.append("周末是否开工")
        placeSection1.append("请选择竣工日期")
        placeHolderArray = [placeSection1, ["请输入备注说明"]];
        
        self.creatUI()
    }
    
    func initData() {
        var section1 = [String]()
        section1.append(upload.name)
        section1.append(upload.mobile)
        section1.append(upload.houseSize)
        section1.append(ESStringUtil.getRoomType(upload.roomType)?.value ?? "")
        section1.append(ESStringUtil.getHouseType(upload.houseType)?.value ?? "")
        section1.append("\(upload.province)\(upload.city)\(upload.district)")
        section1.append(upload.community)
        section1.append(upload.address)
        section1.append(upload.amount)
        section1.append(upload.signDate)
        section1.append(upload.startDate)
        section1.append("\(upload.proNumber)")
        section1.append("")
        section1.append(upload.completeDate)
        var section2 = [String]()
        section2.append(upload.remark)
        actDataArray = [section1, section2];
        
    }
    
    func creatUI() {
        let tvc = UITableViewController(style: .grouped)
        addChildViewController(tvc)
        tableView = tvc.tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        tableView.tableFooterView = UIView.init()
        self.view.addSubview(tableView)
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 50
        tableView.register(UINib.init(nibName: "ESTitleAndTextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "ESTitleAndTextFieldTableViewCell")
        tableView.register(UINib.init(nibName: "ESTextViewTableViewCell", bundle: nil), forCellReuseIdentifier: "ESTextViewTableViewCell")
        tableView.register(UINib.init(nibName: "ESSelectButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ESSelectButtonTableViewCell")
        tableView.register(UINib.init(nibName: "ESSwiftLabelTableViewHeaderFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ESSwiftLabelTableViewHeaderFooterView")
        
        let button = UIButton(frame: .zero)
        
        button.backgroundColor = UIColor.stec_ableButtonBack()
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font  = UIFont.stec_bigTitleFount()
        button.setTitle("确定", for: .normal)
        button.addTarget(self, action: #selector(completeClick), for: .touchUpInside)
        self.view.addSubview(button)
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(button.snp.top)
        }
        button.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(49.scalValue)
        }
        addPickViewForAddress()
        addDateSelector()
    }
    @objc func completeClick() {
        ESProgressHUD.show(in: self.view)
        ESAgreementManager.editContract(upload, success: {
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                if let block = self.AgreeAgreementBlock {
                    block()
                }
                self.navigationController?.popViewController(animated: true)
            }
        }) { (errMsg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: errMsg)
            }
        }
    }
    
    private func addDateSelector(){
        datePicker = ESDatePickerView(controller: self)
    }
    
    //MARK: - ESPickerViewDelegate
    func confirmDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let resultString = dateFormatter.string(from: date)
        switch myIndexPath.row {
        case 9:
            upload.signDate = resultString
            self.setCellInfo(text: resultString, indexPath: myIndexPath)
        case 10:
            upload.startDate = resultString
    
//            let days = Int(upload.proNumber) ?? 0
//            let daysTime = TimeInterval(days * 24 * 60 * 60)
//            let completeDate = Date(timeInterval: daysTime, since: date)
//            let completeDateStr = dateFormatter.string(from: completeDate)
            self.setCellInfo(text: resultString, indexPath: myIndexPath)
//            upload.completeDate = completeDateStr
//            actDataArray[0][13] = completeDateStr
//            self.setCellInfo(text: completeDateStr, indexPath: IndexPath(row: 13, section: myIndexPath.section))
        case 13:
            upload.completeDate = resultString
            self.setCellInfo(text: resultString, indexPath: myIndexPath)
        default:
            break
        }
    }
    
    /// 选择时间
    private func selectDate(index: Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var min: Date?
        var defaultDate: Date?
        switch index {
        case 9:/// 签约日期
            min = Date()
            defaultDate = Date()
            if !ESStringUtil.isEmpty(upload.signDate) {
                defaultDate = dateFormatter.date(from: upload.signDate)
            }
        case 10:/// 开工日期
            if ESStringUtil.isEmpty(upload.signDate) {
                min = Date()
            } else {
                min = dateFormatter.date(from: upload.signDate)
            }
            defaultDate = min
            if !ESStringUtil.isEmpty(upload.startDate) {
                defaultDate = dateFormatter.date(from: upload.startDate)
            }
        case 13:/// 竣工日期
            if ESStringUtil.isEmpty(upload.startDate) {
                min = Date()
                defaultDate = min
            } else {
                let startDate = dateFormatter.date(from: upload.startDate)
                let days = Int(upload.proNumber) ?? 0
                let daysTime = TimeInterval(days * 24 * 60 * 60)
                min = Date(timeInterval: daysTime, since: startDate ?? Date())
            }
            
            if ESStringUtil.isEmpty(upload.completeDate) {
                defaultDate = min
            } else {
                let completeDate = dateFormatter.date(from: upload.completeDate)
                defaultDate = completeDate
            }
        default:
            break
        }
        
        datePicker.show(defaultDate: defaultDate, minDate: min)
    }
    
    /// 选择房屋类型
    private func selectHouseType(){
        addHousePickerView("HousingState")
    }
    
    /// 选择房屋户型
    private func selectHouseRoomType(){
        addHousePickerView("HousingStyle")
    }
    
    /// 选择小区地址
    private func selectCommunityAddress(){
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
        upload.province = info.province
        upload.provinceCode = info.provinceCode
        upload.city = info.city
        upload.cityCode = info.cityCode
        upload.district = info.district
        upload.districtCode = info.districtCode
        self.setCellInfo(text: "\(info.province)\(info.city)\(info.district)", indexPath: myIndexPath)
    }
    
    private func addHousePickerView(_ plistName:String){
        housePickerView = MPPickerView(frame: CGRect.init(x: 0, y: ScreenHeight, width: ScreenWidth, height: 220), plistName: plistName, compontCount: 1, linkage: false, optional: false, style: nil, finish: { (dict) in
            if let dic:[String:String] = dict as? [String : String] {
                let text = String.init(format: "%@", dic["comp1"]!)
                self.setCellInfo(text: text, indexPath: self.myIndexPath)
                
                if plistName == "HousingState" { //房屋类型
                    self.upload.houseType = ESStringUtil.getHouseType(text)?.id ?? ""
                } else if plistName == "HousingStyle" { // 户型
                    self.upload.roomType = ESStringUtil.getRoomType(text)?.id ?? ""
                }
            }
            
            self.housePickerView.hiddenPickerView()
            
        })
        view.addSubview(housePickerView)
        housePickerView.show(in: view)
    }

    func setCellInfo(text :String, indexPath:IndexPath) {
        self.actDataArray[indexPath.section][indexPath.row] = text
        let title = String.init(format: "%@", self.dataArray[indexPath.section][indexPath.row])
        let subTitle = String.init(format: "%@", self.actDataArray[indexPath.section][indexPath.row])
        let placeHolder = String.init(format: "%@", self.placeHolderArray[indexPath.section][indexPath.row])

        if let cell = tableView.cellForRow(at: indexPath)as? ESTitleAndTextFieldTableViewCell {
            var hidden = true;
            switch (indexPath.row) {
            case 3,4,5,8,9,10,13:
                hidden = false
                break
            default:
                hidden = true
                break
            }
            if 2 == indexPath.row {
                cell.setInfo(title: title, subTitle:subTitle, placeHolder: placeHolder, unintTitle: "㎡", hiddenArrow:hidden, indexPath: indexPath)
            } else if 8 == indexPath.row {
                cell.setInfo(title: title, subTitle:subTitle, placeHolder: placeHolder, unintTitle: "元", hiddenArrow:hidden, indexPath: indexPath)
            } else {
                cell.setInfo(title: title, subTitle:subTitle, placeHolder: placeHolder, unintTitle: "", hiddenArrow:hidden, indexPath: indexPath)
            }
        }
    }

}
extension ESAgreementViewController :UITableViewDelegate, UITableViewDataSource, ESEndEditTextDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = String.init(format: "%@", self.dataArray[indexPath.section][indexPath.row])
        let subTitle = String.init(format: "%@", self.actDataArray[indexPath.section][indexPath.row])
        let placeHolder = String.init(format: "%@", self.placeHolderArray[indexPath.section][indexPath.row])
        
        if 0 == indexPath.section {
            if 7 == indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ESTextViewTableViewCell", for: indexPath)as!ESTextViewTableViewCell
                cell.selectionStyle = .none
                let text = String.init(format: "%@", self.actDataArray[indexPath.section][indexPath.row])
                cell.setInfo(title: text, placeHolder: placeHolder, height: 85, indexPath: indexPath as IndexPath)
                cell.delegate = self
                return cell
            } else if 12 == indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ESSelectButtonTableViewCell", for: indexPath)as!ESSelectButtonTableViewCell
                cell.selectionStyle = .none
                let weekend = upload.weekendConstruct == "0" ? false : true
                cell.setBlock(weekend: weekend, block: {[weak self] (_ locationStr : String) in
                    guard let `self` = self else {return}
                    if locationStr == "left" {
                        self.upload.weekendConstruct = "1"
                    } else {
                        self.upload.weekendConstruct = "0"
                    }
//                    self.actDataArray[indexPath.section][indexPath.row] = locationStr;
                })
                cell.selectionStyle = .none;
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ESTitleAndTextFieldTableViewCell", for: indexPath)as!ESTitleAndTextFieldTableViewCell
                cell.selectionStyle = .none
                var hidden = true;
                switch (indexPath.row) {
                case 3,4,5,9,10,13:
                    hidden = false
                    break
                default:
                    hidden = true
                    break
                }
                if 2 == indexPath.row {
                    cell.setInfo(title: title, subTitle:subTitle, placeHolder: placeHolder, unintTitle: "㎡", hiddenArrow:hidden, indexPath: indexPath)
                } else if 8 == indexPath.row {
                    cell.setInfo(title: title, subTitle:subTitle, placeHolder: placeHolder, unintTitle: "元", hiddenArrow:hidden, indexPath: indexPath)
                } else {
                    cell.setInfo(title: title, subTitle:subTitle, placeHolder: placeHolder, unintTitle: "", hiddenArrow:hidden, indexPath: indexPath)
                }
                
                cell.delegate = self
                return cell
            }

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESTextViewTableViewCell", for: indexPath)as!ESTextViewTableViewCell
            cell.selectionStyle = .none
            let text = String.init(format: "%@", self.actDataArray[indexPath.section][indexPath.row])
            cell.setInfo(title: text, placeHolder: placeHolder, height: 145, indexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        myIndexPath = indexPath;
        if 0 == indexPath.section {
            switch indexPath.row {
            case 9,10,13:
                selectDate(index: indexPath.row)
                break
            case 3:
                selectHouseRoomType()
                
                break
            case 4:
                selectHouseType()
                break
            case 5:
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
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESSwiftLabelTableViewHeaderFooterView")as!ESSwiftLabelTableViewHeaderFooterView
        if 0 == section {
            view.setInfo(backColor: UIColor .stec_viewBackground(), title: "ERP编号 \(upload.erpId)", titleColor: UIColor .stec_subTitleText(), subTitle: "", subTitleColor: nil)
        } else {
            view.setInfo(backColor: UIColor.stec_viewBackground(), title: "备注说明", titleColor: UIColor .stec_titleText(), subTitle: "", subTitleColor: nil)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func didFinishedEdit(text: String?, indexPath: IndexPath?) {
        self.actDataArray[(indexPath?.section)!][(indexPath?.row)!] = text!
        
        let section = indexPath?.section ?? -1
        let row = indexPath?.row ?? -1
        let content = text ?? ""
        
        switch section {
        case 0:
            switch row {
            case 0:
                upload.name = content
            case 1:
                upload.mobile = content
            case 2:
                upload.houseSize = content
            case 6:
                upload.community = content
            case 7:
                upload.address = content
            case 8:
                upload.amount = content
            case 11:
                upload.proNumber = content
//                if !ESStringUtil.isEmpty(upload.startDate) {
//                    let days = Int(upload.proNumber) ?? 0
//                    let daysTime = TimeInterval(days * 24 * 60 * 60)
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd"
//                    let startDate = dateFormatter.date(from: upload.startDate) ?? Date()
//                    let completeDate = Date(timeInterval: daysTime, since: startDate)
//                    let completeDateStr = dateFormatter.string(from: completeDate)
//                    upload.completeDate = completeDateStr
//                    actDataArray[0][13] = completeDateStr
//                    self.setCellInfo(text: completeDateStr, indexPath: IndexPath(row: 13, section: myIndexPath.section))
//                }
            default:
                break
            }
        case 1:
            upload.remark = content
        default:
            break
        }
    }
    
}

