//
//  ESFreeAppointFirstCollectionViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESFreeAppointFirstCollectionViewCell: UICollectionViewCell {
    
    //MARK: - setter and gatter
    lazy var  backView = UIView()
    
    lazy var leftIcon = UIImageView()
    
    lazy var sourceTitle: UILabel = {
        var label = UILabel()
        label.textColor = ESColor.color(sample: .textGray)
        label.font = ESFont.font(name: .regular, size: 14)
        return label
    }()
    
    lazy var rightIcon: UIImageView = {
        var icon = UIImageView(image: ESPackageAsserts.bundleImage(named: "arrow_right"))
        return icon
    }()
    
    lazy var sourceTextFiled: UITextField = {
        var textfiled = UITextField()
        textfiled.textColor = ESColor.color(sample: .mainTitleColor)
        textfiled.font = ESFont.font(name: ESFont.ESFontName.medium, size: 14)
        return textfiled
    }()
    
    private var cellIndex:NSInteger = 0
    private weak var viewController:ESFreeAppointViewController?
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(contentView.snp.top)
            make.height.equalTo(54)
            make.bottom.equalTo(contentView.snp.bottom).offset(-14).priority(250)
        }
        backView.layer.masksToBounds = true
        backView.layer.borderWidth = 0.5
        backView.layer.borderColor = ESColor.color(sample: .separatorLine).cgColor
        
        backView.addSubview(leftIcon)
        leftIcon.snp.makeConstraints { (make) in
            make.left.equalTo(19)
            make.centerY.equalTo(backView.snp.centerY)
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
        
        backView.addSubview(sourceTitle)
        
        sourceTitle.snp.makeConstraints { (make) in
            make.left.equalTo(leftIcon.snp.right).offset(15)
            make.centerY.equalTo(backView.snp.centerY)
            make.height.equalTo(20)
        }
        
        backView.addSubview(rightIcon)
        rightIcon.snp.makeConstraints { (make) in
            make.right.equalTo(backView.snp.right).offset(-10)
            make.centerY.equalTo(backView.snp.centerY)
            make.size.equalTo(CGSize(width: 5, height: 10))
        }
        
        backView.addSubview(sourceTextFiled)
        sourceTextFiled.snp.makeConstraints { (make) in
            make.left.equalTo(leftIcon.snp.right).offset(15)
            make.bottom.equalTo(backView.snp.bottom).offset(-8)
            make.size.equalTo(CGSize(width: ScreenWidth - 100, height: 20))
        }
        sourceTextFiled.isHidden = true
        
        sourceTextFiled.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod))
        self.addGestureRecognizer(tap)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Action
    @objc func tapMethod(tap:UITapGestureRecognizer){
        
        changeTheCellStyle()
    }
    
    func changeTheCellStyle(){
        
        changeIcon()
        
        self.sourceTitle.font = ESFont.font(name: ESFont.ESFontName.medium, size: 11)
        self.sourceTitle.textColor = ESColor.color(sample: .textGray)
        self.sourceTextFiled.isHidden = false
        
        self.sourceTitle.snp.remakeConstraints { (make) in
            make.left.equalTo(self.leftIcon.snp.right).offset(15)
            make.top.equalTo(9)
            make.height.equalTo(14)
        }
        
        self.sourceTextFiled.snp.remakeConstraints { (make) in
            make.left.equalTo(self.leftIcon.snp.right).offset(15)
            make.top.equalTo(27)
            make.size.equalTo(CGSize(width: ScreenWidth - 80, height: 20))
            make.bottom.equalTo(backView.snp.bottom).offset(-6).priority(250)
        }
        
        if cellIndex == 2 {
            sourceTextFiled.keyboardType = .decimalPad
        } else if cellIndex == 1 {
            sourceTextFiled.keyboardType = .numberPad
        } else {
            sourceTextFiled.keyboardType = .default
        }
        if let viewController = self.viewController {
            if cellIndex == 3 {
                viewController.showDecorationBudget()
                return
            } else if cellIndex == 4 {
                viewController.showHouseType()
                return
            } else if cellIndex == 5 {
                viewController.showCommunityAddress()
                return
            }
        }
        
        self.sourceTextFiled.becomeFirstResponder()
    }
    
    private func changeIcon(){
        var leftIconName = ""
        if let viewController = self.viewController {
            leftIconName = viewController.cellData[cellIndex].blackIcon
        }
        self.leftIcon.image = ESPackageAsserts.bundleImage(named: leftIconName)
    }
    
    func setCreateProjectModel( model:(title:String, grayIcon:String, blackIcon:String), cellIndex:NSInteger, vc:ESFreeAppointViewController){
        
        self.cellIndex = cellIndex
        self.viewController = vc
        
        if 3 == cellIndex || 4 == cellIndex || 5 == cellIndex {
            sourceTextFiled.isEnabled = false
            rightIcon.isHidden = false
        } else {
            sourceTextFiled.isEnabled = true
            rightIcon.isHidden = true
        }
        
        leftIcon.image = ESPackageAsserts.bundleImage(named: model.grayIcon)
        sourceTitle.text = model.title
        
    }
    
    func setTextFieldContent(_ content: String?) {
        sourceTextFiled.text = content
    }
    
    func setCommuntyAddress(_ model:ESSelectedRegion){
        if 5 == cellIndex {
            sourceTextFiled.text = "\(model.province)\(model.city)\(model.district)"
        }
    }
    
    func setHouseTypeAndBugdge(_ dict:[String:String]){
        let sourceText = dict["comp1"] ?? ""
        if let viewController = self.viewController {
            
            if 3 == cellIndex {
                sourceTextFiled.text = sourceText
                viewController.uploadDic[ESFreeAppointUploadDic.DecorationBudget.rawValue] = sourceText
            } else if 4 == cellIndex {
                sourceTextFiled.text = sourceText
                viewController.uploadDic[ESFreeAppointUploadDic.HouseType.rawValue] = ESStringUtil.getHouseType(sourceText)?.id ?? ""
            }
        }
    }
    
}

extension ESFreeAppointFirstCollectionViewCell:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let viewController = self.viewController {
            
            viewController.currentRect = ESCGRectUtil.getRelativeCGrect(view: textField)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let originText : NSString = textField.text as NSString? ?? ""
        
        let resultText = originText.replacingCharacters(in: range, with: string)
        
        switch cellIndex {
        case 0:
            if resultText.count > 15 && resultText.count > originText.length {//限制位数
                return false
            }
            break
        case 1:
            if resultText.count > 11 && resultText.count > originText.length {//限制位数
                return false
            }
            break
        case 2:

            return ESFormCheck.checkHouseSizeForm(textField: textField, range: range, string: string)
        case 6:
            if resultText.count > 15 && resultText.count > originText.length {//限制位数
                return false
            }
            break
        default:
            break
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text:String = textField.text ?? ""
        
        if let viewController = self.viewController {

            switch cellIndex {
            case 0:
                viewController.uploadDic[ESFreeAppointUploadDic.YourName.rawValue] = text
                break
            case 1:
                viewController.uploadDic[ESFreeAppointUploadDic.Phone.rawValue] = text
                break
            case 2:
                let fixedText =  ESFormCheck.fixInputedHouseSize(text: text)
                textField.text = fixedText
                viewController.uploadDic[ESFreeAppointUploadDic.HouseArea.rawValue] = fixedText
                break
            case 6:
                viewController.uploadDic[ESFreeAppointUploadDic.CommunityName.rawValue] = text
                break
            default:
                break
            }
        }
        return true
    }
}
