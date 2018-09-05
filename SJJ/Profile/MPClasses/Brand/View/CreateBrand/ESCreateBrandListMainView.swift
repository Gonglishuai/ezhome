//
//  ESCreateBrandListMainView.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESCreateBrandListMainViewDelegate: NSObjectProtocol {
    ///创建
    func creatBrandList(upload:Dictionary<String,Any>)
    ///添加品牌
    func addBrand()
    ///删除
    func deleteBrand(cellIndexPath: IndexPath)
}

class ESCreateBrandListMainView: UIView,UITableViewDelegate, UITableViewDataSource {
    
    var uploadDic:Dictionary<String,Any> = [:]
    
    private weak var mainViewDelegate: ESCreateBrandListMainViewDelegate?
    
    private var tableView: UITableView!
    private var creayeButton:UIButton!

    private var brandList = ESBrandBigTytpe()
    private var brandListName = ""
    private var brandListDescription = ""
    
    init(delegate: ESCreateBrandListMainViewDelegate?) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        self.mainViewDelegate = delegate
        setUpSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSubView() {
        
        uploadDic["name"] = ""
        uploadDic["description"] = ""
        uploadDic["itemList"] = []
        
        let btnHeight:CGFloat = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        
        tableView = ESUIViewFactory.tableView(.plain)
        tableView.estimatedRowHeight = 50
        
        self.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib.init(nibName: "ESCreatBrandListFirstCell", bundle: nil), forCellReuseIdentifier: "ESCreatBrandListFirstCell")
        tableView.register(UINib.init(nibName: "ESCreatBrandListSecondCell", bundle: nil), forCellReuseIdentifier: "ESCreatBrandListSecondCell")
        tableView.register(UINib.init(nibName: "ESCreatBrandListThirdCell", bundle: nil), forCellReuseIdentifier: "ESCreatBrandListThirdCell")
        tableView.register(UINib.init(nibName: "ESCreatBrandListRecommdListCell", bundle: nil), forCellReuseIdentifier: "ESCreatBrandListRecommdListCell")
        
        tableView.register(ESCreatBrandListSectionFooterView.self, forHeaderFooterViewReuseIdentifier: "ESCreatBrandListSectionFooterView")
        tableView.register(ESCreateBrandListRecommdReasonSectionHeader.self, forHeaderFooterViewReuseIdentifier: "ESCreateBrandListRecommdReasonSectionHeader")
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-btnHeight)
        }
        addCreateButton(btnHeight)
    }
    
    private func addCreateButton(_ btnHeight:CGFloat) { //创建
        
        creayeButton = ESUIViewFactory.button("创建")
        self.addSubview(creayeButton)
        
        creayeButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(btnHeight)
        }
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            creayeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
        creayeButton.addTarget(self, action: #selector(creatBrandList), for: .touchUpInside)
    }
    
    //MARK: - Public Methods
    func setCreateButtonTitle(title:String){
        creayeButton.setTitle(title, for: .normal)
    }
    
    func setBrandListName(name:String, description:String){
        self.brandListName = name
        self.brandListDescription = description
        uploadDic["name"] = name
        uploadDic["description"] = description
    }
    
    func reloadTableView(brandList:ESBrandBigTytpe, scrollToBottom:Bool){
        self.brandList = brandList
        tableView.reloadData()
        if scrollToBottom {
            let indexPath = IndexPath(row: 0, section:3)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func creatBrandList(){
        if let delegate = mainViewDelegate {
            
            self.endEditing(true)
            
            if checkUploadData() {
                delegate.creatBrandList(upload: uploadDic)
            }
        }
    }
    
    private func checkUploadData() -> Bool {
        
        let name:String = uploadDic["name"] as! String
        
        if !name.isEmpty {
            
            let tmpString = "^[A-Za-z\\u4E00-\\u9FA5]+$"//限制只输入英文、汉字 （@"[a-zA-Z0-9\u4e00-\u9fa5]+$"//中文、英文、数字）
            let predicate = NSPredicate(format: "SELF MATCHES %@", tmpString)
            
            let isMatchDetail = predicate.evaluate(with: name)
            
            if !isMatchDetail {
                ESProgressHUD.showText(in: self, text: "请输入2-20字符汉字、英文")
                return false
            }
        } else {
            ESProgressHUD.showText(in: self, text: "请输入客户姓名")
            return false
        }
        
//        let description:String = uploadDic["description"] as! String
//        
//        if description.isEmpty {
//            ESProgressHUD.showText(in: self, text: "请输入清单介绍")
//            return false
//        }
        
        var itemList = [Dictionary<String,String>]()
        for model in brandList {
            var brands:Dictionary<String,String> = [:]
            brands["brandId"] = model.id ?? ""
            brands["description"] = model.description ?? ""
            itemList.append(brands)
        }
        
        let brandCount = brandList.count
        if brandCount == 0 {
            ESProgressHUD.showText(in: self, text: "每个清单最少需推荐1个品牌")
            return false
        } else if brandCount > 50 {
            ESProgressHUD.showText(in: self, text: "每个清单最多可推荐50个品牌，您已超出\(brandCount - 50)个")
            return false
        }
        
        uploadDic["itemList"] = itemList
        return true
        
    }
    
    //MARK: -  UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if brandList.isEmpty {
            return 3
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 2:
            if brandList.isEmpty {
                return 1
            } else {
                return brandList.count
            }
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESCreatBrandListFirstCell", for: indexPath)as!ESCreatBrandListFirstCell
            cell.setCellDelegate(delegate: self)
            if !brandListName.isEmpty {
                cell.listName.text = brandListName
            }
            return cell
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESCreatBrandListSecondCell", for: indexPath)as!ESCreatBrandListSecondCell
            cell.setCellDelegate(delegate: self)
            if !brandListDescription.isEmpty {
                cell.setTextViewText(text: brandListDescription)
            }
            return cell
            
        case 2:
            
            if brandList.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ESCreatBrandListThirdCell", for: indexPath)as!ESCreatBrandListThirdCell
                
                cell.setCellDelegate(delegate: self)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ESCreatBrandListRecommdListCell", for: indexPath)as!ESCreatBrandListRecommdListCell
                
                cell.setDelegate(delegate: self, indexPath: indexPath)
                
                let model = brandList[indexPath.row]
                
                cell.setCellModel(model: model)
                
                return cell
            }
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESCreatBrandListThirdCell", for: indexPath)as!ESCreatBrandListThirdCell
            
            cell.setCellDelegate(delegate: self)
            
            return cell
        default:
            return UITableViewCell()
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 2:
            if brandList.isEmpty {
                return CGFloat.leastNormalMagnitude
            } else {
                return 35
            }
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 2:
            if brandList.isEmpty {
                return nil
            } else {
                let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESCreateBrandListRecommdReasonSectionHeader")as!ESCreateBrandListRecommdReasonSectionHeader
                view.brandNumber.text = "\(brandList.count)个品牌"
                return view
            }
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 || section == 1 {
            return 10
        } else {
            return CGFloat.leastNormalMagnitude
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ESCreatBrandListSectionFooterView")as!ESCreatBrandListSectionFooterView
        
        if section == 0 || section == 1 {
            return view
        } else {
            return nil
        }
    }
}

extension ESCreateBrandListMainView:ESCreatBrandListRecommdListCellProtocol {
    
    func gotTextViewText(text: String, indexPath: IndexPath) {
        
        var model = brandList[indexPath.row]
        
        model.description = text
        
        brandList[indexPath.row] = model
        
    }
    
    func deleteBrand(cellIndexPath: IndexPath) {
        if let delegate = mainViewDelegate {
            delegate.deleteBrand(cellIndexPath: cellIndexPath)
        }
        brandList.remove(at: cellIndexPath.row)
        tableView.reloadData()
    }
    
}

extension ESCreateBrandListMainView:ESCreatBrandListThirdCellProtocol {
    func addBrand() {
        if let delegate = mainViewDelegate {
            delegate.addBrand()
        }
    }
}
extension ESCreateBrandListMainView:ESCreatBrandListFirstCellProtocol {
    func textFiledText(text: String) {
        uploadDic["name"] = text
        self.brandListName = text
    }
}

extension ESCreateBrandListMainView:ESCreatBrandListSecondCellProtocol {
    func textViewText(text: String) {
        uploadDic["description"] = text
        self.brandListDescription = text
    }
}
