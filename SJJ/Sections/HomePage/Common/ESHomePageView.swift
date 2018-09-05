//
//  ESProprietorHomePageView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESHomePageViewDelegate: NSObjectProtocol {
    /// 获取要注册的cells
    func getRegisterCells() -> [(cellClass: Swift.AnyClass, identifier: String)]
    
    /// 获取组数目
    func getSectionNums() -> Int
    
    /// 获取每组item数目
    func getItemsNums(index: Int) -> Int
    
    /// 获取cell
    func getCollectionCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell?
    
    /// 获取cell size
    func getCellSize(_ indexPath: IndexPath) -> CGSize?
    
    /// 获取要注册的section视图
    func getRegisterSections() -> [(sectionClass: Swift.AnyClass,  kind: String, identifier: String)]
    
    /// 获取section视图
    func getSectionView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView?
    
    /// 获取section视图大小
    func getSectionViewSize(_ kind: String, _ section: Int) -> CGSize?
    
    /// 获取每组Inset
    func getSectionInset(_ index: Int) -> UIEdgeInsets?
    
    /// 已选择某一条目
    func didSelcted(_ collectionView: UICollectionView, indexPath: IndexPath)
    
    /// 下拉刷新
    func mainViewRefresh()
}

class ESHomePageView: UIView {

    weak var delegate: ESHomePageViewDelegate?
    
    init(delegate: ESHomePageViewDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        setUpMainView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshMainView() {
        collectionView.reloadData()
        enRefresh()
    }
    
    func enRefresh() {
        collectionView.mj_header.endRefreshing()
    }
    
    private func setUpMainView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        if let cells = delegate?.getRegisterCells() {
            for (cellClass, identifier) in cells {
                collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
            }
        }
        
        if let sections = delegate?.getRegisterSections() {
            for (sectionClass, kind, identifier) in sections {
                collectionView.register(sectionClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
            }
        }
        
        collectionView.mj_header = ESDiyRefreshHeader(refreshingBlock: {
            self.delegate?.mainViewRefresh()
        })
    }
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.backgroundColor = UIColor.clear
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0.1
        layout.minimumLineSpacing = 0.1
        return layout
    }()
}

extension ESHomePageView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let inset = delegate?.getSectionInset(section) {
            return inset
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let size = delegate?.getSectionViewSize(UICollectionElementKindSectionHeader, section) {
            return size
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let size = delegate?.getSectionViewSize(UICollectionElementKindSectionFooter, section) {
            return size
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let cellSize = delegate?.getCellSize(indexPath) {
            return cellSize
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if #available(iOS 11.0, *) {
            view.layer.zPosition = 0
        }
    }
}

extension ESHomePageView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelcted(collectionView, indexPath: indexPath)
    }
}

extension ESHomePageView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.getItemsNums(index: section) ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return delegate?.getSectionNums() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if let cell = delegate?.getCollectionCell(collectionView, indexPath: indexPath) {
            return cell
        }
        
        return UICollectionViewCell(frame: .zero)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let view = delegate?.getSectionView(collectionView, kind: kind, indexPath: indexPath) {
            return view
        }
        return UICollectionReusableView()
    }

}
