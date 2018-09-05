//
//  ESERPSearchView.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESERPSearchViewDelegate: NSObjectProtocol {
    func getViewModel(viewModel: ESERPSearchViewModel)
    func erpSearch(code: String?)
    func nextButtonClick()
}

class ESERPSearchView: UIView, UITextFieldDelegate {

    private weak var delegate: ESERPSearchViewDelegate?
    private var viewModel: ESERPSearchViewModel = ESERPSearchViewModel()
    
    
    init(delegate: ESERPSearchViewDelegate?) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.delegate = delegate
        setUpView()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView() {
        delegate?.getViewModel(viewModel: viewModel)
        
        consumerContent.text = viewModel.consumerName ?? "--"
        addrContent.text = viewModel.projectAddr ?? "--"
        designerContent.text = viewModel.designerName ?? "--"
        storeContent.text = viewModel.serviceStore ?? "--"
        nextBtn.isEnabled = viewModel.canNext
    }
    
    @objc private func nextBtnClick(sender: UIButton) {
        delegate?.nextButtonClick()
    }
    
    @objc private func tapMainView(sender: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    @objc func searchClick(){
        delegate?.erpSearch(code: erpCodeTextField.text ?? "")
        searchButton.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let originText : NSString = textField.text as NSString? ?? ""
        
        let resultText = originText.replacingCharacters(in: range, with: string)
       
        searchButton.isEnabled = resultText.count >= 1
        
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.erpSearch(code: textField.text)
        textField.endEditing(true)
        return true
    }
    
    private func setUpView() {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESERPSearchView.tapMainView(sender:)))
        self.addGestureRecognizer(tgr)
        self.addSubview(topView)
        self.addSubview(infoView)
        self.addSubview(nextBtn)
    }
    
    private func setConstraint() {
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(120.0)
        }
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(22.5)
            make.height.equalTo(19)
            make.width.greaterThanOrEqualTo(85)
            make.centerX.equalToSuperview()
        }
        erpCodeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(topLabel.snp.bottom).offset(13)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(searchButton.snp.left).offset(-15)
            make.height.equalTo(35)
        }
        
        searchButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(erpCodeTextField.snp.centerY)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
        
        infoView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(13)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.greaterThanOrEqualTo(100)
        }
        consumerTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(13.5)
            make.width.equalTo(53)
            make.height.equalTo(18)
        }
        consumerContent.snp.makeConstraints { (make) in
            make.left.equalTo(consumerTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-13.5)
            make.top.equalTo(consumerTitle)
            make.height.greaterThanOrEqualTo(18)
        }
        addrTitle.snp.makeConstraints { (make) in
            make.top.equalTo(consumerContent.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(13.5)
            make.width.equalTo(53)
            make.height.equalTo(18)
        }
        addrContent.snp.makeConstraints { (make) in
            make.left.equalTo(addrTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-13.5)
            make.top.equalTo(addrTitle)
            make.height.greaterThanOrEqualTo(18)
        }
        designerTitle.snp.makeConstraints { (make) in
            make.top.equalTo(addrContent.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(13.5)
            make.width.equalTo(53)
            make.height.equalTo(18)
        }
        designerContent.snp.makeConstraints { (make) in
            make.left.equalTo(designerTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-13.5)
            make.top.equalTo(designerTitle)
            make.height.greaterThanOrEqualTo(18)
        }
        storeTitle.snp.makeConstraints { (make) in
            make.top.equalTo(designerContent.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(13.5)
            make.width.equalTo(53)
            make.height.equalTo(18)
        }
        storeContent.snp.makeConstraints { (make) in
            make.left.equalTo(storeTitle.snp.right).offset(15)
            make.right.equalToSuperview().offset(-13.5)
            make.top.equalTo(storeTitle)
            make.height.greaterThanOrEqualTo(18)
            make.bottom.equalToSuperview().offset(-18).priority(800)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(49)
        }
    }
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        view.addSubview(topLabel)
        view.addSubview(erpCodeTextField)
        view.addSubview(searchButton)
        return view
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ESColor.color(hexColor: 0x93D7EF, alpha: 1)

        button.setTitle("搜索", for: .normal)
        button.setTitleColor(ESColor.color(sample: .subTitleColorA), for: .normal)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 14)
        button.isEnabled = false
        button.addTarget(self, action: #selector(searchClick), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        let normal = ESColor.getImage(color: ESColor.color(sample: .buttonBlue))
        let disabled = ESColor.getImage(color: ESColor.color(hexColor: 0x93D7EF, alpha: 1))
        button.setBackgroundImage(normal, for: .normal)
        button.setBackgroundImage(normal, for: .highlighted)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 3
        
        return button
    }()
    
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.text = "请输入ERP编号"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorA)
        return label
    }()
    
    private lazy var erpCodeTextField: UITextField = {
        let textField = UITextField()
        let width = 25.0
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        let imgView = UIImageView(image: ESPackageAsserts.bundleImage(named: "erp_search"))
        view.addSubview(imgView)
        imgView.center = CGPoint(x: width / 2, y: width / 2)
        textField.leftView = view
        textField.leftViewMode = .always
        textField.borderStyle = .none
        textField.backgroundColor = ESColor.color(sample: .separatorLine)
        textField.layer.cornerRadius = 3.0
        textField.layer.masksToBounds = true
        textField.delegate = self
        textField.returnKeyType = .search
        return textField
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = ESColor.color(sample: .separatorLine).cgColor
        view.layer.cornerRadius = 3.0
        view.layer.masksToBounds = true
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        view.addSubview(consumerTitle)
        view.addSubview(consumerContent)
        view.addSubview(addrTitle)
        view.addSubview(addrContent)
        view.addSubview(designerTitle)
        view.addSubview(designerContent)
        view.addSubview(storeTitle)
        view.addSubview(storeContent)
        return view
    }()
    
    private lazy var consumerTitle: UILabel = {
        let label = UILabel()
        label.text = "业主姓名"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        return label
    }()
    
    private lazy var consumerContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        label.text = "--"
        label.numberOfLines = 0
        return label
    }()

    private lazy var addrTitle: UILabel = {
        let label = UILabel()
        label.text = "项目地址"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        return label
    }()
    
    private lazy var addrContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        label.text = "--"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var designerTitle: UILabel = {
        let label = UILabel()
        label.text = "设计师"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        return label
    }()
    
    private lazy var designerContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        label.text = "--"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var storeTitle: UILabel = {
        let label = UILabel()
        label.text = "服务门店"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        return label
    }()
    
    private lazy var storeContent: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(sample: .subTitleColorB)
        label.text = "--"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var nextBtn: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.backgroundColor = UIColor.clear
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        let normal = ESColor.getImage(color: ESColor.color(sample: .buttonBlue))
        let disabled = ESColor.getImage(color: ESColor.color(sample: .buttonDisable))
        button.setBackgroundImage(normal, for: .normal)
        button.setBackgroundImage(normal, for: .highlighted)
        button.setBackgroundImage(disabled, for: .disabled)
        button.titleLabel?.font = ESFont.font(name: .regular, size: 13.0)
        button.addTarget(self, action: #selector(ESERPSearchView.nextBtnClick(sender:)), for: .touchUpInside)
        return button
    }()
}
