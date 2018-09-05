//
//  ESEvaluateMainView.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESEvaluateMainViewDelegate: NSObjectProtocol {
    ///获取评价标签items
    func getItemsCount(section: Int) -> Int
    ///提交评价
    func commiteEvaluate()
}

class ESEvaluateMainView: UIView,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private weak var delegate: ESEvaluateMainViewDelegate?
    private var collectionView: UICollectionView!
    
    
    init(delegate: ESEvaluateMainViewDelegate?) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        self.delegate = delegate
        setUpSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSubView() {
        
        let btnHeight:CGFloat = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        
        collectionView = ESUIViewFactory.collectionView()
        
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "ESEvaluateFirstCollectionViewCell", bundle: ESPackageAsserts.hostBundle), forCellWithReuseIdentifier: "ESEvaluateFirstCollectionViewCell")
        collectionView.register(ESEvaluateSecondCollectionViewCell.self, forCellWithReuseIdentifier: "ESEvaluateSecondCollectionViewCell")
        collectionView.register(ESEvaluateThirdCollectionViewCell.self, forCellWithReuseIdentifier: "ESEvaluateThirdCollectionViewCell")
        collectionView.register(UINib.init(nibName: "ESEvaluateFourthCollectionViewCell", bundle: ESPackageAsserts.hostBundle), forCellWithReuseIdentifier: "ESEvaluateFourthCollectionViewCell")
        collectionView.register(UINib.init(nibName: "ESEvaluateFirthCollectionViewCell", bundle: ESPackageAsserts.hostBundle), forCellWithReuseIdentifier: "ESEvaluateFirthCollectionViewCell")
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-btnHeight.scalValue)
        }
        //提交评价
        let button = ESUIViewFactory.button("提交评价")
        addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(btnHeight.scalValue)
        }
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
        button.addTarget(self, action: #selector(commitEvaluate), for: .touchUpInside)
    }
    
    func refreshMainView() {
        collectionView.reloadData()
    }
    
    func refreshMainViewForSelectedPhoto(){
        let indexSet = IndexSet(integer: 4)
        collectionView.reloadSections(indexSet)
    }
    
    @objc func commitEvaluate(){
        if let delegate = self.delegate {
            self.endEditing(true)
            delegate.commiteEvaluate()
        }
    }
    
    //MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = delegate?.getItemsCount(section: section) ?? 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            
            return CGSize(width: ScreenWidth, height: 127)
        case 1:
            
            return CGSize(width: 100.scalValue, height: 25.scalValue)
        case 2:
            
            return CGSize(width: ScreenWidth, height: 40.scalValue)
        case 3:
            
            return CGSize(width: ScreenWidth, height: 123)
        case 4:
            
            return CGSize(width: 73.scalValue, height: 73.scalValue)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESEvaluateFirstCollectionViewCell", for: indexPath)as!ESEvaluateFirstCollectionViewCell
            
            let dele = self.delegate as? ESEvaluateFirstCollectionViewCellDelegate
            cell.setCellModel(delegate: dele)
            
            return cell
        case 1:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESEvaluateSecondCollectionViewCell", for: indexPath)as!ESEvaluateSecondCollectionViewCell
            
            let dele = self.delegate as? ESEvaluateSecondCollectionViewCellProtocol
            cell.setCellDelegate(delegate: dele, cellIndex: indexPath.row)
            
            return cell
        case 2:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESEvaluateThirdCollectionViewCell", for: indexPath)as!ESEvaluateThirdCollectionViewCell
            
            let dele = self.delegate as? ESEvaluateThirdCollectionViewCellProtocol
            cell.setCellDelegate(delegate: dele, cellIndex: indexPath.row)
            
            return cell
        case 3:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESEvaluateFourthCollectionViewCell", for: indexPath)as!ESEvaluateFourthCollectionViewCell
            
            cell.cellDelegate = self.delegate as? ESEvaluateFourthCollectionViewCellProtocol
            
            return cell
            
        case 4:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESEvaluateFirthCollectionViewCell", for: indexPath)as!ESEvaluateFirthCollectionViewCell
            
            cell.cellDelegate = self.delegate as? ESEvaluateFirthCollectionViewCellProtocol
            cell.updateCell(index: indexPath.item)
            
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0,2:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case 1:
            return UIEdgeInsets(top: 0, left: 22.5.scalValue, bottom: 0, right: 22.5.scalValue)
        case 3,4:
            return UIEdgeInsets(top: 0, left: 15.scalValue, bottom: 0, right: 15.scalValue)
        default:
            return UIEdgeInsets.zero//(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 1:
            return 13.scalValue
        case 4:
            return 15.scalValue
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNormalMagnitude
        case 1,4:
            return 15.scalValue
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
}

