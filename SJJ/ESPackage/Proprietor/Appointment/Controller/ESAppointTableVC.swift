//
//  ESAppointTableVC.swift
//  EZHome
//
//  Created by Admin on 2018/8/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit

fileprivate let ADDR_PICKERVIEW_HEIGHT = 260
fileprivate let ADDR_TOOLBAR_HEIGHT = 44

class ESAppointTableVC: UITableViewController,ESRegionPickerViewDelegate {
    
    @IBOutlet weak var lastCell: UITableViewCell!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var homeNameTxt: UITextField!
    @IBOutlet weak var BigTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var tipsLabel: UILabel!
    private var decorationStyle = [ESAppointDecorateStyleModel]()
    var uploadDic:Dictionary<String,String> = [:]
    @IBOutlet weak var styleBtnCell: UITableViewCell!
    
    let styleBtnW = (ScreenWidth - 100) / 4
    @objc var selectStytleArr = [String]()
    private var selectRegion = ESSelectedRegion()
    private var pickerView:ESRegionPickerView!
    @objc var selectedType = 5//外部需要传    套餐：5  个性化：7  其他：6
    @objc var pkgType = 0//外部需要传
    var isShowStyle = true
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadDic = ESCreateProjectModel.uploadDicForFreeAppoint()
        self.styleBtnCell.isHidden = !isShowStyle
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        if isShowStyle {
            self.getDecorationStyle()
        }
        lastCell.separatorInset = UIEdgeInsetsMake(0, ScreenWidth, 0, 0);
        self.addPickViewForAddress()
        
        self.tipsLabel.attributedText = self.attrbutstring(differentStr: "3", totalStr: self.tipsLabel.text!, color: UIColor.stec_redText())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func getDecorationStyle(){
        ESAppointDataManager.getDecorationStyle({ (style) in
            self.decorationStyle = style
        for (index,model) in self.decorationStyle.enumerated() {
            let btn = UIButton()
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = 5
            btn.layer.borderWidth = 1
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.setTitleColor(ESColor.color(hexColor: 0x2D2D34, alpha: 1.0), for: .normal)
            btn.layer.borderColor = ESColor.color(hexColor: 0xC7C7C7, alpha: 1.0).cgColor
            btn.setTitleColor(ESColor.color(hexColor: 0x6A91FE, alpha: 1.0), for: .selected)
            btn.tag = index
            btn.setTitle(model.styleName, for: .normal)
            btn.addTarget(self, action: #selector(self.selectBtnClick(btn:)), for: .touchUpInside)
            let x = (index % 4 * Int(self.styleBtnW)) + (index % 4 * 20)
            btn.frame = CGRect.init(x: 20 + x, y: index < 4 ? 50 : 90, width: Int(self.styleBtnW), height: 30)
            self.styleBtnCell.addSubview(btn)
        }
        }) {(error) in
            ESProgressHUD.showText(in: self.view, text: SHRequestTool.getErrorMessage(error))
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 8 && !isShowStyle{
            return 0.0
        }
        if indexPath.row == 8 && isShowStyle{
            return 132.0
        }
        if indexPath.row == 9 {
            return 170.0
        }
        if indexPath.row == 0 {
            return 40.0
        }
        if indexPath.row == 3  || indexPath.row == 7 {
            return 10.0
        }
        return 53
    }
    
    @objc func selectBtnClick(btn:UIButton) {
        if self.selectStytleArr.count > 2 && !btn.isSelected {
            ESProgressHUD.showText(in: self.view, text: "仅支持3个选项哦")
            return
        }
        btn.isSelected = !btn.isSelected
        btn.isSelected ? self.selectStytleArr.append(self.decorationStyle[btn.tag].styleEnglish ?? "") : self.selectStytleArr.remove(self.decorationStyle[btn.tag].styleEnglish ?? "")
        btn.layer.borderColor = ESColor.color(hexColor: btn.isSelected ? 0x6A91FE : 0xC7C7C7 , alpha: 1.0).cgColor
    }

    @IBAction func subminBtnClick(_ sender: Any){
//        if let selectedType = self.selectedType{
           self.uploadDic[ESFreeAppointUploadDic.SelectedType.rawValue] = "\(selectedType)"
//        }
        if self.pkgType != 0 {
           self.uploadDic[ESFreeAppointUploadDic.PkgType.rawValue] = "\(self.pkgType)"
        }
        self.uploadDic[ESFreeAppointUploadDic.YourName.rawValue] = nameTxt.text
        self.uploadDic[ESFreeAppointUploadDic.Phone.rawValue] = phoneTxt.text
        self.uploadDic[ESFreeAppointUploadDic.HouseArea.rawValue] = BigTxt.text
        self.uploadDic[ESFreeAppointUploadDic.CommunityName.rawValue] = homeNameTxt.text
        self.uploadDic[ESFreeAppointUploadDic.DesignStyle.rawValue] = isShowStyle ? self.selectStytleArr.joined() : ""
        if ESAppointDataManager.checkInputedMessage(uploadDic, target: self) {
            appointImmediately()
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
    
    @IBAction func showAddressView(_ sender: Any) {
        self.pickerView.show(
            province: selectRegion.provinceCode,
            city: selectRegion.cityCode,
            district: selectRegion.districtCode)
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
     //    MARK:打电话
    @IBAction func telephoneAction(_ sender: UIButton) {
        let alertView = UIAlertController(title: "400-650-3333", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let callAction = UIAlertAction(title: "呼叫", style: .default) { (action) in
            UIApplication.shared.openURL(NSURL(string: "tel://4006503333")! as URL)
        }
        
        alertView.addAction(cancelAction)
        alertView.addAction(callAction)
        self.navigationController?.present(alertView, animated: true, completion: nil)
        
    }
   
    
    
    //MARK: - ESRegionPickerViewDelegate
    func confirmAddress(info: ESSelectedRegion) {
        self.selectRegion = info
        self.uploadDic = ESAppointDataManager.fixAppointMessage(info, uploadDic: self.uploadDic)
        addressTxt.text = "\(info.province)\(info.city)\(info.district)"
    }
    
    
    func attrbutstring(differentStr:String,totalStr:String,color:UIColor) -> NSAttributedString {
        let attrstring:NSMutableAttributedString = NSMutableAttributedString(string:totalStr)
        
        let totalS = totalStr as NSString
        let location = totalS.range(of: differentStr).location as Int
        
        attrstring.addAttributes([NSAttributedStringKey.foregroundColor: color], range: NSRange.init(location: location, length: differentStr.count))
        
        return attrstring
    }
}
