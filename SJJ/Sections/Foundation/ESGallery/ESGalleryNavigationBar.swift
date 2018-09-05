//
//  ESGalleryNavigationBar.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESGalleryNavigationBarDelegate: NSObjectProtocol {
    func popAction()
    func deleteAction()
}

class ESGalleryNavigationBar: UIView {
    private weak var delegate: ESGalleryNavigationBarDelegate?
    
    init(delegate:  ESGalleryNavigationBarDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.backgroundColor = ESColor.color(hexColor: 0x141519, alpha: 1.0)
        setUpViews()
    }
    
    private func setUpViews() {
        addSubview(toolbar)
        toolbar.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    @objc private func backBtnClick() {
        delegate?.popAction()
    }
    
    @objc private func deleteBtnClick() {
        delegate?.deleteAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var toolbar: UIToolbar = {
        let bar = UIToolbar(frame: .zero)
        let bgImg = ESColor.getImage(color: ESColor.color(hexColor: 0x141519, alpha: 1.0))
        bar.setBackgroundImage(bgImg, forToolbarPosition: .any, barMetrics: .default)
        bar.tintColor = ESColor.color(hexColor: 0x141519, alpha: 1.0)
        var items: [UIBarButtonItem] = []
        
        let backBtnSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        backBtnSpace.width = 8
        items.append(backBtnSpace)
        let backImg = ESPackageAsserts.bundleImage(named: "navigation_back_white").withRenderingMode(.alwaysOriginal)
        let backBtn = UIBarButtonItem(image: backImg, style: .plain, target: self, action: #selector(backBtnClick))
        items.append(backBtn)
        
        let space1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        items.append(space1)
        
        let title = UIBarButtonItem(customView: titleLabel)
        items.append(title)
        
        let space2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        items.append(space2)

        let deleteImg = ESPackageAsserts.bundleImage(named: "nav_delete").withRenderingMode(.alwaysOriginal)
        let deleteBtn = UIBarButtonItem(image: deleteImg, style: .plain, target: self, action: #selector(deleteBtnClick))
        items.append(deleteBtn)
        
        let deleteBtnSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        deleteBtnSpace.width = 8
        items.append(deleteBtnSpace)
        
        bar.items = items
        return bar
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = ESFont.font(name: .medium, size: 15.0)
        return label
    }()
}
