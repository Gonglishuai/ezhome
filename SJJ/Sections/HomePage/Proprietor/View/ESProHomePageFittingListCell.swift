//
//  ESProHomePageFittingListCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/3/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProHomePageFittingListCellDelegate: NSObjectProtocol {
    func getFittingList(_ index: Int) -> [ESProHomePageFittingCase]?
    func didSFittingCase(_ indexPath: IndexPath)
}

class ESProHomePageFittingListCell: UICollectionViewCell, ESProHomePageCellCommonProtocol {
    
    var delegate: ESProHomePageCommonCellDelegate?
    
    fileprivate var caseList: [String?] = []
    fileprivate var section: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(_ indexPath: IndexPath) {
        section = indexPath.item
        caseList.removeAll()
        if let cases = delegate?.getFittingList(indexPath.item), cases.count > 0 {
            caseList = cases.map({ (fitting) -> String? in
                return fitting.case_image
            })
            collectionView.reloadData()
            if let refresh = delegate?.needReload(), refresh {
                let index = IndexPath(item: 0, section: 0)
                do {
                    try scrollToLeft(index)
                } catch let err {
                    print(err)
                }
            }
        }
    }
    
    func scrollToLeft(_ indexPath: IndexPath) throws {
        collectionView.scrollToItem(at: indexPath, at: .init(rawValue: 0), animated: false)
    }
    
    func setUpView() {
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(7.5.scalValue)
            make.right.equalToSuperview().offset(-7.5.scalValue)
        }
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let view =  UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.register(ESProHomePageFittingRoomCell.self, forCellWithReuseIdentifier: "ESProHomePageFittingRoomCell")
        view.backgroundColor = .white
        view.alwaysBounceHorizontal = true
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    fileprivate lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 130.scalValue, height: 178.scalValue)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
//        layout.sectionInset = UIEdgeInsetsMake(0, 7.5.scalValue, 0, 7.5.scalValue)
        return layout
    }()
}

extension ESProHomePageFittingListCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSFittingCase(IndexPath(item: indexPath.item, section: section))
    }
}

extension ESProHomePageFittingListCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return caseList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESProHomePageFittingRoomCell", for: indexPath) as! ESProHomePageFittingRoomCell
        let image = caseList[indexPath.item]
        cell.caseImg = image
        return cell
    }
}

