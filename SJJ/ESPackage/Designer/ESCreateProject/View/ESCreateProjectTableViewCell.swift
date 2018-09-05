//
//  ESCreateProjectTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESCreateProjectTableViewCell: UITableViewCell {
    
    //MARK: - setter and gatter
    lazy var leftIcon = UIImageView()
    
    lazy var sourceTitle: UILabel = {
        var label = UILabel()
        label.textColor = ESColor.color(sample: .mainTitleColor)
        label.font = UIFont.systemFont(ofSize: 14)
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
    private weak var viewController:ESCreateProjectViewController?
    
    //MARK: - init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let line = UIView()
        line.backgroundColor = UIColor.groupTableViewBackground
        contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.size.equalTo(CGSize(width: ScreenWidth, height: 0.5))
        }
        
        contentView.addSubview(leftIcon)
        leftIcon.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.centerY.equalTo(contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 13, height: 13))
        }
        
        contentView.addSubview(sourceTitle)
        sourceTitle.snp.makeConstraints { (make) in
            make.left.equalTo(leftIcon.snp.right).offset(15)
            make.centerY.equalTo(contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 150, height: 20))
        }
        
        contentView.addSubview(rightIcon)
        rightIcon.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.right).offset(-15)
            make.centerY.equalTo(contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 5, height: 10))
        }
        
        let line1 = UIView()
        line1.backgroundColor = UIColor.groupTableViewBackground
        contentView.addSubview(line1)
        line1.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(52.5)
            make.size.equalTo(CGSize(width: ScreenWidth, height: 0.5))
        }
        
        contentView.addSubview(sourceTextFiled)
        sourceTextFiled.snp.makeConstraints { (make) in
            make.left.equalTo(leftIcon.snp.right).offset(15)
            make.bottom.equalTo(contentView.snp.bottom).offset(-8)
            make.size.equalTo(CGSize(width: ScreenWidth - 80, height: 20))
        }
        sourceTextFiled.isHidden = true
        
        sourceTextFiled.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod))
        self.addGestureRecognizer(tap)
    }
    
    @objc func tapMethod(tap:UITapGestureRecognizer){
        
        changeTheCellStyle(true)
        cellActions()
    }
    
    func changeTheCellStyle(_ openKeyboard:Bool){
        
        changeIcon()
        
        self.sourceTitle.font = ESFont.font(name: ESFont.ESFontName.regular, size: 10)
        self.sourceTitle.textColor = ESColor.color(sample: .subTitleColor)
        self.sourceTextFiled.isHidden = false
        
        self.sourceTitle.snp.remakeConstraints { (make) in
            make.left.equalTo(self.leftIcon.snp.right).offset(15)
            make.top.equalTo(9)
            make.size.equalTo(CGSize(width: 150, height: 14))
        }
        
        self.sourceTextFiled.snp.remakeConstraints { (make) in
            make.left.equalTo(self.leftIcon.snp.right).offset(15)
            make.top.equalTo(25)
            make.bottom.equalTo(-8)
            make.size.equalTo(CGSize(width: ScreenWidth - 80, height: 20))
        }
        if cellIndex == 6{
            sourceTextFiled.keyboardType = .decimalPad
        } else if cellIndex == 1 {
            sourceTextFiled.keyboardType = .numberPad
        } else {
            sourceTextFiled.keyboardType = .default
        }
        
        if openKeyboard {
            self.sourceTextFiled.becomeFirstResponder()
        }
    }
    
    private func cellActions(){
        
        if let viewController = self.viewController {
            switch cellIndex {
            case 2:
                viewController.showHouseAddress()
                break
            case 4:
                viewController.showHouseType()
                break
            case 5:
                viewController.showRoomType()
                break
            case 7:
                viewController.showProjectType()
                break
            default:
                break
            }
        }
    }
    
    private func changeIcon(){
        
        var leftIconName = ""
        
        if let viewController = self.viewController {
            leftIconName = viewController.cellData[cellIndex].blackIcon
        }
        self.leftIcon.image = ESPackageAsserts.bundleImage(named: leftIconName)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - setter
    func setHouseTypeAndBugdge(_ dict:[String:String]){
        let sourceText = dict["comp1"] ?? ""
        if let viewController = self.viewController {
            
            if 4 == cellIndex {
                sourceTextFiled.text = sourceText
                viewController.uploadDic[ESCreateProjectUploadDic.HouseType.rawValue] = ESStringUtil.getHouseType(sourceText)?.id ?? ""
            } else if 5 == cellIndex {
                sourceTextFiled.text = sourceText
                viewController.uploadDic[ESCreateProjectUploadDic.RoomType.rawValue] = ESStringUtil.getRoomType(sourceText)?.id ?? ""
            } else if 7 == cellIndex {
                sourceTextFiled.text = sourceText
                viewController.uploadDic[ESCreateProjectUploadDic.ProjectType.rawValue] = ESStringUtil.getPackageId(sourceText)
            }
        }
    }
    
    func setCommuntyAddress(_ model:ESSelectedRegion){
        if 2 == cellIndex {
            sourceTextFiled.text = "\(model.province)\(model.city)\(model.district)"
        }
    }
    
    func setCreateProjectModel( model:(title:String, grayIcon:String, blackIcon:String), cellIndex:NSInteger, vc:ESCreateProjectViewController){
        
        self.cellIndex = cellIndex
        self.viewController = vc
        
        if 2 == cellIndex || 4 == cellIndex || 5 == cellIndex || 7 == cellIndex{
            sourceTextFiled.isEnabled = false
            rightIcon.isHidden = false
        } else {
            sourceTextFiled.isEnabled = true
            rightIcon.isHidden = true
        }
        
        leftIcon.image = ESPackageAsserts.bundleImage(named:model.grayIcon)
        sourceTitle.text = model.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension ESCreateProjectTableViewCell:UITextFieldDelegate {
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
        case 0,3:
            if resultText.count > 15 && resultText.count > originText.length {//限制位数
                return false
            }
            break
        case 1:
            if resultText.count > 11 && resultText.count > originText.length {//限制位数
                return false
            }
            break
        case 6:
            
            return ESFormCheck.checkHouseSizeForm(textField: textField, range: range, string: string)
        default:
            break
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if let viewController = self.viewController {
            switch cellIndex {
            case 0:  viewController.uploadDic[ESCreateProjectUploadDic.OwnerName.rawValue] = text
                break
            case 1:  viewController.uploadDic[ESCreateProjectUploadDic.Phone.rawValue] = text
                break
            case 3:  viewController.uploadDic[ESCreateProjectUploadDic.ComunityName.rawValue] = text
                break
            case 6:
                let fixedText =  ESFormCheck.fixInputedHouseSize(text: text)
                textField.text = fixedText
                viewController.uploadDic[ESCreateProjectUploadDic.HouseArea.rawValue] = fixedText
                break
            default:
                break
            }
        }
        return true
    }
}
