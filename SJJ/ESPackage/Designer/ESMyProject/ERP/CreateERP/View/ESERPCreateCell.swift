//
//  ESERPCreateCell.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESERPCreateCellDelegate: NSObjectProtocol {
    func getViewModel(_ index: Int) -> ESERPCreateViewModel
    func textFieldComplete(viewModel: ESERPCreateViewModel)
}

class ESERPCreateCell: UITableViewCell, UITextFieldDelegate {

    weak var delegate: ESERPCreateCellDelegate?
    private var itemModel: ESERPCreateViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ index: Int, _ section: Int) {
        if let model = delegate?.getViewModel(index) {
            itemModel = model
            title.text = itemModel.title
            title.isHidden = ESStringUtil.isEmpty(itemModel.title)
            
            let left = ESStringUtil.isEmpty(itemModel.title) ? 15 : 115
            let right = itemModel.isSelectedItme ? -30 : -15
            content.text = itemModel.itemContent
            content.placeholder = itemModel.placeholder
            content.isEnabled = !itemModel.isSelectedItme
            if itemModel.key == .designer || itemModel.key == .consumerMobile {
                content.keyboardType = .phonePad
            } else {
                content.keyboardType = .default
            }
            content.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(left)
                make.right.equalToSuperview().offset(right)
                make.height.equalTo(21)
                make.top.equalToSuperview().offset(12.5)
            }
            
            arrowImgView.isHidden = !itemModel.isSelectedItme
        }
    }
    
    private func setUpViews() {
        self.contentView.addSubview(title)
        self.contentView.addSubview(content)
        self.contentView.addSubview(arrowImgView)
        self.contentView.addSubview(bottomLine)
        title.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(17.5)
            make.width.greaterThanOrEqualTo(61)
            make.height.equalTo(21)
            make.top.equalToSuperview().offset(12.5)
        }
        arrowImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(title)
            make.width.equalTo(5)
            make.height.equalTo(10)
        }
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(17.5)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(content.snp.bottom).offset(15)
            make.bottom.equalToSuperview().priority(800)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        itemModel.itemContent = textField.text
        delegate?.textFieldComplete(viewModel: itemModel)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = ESFont.font(name: .regular, size: 14.0)
        return label
    }()
    
    lazy var content: UITextField = {
        let textField = UITextField()
        textField.returnKeyType = .done
        textField.delegate = self
        textField.font = ESFont.font(name: .regular, size: 13.0)
        return textField
    }()
    
    lazy var arrowImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = ESPackageAsserts.bundleImage(named: "arrow_right")
        return imgView
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .separatorLine)
        return view
    }()
}
