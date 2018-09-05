//
//  ESApplyChargebackViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/25.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// 申请退单
class ESApplyChargebackViewController: ESBasicViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentRect:CGRect!
    var uploadDic:Dictionary<String,String> = [:]
    
    private var viewManager = ESFreeAppointViewManager()
    private var assetId = ""
    private var chargebackBlock:(()->Void)?
    
    //MARK: - Init
    init(assetId: String, block:(()->Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.chargebackBlock = block
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
    
    //MARK: - Init UI
    private func initilizeUI(){
        currentRect = CGRect.zero
        uploadDic = ["projectId": assetId, ESCancleAppointUploadDic.CancleInputed.rawValue:""]
        
        setupNavigationTitleWithBack(title: "申请退单")
        
        view.addSubview(viewManager.tableView)
        viewManager.tableView.delegate = self
        viewManager.tableView.dataSource = self
        
        let button = viewManager.commitApply(self)
        view.addSubview(button)
        
        let btnHeight:CGFloat = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        button.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(btnHeight)
        }
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
        viewManager.setTableHeaderViewForChargeback()
    }
    
    //MARK: - Network
    private func chargeback(){
        ESProgressHUD.show(in: view)
        ESAppointApi.cancleOrder(uploadDic, success: { (data) in
            
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: "退款成功")
            if let block = self.chargebackBlock {
                block()
            }
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            MBProgressHUD.showError(SHRequestTool.getErrorMessage(error), to: self.view)
        }
    }
    
    //MARK: - Actions
    @objc func commitApply(){
        print("提交申请")
        if uploadDic[ESCancleAppointUploadDic.CancleInputed.rawValue] != "" {
            chargeback()
        } else {
            ESProgressHUD.showText(in: view, text: "请输入退款原因")
        }
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESCancleAppointReasonTableViewCell", for: indexPath)as!ESCancleAppointReasonTableViewCell
        cell.placeHoldLabel.text = "您可以在这里填写您申请退单的原因哦~"
        cell.setApplyChargebackCellIndex(index: indexPath.row, vc: self)
        return cell
    }
}
