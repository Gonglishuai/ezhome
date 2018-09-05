
//
//  ESSearchBransMainView.swift
//  Consumer
//
//  Created by zhang dekai on 2018/3/1.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESSearchBransMainViewProtocol:NSObjectProtocol {
    ///添加
    func addBrands(brands:ESBrandBigTytpe)
}

class ESSearchBransMainView: UIView ,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private weak var mainViewDelegate: ESSearchBransMainViewProtocol?
    
    private var collectionView: UICollectionView!

    private var addBrandList = [ESBrandGoodsModel]()
    
    ///推荐品牌 最外层大 list
    var addingBrandObjects = ESBrandBigTytpe()
    
    var hasAddedBrands = ESBrandBigTytpe()
    
    init(delegate: ESSearchBransMainViewProtocol?) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        self.mainViewDelegate = delegate
        setUpSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - InitUI
    private func setUpSubView() {
        
        let btnHeight:CGFloat = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT
        
        collectionView = ESUIViewFactory.collectionView()
        
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib.init(nibName: "ESAddBrandsCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "ESAddBrandsCollectionViewCell")
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-btnHeight)
        }
        addButton(btnHeight)
    }
  
    private var addBransButton:UIButton!
    private func addButton(_ btnHeight:CGFloat){
        //添加
        addBransButton = ESUIViewFactory.button("添加")
        self.addSubview(addBransButton)
        
        addBransButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(btnHeight)
        }
        if BOTTOM_SAFEAREA_HEIGHT > 0 {
            addBransButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
        addBransButton.addTarget(self, action: #selector(addBrands), for: .touchUpInside)
    }
    
    //MARK: - Public Methods
    func setBottomButtonColor(color:UIColor, enable:Bool){
        addBransButton.backgroundColor = color
        addBransButton.isEnabled = enable
    }
    
    func reloadView(model:[ESBrandGoodsModel]){
        self.addBrandList = model
        collectionView.reloadData()
    }
    
    //MARK: - Network
    private var errorView = ESErrorViewUtil()
    func requestDataForBrands(ketword:String){//TODO: - 模糊搜索获取品牌
        ESProgressHUD.show(in: self)
        ESBrandApi.searchBrands(ketword: ketword, success: { (data) in
            ESProgressHUD.hide(for: self)
            self.errorView.hiddenErrorView()

            let brands = try?JSONDecoder().decode([ESBrandGoodsModel].self, from: data)
            if let list = brands, !list.isEmpty {
                self.addBrandList = list
                self.fixNewDatasForshowSelectedBrands()
                self.collectionView.reloadData()
            } else {
                self.errorView.showErrorView(in: self, imgName:"nodata_search", title:"搜索不到内容哦~\n换个关键词试试吧", buttonTitle:"", block:nil)
            }
        }) { (error) in
            ESProgressHUD.hide(for: self)
            ESProgressHUD.showText(in: self, text: "检索不到数据")//SHRequestTool.getErrorMessage(error))
        }
        
    }
    
    private func fixNewDatasForshowSelectedBrands() {
        
        for i in 0..<addBrandList.count {
            
            var model = addBrandList[i]
            for model1 in hasAddedBrands {
                
                if model.id == model1.id {
                    model.hasSelected = true
                    addBrandList[i] = model
                }
            }
        }
    }
    
    //MARK: - Actions
    @objc func addBrands(){//添加
        if let delegate = mainViewDelegate {
            
            self.endEditing(true)
            
            delegate.addBrands(brands: addingBrandObjects)
        }
    }
    
    //MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addBrandList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167.scalValue, height: 212.scalValue)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESAddBrandsCollectionViewCell", for: indexPath)as!ESAddBrandsCollectionViewCell
        
        if !addBrandList.isEmpty {
            let model = addBrandList[indexPath.row]
            cell.setCellModel(model: model)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)as!ESAddBrandsCollectionViewCell
        
        var model:ESBrandGoodsModel = addBrandList[indexPath.row]
        
        if cell.selectrdIcon.isHidden {
            cell.selectrdIcon.isHidden = false
            
            var cat2IdCount = 0
            _ = addingBrandObjects.map({ (model1) -> Void in
                if model.cat2Id == model1.cat2Id {
                    cat2IdCount = cat2IdCount + 1
                }
            })
            
            if cat2IdCount > 3 {
                ESProgressHUD.showText(in: collectionView, text: "每个品类下最多可以推荐三个品牌商品，您已超量啦~")
            } else {
                model.hasSelected = true
                addingBrandObjects.append(model)
                addBransButton.backgroundColor = ESColor.color(sample: .buttonBlue)
                addBransButton.isEnabled = true
            }
            
            //            if cat2Ids.contains(cat2Id) {
            //
            //                var selectedBrands = addingBrandObjects[cat2Id] ?? []
            //
            //                if selectedBrands.count >= 3 {
            //                    ESProgressHUD.showText(in: collectionView, text: "每个品类下最多可以推荐三个品牌商品，您已超量啦~")
            //                } else {
            //                    model.hasSelected = true
            //                    selectedBrands.append(model)
            //                    addingBrandObjects[cat2Id] = selectedBrands
            //                    addBransButton.backgroundColor = ESColor.color(sample: .buttonBlue)
            //                    addBransButton.isEnabled = true
            //                }
            //            } else {
            //                var selectedBrands = [ESBrandGoodsModel]()
            //                model.hasSelected = true
            //                selectedBrands.append(model)
            //                addingBrandObjects[cat2Id] = selectedBrands
            //                addBransButton.backgroundColor = ESColor.color(sample: .buttonBlue)
            //                addBransButton.isEnabled = true
            //            }
        } else {
            
            cell.selectrdIcon.isHidden = true
            
            for i in 0..<addingBrandObjects.count {
                let model1 = addingBrandObjects[i]
                if model1.id == model.id {
                    addingBrandObjects.remove(at: i)
                    break
                }
            }
            //
            //            var selectedBrands = addingBrandObjects[cat2Id] ?? []
            //
            //            for i in 0..<selectedBrands.count {
            //                let model1 = selectedBrands[i]
            //                if model.id == model1.id {
            //                    selectedBrands.remove(at: i)
            //                    addingBrandObjects[cat2Id] = selectedBrands
            //                    break
            //                }
            //            }
            
            if addingBrandObjects.count == 0 {
                addBransButton.backgroundColor = ESColor.color(hexColor: 0xCFCFCF, alpha: 1)
                addBransButton.isEnabled = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 15.scalValue, bottom: 0, right: 15.scalValue)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return CGFloat.leastNormalMagnitude
    }

}
