//
//  ESEvaluateViewController.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

/// 评价
class ESEvaluateViewController: ESBasicViewController {

    private lazy var mainView = ESEvaluateMainView(delegate: self)
    private var assetId = ""
    private var designerAvatar: String?
    private var designerName: String?
    private var evaluateTags = [String?]()
    private var selectImages = [UIImage?]()
    
    private lazy var photoSelector:ESPhotoSelector = ESPhotoSelector()
    
    init(assetId: String, designerAvatar: String?, designerName: String?) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.designerAvatar = designerAvatar
        self.designerName = designerName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initilizaUI()
        requestData()
    }
    
    private func initilizaUI() {
        setupNavigationTitleWithBack(title: "评价")
        
        view.addSubview(mainView)
        
        mainView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    private func requestData() {
        ESProgressHUD.show(in: self.view)
        ESProjectEvaluateDataManager.getEvaluateTags(success: { (array) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.evaluateTags = array
                self.mainView.refreshMainView()
            }
        }) { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
            }
        }
    }
    
    func addPicture(){
        
    }
}

extension ESEvaluateViewController: ESEvaluateMainViewDelegate {
    func getItemsCount(section: Int) -> Int {
        switch section {
        case 1:
            return evaluateTags.count
        case 2:
            return ESProjectEvaluateDataManager.getEvaluateStarTitle().count
        case 4:
            if selectImages.count < 5 {
                return selectImages.count + 1
            }
            return selectImages.count
        default:
            return 1
        }
    }
    
    func commiteEvaluate() {
        print("提交评价")
    }
}

//MARK: - 设计师信息
extension ESEvaluateViewController: ESEvaluateFirstCollectionViewCellDelegate{
    func getInfo() -> (String?, String?) {
        return (designerAvatar, designerName)
    }
}
//MARK: - 评价标签
extension ESEvaluateViewController: ESEvaluateSecondCollectionViewCellProtocol{
    func getTagTitle(index: Int) -> String? {
        if evaluateTags.count <= index {
            return nil
        }
        return evaluateTags[index]
    }
    
    func selectedEvaluate(selected: Bool, cellIndex: Int) {
        print(cellIndex)
    }
}
//MARK: - 评分
extension ESEvaluateViewController: ESEvaluateThirdCollectionViewCellProtocol{
    func getStarTitle(index: Int) -> String? {
        let titles = ESProjectEvaluateDataManager.getEvaluateStarTitle()
        if titles.count <= index {
            return nil
        }
        return titles[index]
    }
    
    func evaluateScore(score: Int, cellIndex: Int) {
        print("cellIndex:\(cellIndex)   score:\(score)")
    }
}
//MARK: - 输入评价
extension ESEvaluateViewController: ESEvaluateFourthCollectionViewCellProtocol {
    func textViewText(text: String) {
        print(text)
    }
}
//MARK: - 添加图片
extension ESEvaluateViewController: ESEvaluateFirthCollectionViewCellProtocol {
    func getImage(index: Int) -> (UIImage?, Bool) {
        if index == selectImages.count {
            let img = ESPackageAsserts.bundleImage(named: "evaluate_add")
            return (img, true)
        }
        return (selectImages[index], false)
    }
    
    func addImage() {
        print("添加图片")
        photoSelector.selectPhoto(self)
        photoSelector.maxSelectNumber = 5
        photoSelector.returnedPhotos = {[weak self](photos) in
            guard let `self` = self else {
                return
            }
            self.selectImages = photos!
            self.mainView.refreshMainViewForSelectedPhoto()
        }
    }
}
