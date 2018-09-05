//
//  ESPersonalAppointViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// 个性化
class ESPersonalAppointViewController: ESBasicViewController {
    
    var selectedCount = 0
    var selectedStyleArray:Array<Int> = []

    private var viewManager = ESFreeAppointViewManager()
    private var iconWH = ((ScreenWidth - 30 - 24.scalValue) / 4)
    private var decorationStyle = [ESAppointDecorateStyleModel]()
    
    //MARK: - Life Style
    override func viewDidLoad() {
        super.viewDidLoad()
        initilizeUI()
        requestData()
    }

    //MARK: - Init UI
    private func initilizeUI(){
        
        setupNavigationTitleWithBack(title: "个性化")
        
        view.addSubview(viewManager.personCollectionView)
        viewManager.personCollectionView.delegate = self
        viewManager.personCollectionView.dataSource = self
        
        let button = viewManager.orderImmediatelyForPerson(self)
        view.addSubview(button)
        
        let btnHeight:CGFloat = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        button.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(btnHeight)
        }
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
    }
    //MARK: - Network
    private func requestData(){
        ESProgressHUD.show(in: view)
        ESAppointDataManager.getDecorationStyle({ (style) in
            ESProgressHUD.hide(for: self.view)
            self.decorationStyle = style
//            self.selectedStyleArray = []
            for _ in style {
                self.selectedStyleArray.append(0)
            }
            self.viewManager.personCollectionView.reloadData()
        }) { (error) in
            ESProgressHUD.hide(for: self.view)
            ESProgressHUD.showText(in: self.view, text: SHRequestTool.getErrorMessage(error))
        }
    }

    @objc func orderImmediately(){
        print("选好了")
        var items = [Dictionary<String,String>]()
        for i in 0..<selectedStyleArray.count {
            if selectedStyleArray[i] == 1 {
                let model = decorationStyle[i]
                let dict = ["name": model.styleName ?? "", "type":"style", "value": model.styleEnglish ?? ""]
                items.append(dict)
            }
        }
        let vc = ESThreeDListViewController()
        vc.selectedCaseTags(items)
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension ESPersonalAppointViewController:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if 0 == section {
            return 1
        }
        return decorationStyle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if 0 == indexPath.section {
            return CGSize(width: ScreenWidth, height: 150)
        } else {
            return CGSize(width: iconWH, height: iconWH + 24)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if 0 == indexPath.section {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESPersonalAppointCollectionViewCell", for: indexPath)as!ESPersonalAppointCollectionViewCell
          
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESFreeAppointSelectStyleCollectionViewCell", for: indexPath)as!ESFreeAppointSelectStyleCollectionViewCell
            cell.setPersonalAppointModel(cellIndex: indexPath.row, vc: self)
            if !decorationStyle.isEmpty {
                cell.setStyleModel(decorationStyle[indexPath.row])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if 0 == section {
            return CGSize.zero
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if 0 == section {
            return CGSize(width: ScreenWidth, height: 68)
        } else {
            return CGSize(width: ScreenWidth, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ESFreeAppointFirstSectionHeader", for: indexPath)
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ESFreeAppointSectionFooterCollectionReusableView", for: indexPath)as!ESFreeAppointSectionFooterCollectionReusableView
            if indexPath.section == 1 {
                view.sectionFooterImage.isHidden = true
            } else {
                view.sectionFooterImage.isHidden = false
            }
            return view
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if 0 == section {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if 0 == section {
            return CGFloat.leastNormalMagnitude
        }
        return 8.scalValue
    }

}
