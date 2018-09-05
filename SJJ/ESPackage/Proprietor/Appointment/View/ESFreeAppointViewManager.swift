//
//  ESFreeAppointViewManager.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/21.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESFreeAppointViewManager: NSObject {
    
    lazy var collectionView: UICollectionView = {
        
        let collectionView = ESUIViewFactory.collectionView()
        collectionView.frame = CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 50)
        
        collectionView.register(ESFreeAppointFirstCollectionViewCell.self, forCellWithReuseIdentifier: "ESFreeAppointFirstCollectionViewCell")
        collectionView.register(UINib.init(nibName: "ESFreeAppointFirstSectionHeader", bundle: ESPackageAsserts.hostBundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ESFreeAppointFirstSectionHeader")
        collectionView.register(UINib.init(nibName: "ESFreeAppointSectionFooterCollectionReusableView", bundle: ESPackageAsserts.hostBundle), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ESFreeAppointSectionFooterCollectionReusableView")
        collectionView.register(ESFreeAppointSelectStyleCollectionViewCell.self, forCellWithReuseIdentifier: "ESFreeAppointSelectStyleCollectionViewCell")

        return collectionView
    }()
    
    lazy var personCollectionView: UICollectionView = {
        
        let collectionView = ESUIViewFactory.collectionView()
        
        collectionView.register(UINib.init(nibName: "ESFreeAppointFirstSectionHeader", bundle: ESPackageAsserts.hostBundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ESFreeAppointFirstSectionHeader")
        collectionView.register(UINib.init(nibName: "ESFreeAppointSectionFooterCollectionReusableView", bundle: ESPackageAsserts.hostBundle), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ESFreeAppointSectionFooterCollectionReusableView")
        
        collectionView.register(ESFreeAppointSelectStyleCollectionViewCell.self, forCellWithReuseIdentifier: "ESFreeAppointSelectStyleCollectionViewCell")
        collectionView.register(UINib.init(nibName: "ESPersonalAppointCollectionViewCell", bundle: ESPackageAsserts.hostBundle), forCellWithReuseIdentifier: "ESPersonalAppointCollectionViewCell")
        
        return collectionView
    }()
    
    
    
    func orderImmediately(_ target:ESFreeAppointViewController)-> UIButton{
        let button = ESUIViewFactory.button("立即预约")
        button.addTarget(target, action: #selector(target.orderImmediately), for: .touchUpInside)
        return button
    }
    
    func orderImmediatelyForPerson(_ target:ESPersonalAppointViewController)-> UIButton{
        let button = ESUIViewFactory.button("选好了")
        button.addTarget(target, action: #selector(target.orderImmediately), for: .touchUpInside)
        return button
    }
   
    
    lazy var tableView: UITableView = {
        
        let tableView:UITableView = ESUIViewFactory.tableView(.grouped)
        tableView.backgroundColor = UIColor.white

        tableView.frame = CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 50)
        tableView.estimatedRowHeight = 50
        
        tableView.register(UINib.init(nibName: "ESCancleAppointTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESCancleAppointTableViewCell")
        tableView.register(UINib.init(nibName: "ESCancleAppointReasonTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESCancleAppointReasonTableViewCell")
        
        tableView.tableHeaderView = tableHeaderView()
        
        return tableView
    }()
    
    lazy var detailTableView: UITableView = {
        
        let tableView:UITableView = ESUIViewFactory.tableView(.grouped)
        tableView.backgroundColor = UIColor.white
        
        tableView.estimatedRowHeight = 150
        tableView.sectionFooterHeight = 30//CGFloat.leastNormalMagnitude
        
        tableView.register(UINib.init(nibName: "ESChargebackDetailFirstTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESChargebackDetailFirstTableViewCell")
        tableView.register(UINib.init(nibName: "ESChargebackDetailSecondTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESChargebackDetailSecondTableViewCell")
        tableView.register(UINib.init(nibName: "ESChargebackThirdTableViewCell", bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: "ESChargebackThirdTableViewCell")
        tableView.register(ESChargebackDetalFourthTableViewCell.self, forCellReuseIdentifier: "ESChargebackDetalFourthTableViewCell")
        tableView.register(ESChargebackDetailSectionHeader.self, forHeaderFooterViewReuseIdentifier: "ESChargebackDetailSectionHeader")
        
        return tableView
    }()
    
    func getFreeAppointFirstCell(_ type:String,collectionView:UICollectionView)-> ESFreeAppointFirstCollectionViewCell{
        var itemIndex = 3
        if type == "HousingState" {
            itemIndex = 4
        } else if type == "PackageDecorationBudget"{
            itemIndex = 3
        }
        let indexPath = IndexPath(item: itemIndex, section: 0)
        let cell = collectionView.cellForItem(at: indexPath)as!ESFreeAppointFirstCollectionViewCell
        return cell
    }
    
    private var phone = UIButton()
    private var icon = UIImageView()
    private var mainLabel = ESUIViewFactory.mainLabel()
    private var cancleLabel = UILabel()

    func tableHeaderView()-> UIView{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 258))
        view.backgroundColor = UIColor.white
        
        icon.image = ESPackageAsserts.bundleImage(named: "consumer_cancle_appoint")
        view.addSubview(icon)
        
        icon.snp.makeConstraints({ (make) in
            make.top.equalTo(view.snp.top).offset(40)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width: 107, height: 53))
        })
        
        view.addSubview(mainLabel)
        mainLabel.textAlignment = .center
        mainLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(icon.snp.bottom).offset(28)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width: ScreenWidth - 20, height: 22.5))
        })
        mainLabel.text = "尊贵的客人，您确定取消预约吗？"
        
        
        let subLabel = UILabel()
        subLabel.textColor = ESColor.color(sample: .subTitleColor)
        subLabel.font = ESFont.font(name: .regular, size: 12)
        view.addSubview(subLabel)
        subLabel.textAlignment = .center

        subLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(mainLabel.snp.bottom).offset(12)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width: ScreenWidth - 20, height: 22.5))
        })
        subLabel.text = "遇到任何问题，可以联系我们的客服人员哦~"
        
        view.addSubview(phone)
        phone.setTitle("400-650-3333", for: .normal)
        phone.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
        phone.titleLabel?.font = ESFont.font(name: .medium, size: 13)
        
        phone.snp.makeConstraints({ (make) in
            make.top.equalTo(subLabel.snp.bottom)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width: ScreenWidth - 20, height: 22.5))
        })
        phone.addTarget(self, action: #selector(callSomeone), for: UIControlEvents.touchUpInside)
        
        let line = ESUIViewFactory.line()
        view.addSubview(line)
        
        line.snp.makeConstraints({ (make) in
            make.top.equalTo(phone.snp.bottom).offset(17)
            make.centerX.equalTo(view.snp.centerX)
            make.size.equalTo(CGSize(width: ScreenWidth - 60, height: 0.5))
        })
        
        view.addSubview(cancleLabel)
        cancleLabel.textColor = ESColor.color(sample: .subTitleColor)
        cancleLabel.font = ESFont.font(name: .medium, size: 12)
        
        cancleLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(line.snp.bottom).offset(22.5)
            make.left.equalTo(35)
            make.size.equalTo(CGSize(width: ScreenWidth - 70, height: 17))
        })
        cancleLabel.text = "取消原因"
       
        return view
    }
    
    func setTableHeaderViewForChargeback(){
        icon.image = ESPackageAsserts.bundleImage(named: "consumer_apply_chargeback")
        mainLabel.text = "尊贵的客人，您确定要申请退单吗？"
        cancleLabel.text = "请您填写申请退单原因，您的申请我们会尽快处理"
    }
    
    func conformCancle(_ target:ESCancleAppointViewController)->UIButton{
        let button = ESUIViewFactory.button()
        button.setTitle("确定取消", for: .normal)
        button.addTarget(target, action: #selector(target.conformCancleClick), for: UIControlEvents.touchUpInside)
        return button
    }
    
    func commitApply(_ target:ESApplyChargebackViewController)->UIButton{
        let button = ESUIViewFactory.button()
        button.setTitle("提交申请", for: .normal)
        button.addTarget(target, action: #selector(target.commitApply), for: UIControlEvents.touchUpInside)
        return button
    }
    
    
    @objc func callSomeone(){
        ESDeviceUtil.callToSomeone(numberString: phone.titleLabel?.text ?? "")
    }
   
    
}
