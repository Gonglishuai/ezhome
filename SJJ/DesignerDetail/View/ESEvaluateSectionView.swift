//
//  ESEvaluateSectionView.swift
//  EZHome
//
//  Created by shiyawei on 4/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESEvaluateSectionView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    
    let mainLayout = ESEvaluateSectionLayout()
    private var datas = Array<String>()
    
    
    
    //    MARK:UICollectionViewDelegate,UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datas.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESEvaluateSectionCell", for: indexPath) as! ESEvaluateSectionCell
        cell.contentString(text:self.datas[indexPath.item])
        return cell
    }
    
    func datas(datas:Array<String>) {
        self.datas = datas
        self.addSubview(self.collectionView)
        self.collectionView.reloadData()
    }
    
    lazy var collectionView:UICollectionView = {
        mainLayout.sectionHeadersPinToVisibleBounds = true
        mainLayout.sectionInset = UIEdgeInsets(top: 13, left: 15, bottom: 13, right: 15)
        mainLayout.headerReferenceSize = CGSize(width: ScreenWidth / 3, height: 50)
        
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: mainLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UINib.init(nibName: "ESEvaluateSectionCell", bundle: nil), forCellWithReuseIdentifier: "ESEvaluateSectionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.autoresizesSubviews = false
        collectionView.alwaysBounceVertical = false
        collectionView.bounces = false
        return collectionView
    }()

}
