//
//  ESAddBrandMainView.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESAddBrandMainViewProtocol:NSObjectProtocol {
    ///添加
    func addBrands(brands:ESBrandBigTytpe)
    
}

class ESAddBrandMainView: UIView ,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private weak var mainViewDelegate: ESAddBrandMainViewProtocol?
    
    private var collectionView: UICollectionView!
    
    private var typeListView = ESSelectBrandListView()
    private var selectView:ESAddBrandSelectBrandsView!
    
    private var firstRank = true
    
    private var addBrandList = ESBrandBigTytpe()
    
    ///推荐品牌 最外层大 list
    var addingBrandObjects = ESBrandBigTytpe()
    
//    var hasAddedBrands = ESBrandBigTytpe()
    
    init(delegate: ESAddBrandMainViewProtocol?) {
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
        
        addSelectView()
        
        collectionView = ESUIViewFactory.collectionView()
        
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib.init(nibName: "ESAddBrandsCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "ESAddBrandsCollectionViewCell")
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(selectView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-btnHeight)
        }
        addButton(btnHeight)
    }
    
    private func addSelectView() {
        
        selectView = ESAddBrandSelectBrandsView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 44.scalValue))
        addSubview(selectView)
        selectView.setViewModel()
        
        selectView.selectBrandsBlock = {[weak self](left:Bool) in
            guard let `self` = self else {
                return
            }
            if left {
                self.firstRank = true
            } else {
                self.firstRank = false
            }
            self.addSelectBrandsTypeList()
        }
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
    
    private var brandCatagoryList = [ESBrandsCatalogsModel]()
    private var catagoryTouchIndex:Int = 0
    
    private func addSelectBrandsTypeList(){
        if brandCatagoryList.isEmpty {
            return
        }
        addSubview(typeListView)
        let showCatagaory = setBrandCatagoryListData()
        
        typeListView.snp.makeConstraints { (make) in
            make.top.equalTo(selectView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        typeListView.selectTypeBlock = {[weak self] (typeIndex:Int) in
            guard let `self` = self else {
                return
            }
            if !showCatagaory.isEmpty {
                //TODO: - 添加数据刷新
                if self.firstRank {
                    self.catagoryTouchIndex = typeIndex
                    self.selectView.setleftButtonTitle(title: showCatagaory[typeIndex])
                    self.selectView.setRightButtonTitle(title: "类型")
                    
                    let model = self.brandCatagoryList[typeIndex]
                    
                    self.requestDataForBrands(catLevel: "1", catId: model.id ?? "")
                    
                } else {
                    self.selectView.setRightButtonTitle(title: showCatagaory[typeIndex])
                    
                    if let list = self.brandCatagoryList[self.catagoryTouchIndex].subList {
                        let model:ESBrandsCatalogsSubModel = list[typeIndex]
                        
                        self.requestDataForBrands(catLevel: "2", catId: model.id ?? "")
                    }
                }
            }
        }
    }
    //MARK: - Actions
    private func setBrandCatagoryListData()->[String]{ ///设置下拉分类数据
        var showCatagaory = [String]()
        if firstRank {
            for model in brandCatagoryList {
                showCatagaory.append(model.name ?? "--")
            }
            selectView.setleftButtonTitle(title: brandCatagoryList[catagoryTouchIndex].name ?? "--")//设置
            
        } else {
            let array = brandCatagoryList[catagoryTouchIndex].subList ?? []
            for model in array {
                showCatagaory.append(model.name ?? "--")
            }
        }
        typeListView.setCellModel(data: showCatagaory)
        return showCatagaory
    }
    
    //MARK: - Public Methods
    func setBottomButtonColor(color:UIColor, enable:Bool){
        addBransButton.backgroundColor = color
        addBransButton.isEnabled = enable
    }
    
    func setTypeListViewData(catagorys:[ESBrandsCatalogsModel]){
        self.brandCatagoryList = catagorys
    }
    
    func reloadView(model:[ESBrandGoodsModel]){
        self.addBrandList = model
        collectionView.reloadData()
    }
    //MARK: - Network
    private var errorView = ESErrorViewUtil()
    func requestDataForBrands(catLevel:String, catId:String){//TODO: - 获取品牌
        ESProgressHUD.show(in: self)
        ESBrandApi.getCatagorysBrands(catLevel: catLevel, catId: catId, success: { (data) in
            ESProgressHUD.hide(for: self)
            self.errorView.hiddenErrorView()
            
            let brands = try?JSONDecoder().decode([ESBrandGoodsModel].self, from: data)
            if let list = brands, !list.isEmpty {
                
                self.addBrandList = list
                self.fixNewDatasForshowSelectedBrands()
            } else {
                self.addBrandList.removeAll()
                self.errorView.showErrorView(in: self.collectionView, imgName:"nodata_search", title:"没有搜索到任何品牌~", buttonTitle:"", block:nil)
            }
            self.collectionView.reloadData()
        }) { (error) in
            ESProgressHUD.hide(for: self)
            ESProgressHUD.showText(in: self, text: SHRequestTool.getErrorMessage(error))
        }
    }
    
    private func fixNewDatasForshowSelectedBrands() {
        
        for i in 0..<addBrandList.count {
            
            var model = addBrandList[i]
            for model1 in addingBrandObjects {
                
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
         } else {
            
            cell.selectrdIcon.isHidden = true
            
            for i in 0..<addingBrandObjects.count {
                let model1 = addingBrandObjects[i]
                if model1.id == model.id {
                    addingBrandObjects.remove(at: i)
                    break
                }
            }
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
