//
//  ESCancleAppointViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/25.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

enum ESCancleAppointUploadDic:String {
    case CancleSelected = "reason"
    case CancleInputed = "remark"
}
/// 取消预约
class ESCancleAppointViewController: ESBasicViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentRect:CGRect!
    var uploadDic:Dictionary<String,String> = [:]
    var selectedIcon = [false,false,false,false,false]
    
    private var viewManager = ESFreeAppointViewManager()
    private let reason = ["信息填写错误，要重新预约","不装修了","准备在其他装饰公司装修","我对服务人员不满意","其他原因"]
    private var assetId = ""
    private var canaleBlcok:(()->Void)?
    
    //MARK: - Init
    init(assetId:String, block:(()->Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.canaleBlcok = block
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Style
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizeUI()
        addNotifation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Network
    private func requestData(){
        ESProgressHUD.show(in: view)
        ESAppointApi.cancleAppointWith(assetId, parm: uploadDic, success: { (responseData) in
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: "已取消预约")
            if let block = self.canaleBlcok {
                block()
            }
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: "啊哦，操作失败了")
        }
    }
    //MARK: - Init UI
    private func initilizeUI(){
        currentRect = CGRect.zero
        uploadDic = [ESCancleAppointUploadDic.CancleSelected.rawValue:"",
                     ESCancleAppointUploadDic.CancleInputed.rawValue:""]
        
        setupNavigationTitleWithBack(title: "取消预约")
        
        view.addSubview(viewManager.tableView)
        viewManager.tableView.delegate = self;
        viewManager.tableView.dataSource = self;
        
        let button = viewManager.conformCancle(self)
        view.addSubview(button)
        
        let btnHeight:CGFloat = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        button.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(btnHeight.scalValue)
        }
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
    }
    
    //MARK: - Actions
    func reloadView(){
        viewManager.tableView.reloadData()
    }
    
    @objc func conformCancleClick(){
        if checkTheReason() {
            print("确定取消:\(uploadDic)")
            requestData()
        }
    }
    
    private func checkTheReason()->Bool{
        if uploadDic[ESCancleAppointUploadDic.CancleSelected.rawValue] == ""{
            ESProgressHUD.showText(in: self.view, text: "请您选择取消原因")
            return false
        }
        
        return true
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
    
    //MARK: -  UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESCancleAppointReasonTableViewCell", for: indexPath)as!ESCancleAppointReasonTableViewCell
            cell.setCellIndex(index: indexPath.row, vc: self)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESCancleAppointTableViewCell", for: indexPath)as!ESCancleAppointTableViewCell
            cell.setCellIndex(index: indexPath.row, vc: self)
            cell.setIconImage(selectedIcon[indexPath.row])
            cell.setCancleReason(reason[indexPath.row])
            return cell
        }
    }
    
}
