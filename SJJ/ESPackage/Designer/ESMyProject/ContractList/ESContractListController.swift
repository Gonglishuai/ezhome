//
//  ESContractListController.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/13.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

enum ContractListType: String {
    case consumer = "1"
    case designer = "2"
}

enum EntryType {
    case List
    case Detail
}

class ESContractListController: ESBasicViewController, UITableViewDelegate, UITableViewDataSource {
    var info: (orderId: String, amount: Double) = ("", 0.0)
    private var dataArray: [ESPackageContract] = []
    private var assetId: String = ""
    private var type: ContractListType = .consumer
    private var entry: EntryType = .List
    
    init(assetId: String, shouldAgree: Bool, type: ContractListType, entry: EntryType) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.agreeButton.isHidden = !shouldAgree
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        
        setupNavigationTitleWithBack(title: "合同详情")
        view.addSubview(tableView)
        view.addSubview(agreeButton)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
        }
        let btnisHidden = agreeButton.isHidden
        agreeButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview().priority(800)
            make.top.equalTo(tableView.snp.bottom)
            make.height.equalTo(btnisHidden ? 0 : 49.scalValue)
        }
        
        requestData()
    }
    
    private func requestData() {
        ESProgressHUD.show(in: self.view)
        ESContractListManager.getContractList(assetId: assetId, type: type.rawValue, success: { (array) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.dataArray = array
                self.tableView.reloadData()
                if array.count > 0 {
                    ESEmptyView.hideEmptyView(in: self.view)
                } else {
                    ESEmptyView.showEmptyView(in: self.view, image: "package_noData", text: "暂时还未生成合同，请耐心等待...")
                }
            }
        }) { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
            }
        }
    }
    
    @objc private func agreeBtnClick() {
        let payType = entry == .List ? ESPayType.pkgProjectList : ESPayType.pkgProjectDetail
        let vc = ESPayTimesViewController(orderId: "",
                                          payOrderId: info.orderId,
                                          brandId: "",
                                          amount: String(format: "%.2f", info.amount),
                                          partPayment: true,
                                          loanDic: ["":""],
                                          payType: payType,
                                          payTimesType: .again)
        navigationController?.pushViewController(vc!, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESContractListCell") as! ESContractListCell
        if dataArray.count > indexPath.row {
            let model = dataArray[indexPath.row]
            cell.updateCell(text: model.fileName)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataArray.count <= indexPath.row {
            return
        }
        if let url = dataArray[indexPath.row].fileH5Url {
            let vc = JRWebViewController()
            let title = dataArray[indexPath.row].fileName ?? "合同详情"
            vc.setTitle(title, url: url)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        view.dataSource = self
        view.delegate = self
        view.estimatedRowHeight = 55
        view.rowHeight = UITableViewAutomaticDimension
        view.separatorStyle = .none
        view.register(ESContractListCell.self, forCellReuseIdentifier: "ESContractListCell")
        return view
    }()

    private lazy var agreeButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = ESColor.color(sample: .buttonBlue)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(ESContractListController.agreeBtnClick), for: .touchUpInside)
        btn.setTitle("我已阅读并同意以上所有协议", for: .normal)
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 16.0)
        btn.setTitleColor(UIColor.white, for: .normal)
        return btn
    }()
}
