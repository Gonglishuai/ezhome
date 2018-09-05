//
//  ESProHomePageCasesCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  推荐案例列表

import UIKit

protocol ESProHomePageCasesCellDelegate: NSObjectProtocol {
    func getRecommendCases() -> [ESProHomePageCase]?
    func didSelectCase(_ index: Int)
}

class ESProHomePageCasesCell: UICollectionViewCell, ESProHomePageCellCommonProtocol {
    var delegate: ESProHomePageCommonCellDelegate?
    
    fileprivate var caseList: [ESProHomePageCase] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ indexPath: IndexPath) {
        if let cases = delegate?.getRecommendCases(), cases.count > 0 {
            caseList = cases
            collectionView.reloadData()
        }
    }
    
    func setUpView() {
        contentView.addSubview(collectionView)
        contentView.addSubview(lineView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(lineView)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15.scalValue)
            make.right.equalToSuperview().offset(-15.scalValue)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xCCCCCC, alpha: 1.0)
        return view
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let view =  UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.register(ESProHomePageCaseCell.self, forCellWithReuseIdentifier: "ESProHomePageCaseCell")
        view.backgroundColor = .white
        view.alwaysBounceHorizontal = true
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    fileprivate lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 115.scalValue, height: 166.scalValue)
        layout.minimumInteritemSpacing = 15.scalValue
        layout.sectionInset = UIEdgeInsetsMake(13.scalValue, 15.scalValue, 15.scalValue, 15.scalValue)
        return layout
    }()
}

extension ESProHomePageCasesCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCase(indexPath.item)
    }
}

extension ESProHomePageCasesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return caseList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESProHomePageCaseCell", for: indexPath) as! ESProHomePageCaseCell
        let model = caseList[indexPath.item]
        cell.caseModel = model
        return cell
    }
}

