//
//  ESFreeAppointSelectStyleCollectionViewCell.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/22.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit
import Foundation

typealias SelectStyleBlock = (_ selectedIcon:Array<Int>)->Void

class ESFreeAppointSelectStyleCollectionViewCell: UICollectionViewCell {
    
    lazy var styleIcon = UIImageView()
    lazy var styleSelectedIcon = UIImageView()
    
    lazy var styleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: .medium, size: 13)
        label.textAlignment = .center
        return label
    }()
    
    private var cellIndex:NSInteger = 0
    
    private weak var viewController:ESFreeAppointViewController?
    private weak var viewController1:ESPersonalAppointViewController?
    
    private var personal = false //个性化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let iconWH:CGFloat = 65.scalValue//((ScreenWidth - 30 - 24.scalValue) / 4) - 4.scalValue
        
        contentView.addSubview(styleIcon)
        
        styleIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: iconWH, height: iconWH))
            make.centerX.equalTo(contentView.snp.centerX)
        }
        
        contentView.addSubview(styleSelectedIcon)
        styleSelectedIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: iconWH, height: iconWH))
            make.centerX.equalTo(contentView.snp.centerX)
        }
        
        styleIcon.layer.masksToBounds = true
        styleIcon.layer.cornerRadius = iconWH / 2
        
        contentView.addSubview(styleLabel)
        styleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(styleIcon.snp.bottom).offset(13.scalValue)
            make.size.equalTo(CGSize(width: iconWH, height: 18.5.scalValue))
            make.centerX.equalTo(contentView.snp.centerX)
        }
        styleIcon.isUserInteractionEnabled = true
        styleLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod(tap:)))
        self.addGestureRecognizer(tap)
        
        bringSubview(toFront: styleSelectedIcon)
    }
    
    
    func setCreateProjectModel(cellIndex:NSInteger, vc:ESFreeAppointViewController){
        self.cellIndex = cellIndex
        self.viewController = vc
        if cellIndex < vc.selectedStyleArray.count {
            styleSelectedIcon.image =  vc.selectedStyleArray[self.cellIndex] == 0 ? nil : ESPackageAsserts.bundleImage(named: "appoint_select_right")
        }
    }
    
    func setPersonalAppointModel(cellIndex:NSInteger, vc:ESPersonalAppointViewController){
        self.personal = true
        self.cellIndex = cellIndex
        self.viewController1 = vc
        if self.cellIndex < vc.selectedStyleArray.count {
            styleSelectedIcon.image = vc.selectedStyleArray[self.cellIndex] == 0 ? nil : ESPackageAsserts.bundleImage(named: "appoint_select_right")
        }
    }
    
    @objc func tapMethod(tap:UITapGestureRecognizer){
        
        if !personal {
            if let viewController = self.viewController {
                
                if viewController.selectedStyleArray[cellIndex] == 0 {
                    if viewController.selectedCount >= 3 {
                        ESProgressHUD.showText(in: viewController.view, text: "仅支持3个选项哦")
                        return
                    }
                    styleSelectedIcon.image = ESPackageAsserts.bundleImage(named: "appoint_select_right")
                    viewController.selectedStyleArray[cellIndex] = 1
                    viewController.selectedCount += 1
                } else {
                    styleSelectedIcon.image = nil
                    viewController.selectedStyleArray[cellIndex] = 0
                    viewController.selectedCount -= 1
                }
            }
            
        } else {
            if let viewController1 = self.viewController1 {
                
                if viewController1.selectedStyleArray[cellIndex] == 0 {
                    if viewController1.selectedCount >= 1 {
                        ESProgressHUD.showText(in: viewController1.view, text: "仅支持1个选项哦")
                        return
                    }
                    styleSelectedIcon.image = ESPackageAsserts.bundleImage(named: "appoint_select_right")
                    
                    viewController1.selectedStyleArray[cellIndex] = 1
                    viewController1.selectedCount += 1
                } else {
                    styleSelectedIcon.image = nil
                    viewController1.selectedStyleArray[cellIndex] = 0
                    viewController1.selectedCount -= 1
                }
            }
        }
    }
    
    func setStyleModel(_ model:ESAppointDecorateStyleModel){
        styleIcon.imageWith(model.styleImageUrl ?? "", placeHold: #imageLiteral(resourceName: "equal_default"))
        styleLabel.text = model.styleName
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
