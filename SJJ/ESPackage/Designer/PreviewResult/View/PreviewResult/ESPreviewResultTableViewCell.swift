//
//  ESPreviewResultTableViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/19.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESPreviewResultTableViewCell: UITableViewCell{
    
    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var textfiled: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    
    private var cellIndex:NSInteger = 0
    private weak var viewController:ESPreviewResultViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textfiled.delegate = self
    }
    
    //MARK: - setter
    func setCellIndex(index:NSInteger, vc:ESPreviewResultViewController){
        self.cellIndex = index
        self.viewController = vc
        
        if 1 == cellIndex || 2 == cellIndex || 7 == cellIndex {
            self.hiddenLabelAndImageView()
        } else if 3 == cellIndex {
            self.showUnitLabel()
        } else {
            self.showRightArrow()
        }
    }
    
    func setBasicData(model:(leftTitle:String, placeHold:String)){
        leftTitleLabel.text = model.leftTitle
        textfiled.placeholder =  model.placeHold
    }
    
    func setCellModel(model:ESPreviewResultUploadModel){
        switch cellIndex {
        case 1:
            textfiled.text  = model.name
            break
        case 2:
            textfiled.text  = model.mobile
            break
        case 3:
            textfiled.text  = model.houseSize
            break
        case 4:
            textfiled.text  =  ESStringUtil.getHouseType(model.houseType)?.value ?? ""
            break
        case 5:
            textfiled.text  = ESStringUtil.getRoomType(model.roomType)?.value ?? ""
            break
        case 6:
            textfiled.text  = model.province + model.city + model.district
            break
        case 7:
            textfiled.text  = model.community
            break
        default:
            break
        }
    }
    
    func setDateString(_ date:String){
        textfiled.text = date
    }
    
    func setCommuntyAddress(_ model:ESSelectedRegion){
        if 6 == cellIndex {
            textfiled.text = "\(model.province)\(model.city)\(model.district)"
        }
    }
    
    func setHouseTypeAndBugdge(_ dict:[String:String]){
        let source = dict["comp1"] ?? ""
        if let viewController = self.viewController {
            
            if 4 == cellIndex {
                textfiled.text = source
                let n = ESStringUtil.getHouseType(source)?.id ?? ""
                print("jieguo == " + n)
                viewController.uploadDic[ESPreviewResultUploadDic.HouseType.rawValue] = ESStringUtil.getHouseType(source)?.id ?? ""//source
                
            } else if 5 == cellIndex {
                textfiled.text = source
                let n = ESStringUtil.getRoomType(source)?.id ?? ""
                print("jieguo == " + n)
                viewController.uploadDic[ESPreviewResultUploadDic.RoomType.rawValue] = ESStringUtil.getRoomType(source)?.value ?? ""
            }
        }
    }
    
    //MARK: - Method
    
    func hiddenLabelAndImageView(){
        unitLabel.isHidden = true
        rightArrowImageView.isHidden = true
        textfiled.isEnabled = true
    }
    
    func showUnitLabel() {
        unitLabel.isHidden = false
        rightArrowImageView.isHidden = true
        textfiled.isEnabled = true
    }
    
    func showRightArrow() {
        unitLabel.isHidden = true
        rightArrowImageView.isHidden = false
        textfiled.isEnabled = false
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension ESPreviewResultTableViewCell:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if cellIndex == 7 {
            if let viewController = self.viewController {
                
                viewController.currentRect = ESCGRectUtil.getRelativeCGrect(view: textField)
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let originText : NSString = textField.text as NSString? ?? ""
        
        let resultText = originText.replacingCharacters(in: range, with: string)
        
        switch cellIndex {
        case 1:
            if resultText.count > 15 && resultText.count > originText.length {//限制位数
                return false
            }
            break
        case 2:
            if resultText.count > 11 && resultText.count > originText.length {//限制位数
                return false
            }
            break
        case 3:
        
            return ESFormCheck.checkHouseSizeForm(textField: textField, range: range, string: string)
            
        case 7:
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
        if let viewController = self.viewController {
            
            let text = textField.text ?? ""
            
            switch cellIndex {
            case 1:
                viewController.uploadDic[ESPreviewResultUploadDic.CosumerName.rawValue] = text
                break
            case 2:
                viewController.uploadDic[ESPreviewResultUploadDic.Telephone.rawValue] = text
                break
            case 3:
                let fixedText =  ESFormCheck.fixInputedHouseSize(text: text)
                textField.text = fixedText
                viewController.uploadDic[ESPreviewResultUploadDic.HouseArea.rawValue] = fixedText
                break
            case 7:
                viewController.uploadDic[ESPreviewResultUploadDic.CommunityName.rawValue] = text
                break
            default:
                break
            }
        }
        return true
    }
}
