//
//  ESGalleryView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESGalleryViewDelegate: NSObjectProtocol {
    func getNums(_ section: Int) -> Int
    func disPlaying(index: Int)
}

class ESGalleryView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    private weak var delegate: ESGalleryViewDelegate?
    private var collectionView:UICollectionView!
    
    init(delegate: ESGalleryViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        
        setUpMainView()
        setCostraints()
    }
    
    private func setUpMainView() {
        self.backgroundColor = UIColor.black
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        let width = ESDeviceUtil.screen_w
        let height = ESDeviceUtil.screen_h
        collectionViewLayout.itemSize = CGSize(width: width, height: height)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            let vc = delegate as! UIViewController
            vc.automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.register(ESGalleryCell.self, forCellWithReuseIdentifier: "ESGalleryCell")
        
        self.addSubview(collectionView)
    }
    
    private func setCostraints() {
        collectionView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    func deleteItem(index: Int) {
        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.getNums(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESGalleryCell", for: indexPath) as! ESGalleryCell
        cell.delegate = self.delegate as? ESGalleryCellDelegate
        cell.updateCell(indexPath.section, indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ESGalleryCell {
            //由于单元格是复用的，所以要重置内部元素尺寸
            cell.resetSize()
            delegate?.disPlaying(index: indexPath.item)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
