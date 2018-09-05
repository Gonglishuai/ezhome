//
//  ESProHomePageCaseSectionView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/3/2.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProHomePageCaseSectionViewDelegate: NSObjectProtocol {
    func getContent(_ index: Int) -> (title: String?, tags: [String?])?
    func tapMore(_ index: Int)
}

class ESProHomePageCaseSectionView: UICollectionReusableView {
    weak var delegate: ESProHomePageCaseSectionViewDelegate?
    private var index: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSection(_ indexPath: IndexPath) {
        index = indexPath.section
        if let content = delegate?.getContent(index) {
            titleLabel.text = content.title
            for tagSubView in tagListBackView.subviews {
                tagSubView.removeFromSuperview()
            }
            
            var lastView: UIView?
            for (index, tag) in content.tags.enumerated() {
                let tagView = getTagView(tag)
                tagListBackView.addSubview(tagView)
                tagView.snp.makeConstraints({ (make) in
                    make.height.equalTo(14.0)
                    make.centerY.equalToSuperview()
                    if let last = lastView {
                        make.left.equalTo(last.snp.right).offset(10.0.scalValue)
                    } else {
                        make.left.equalToSuperview().offset(10.0.scalValue)
                    }
                })
                lastView = tagView
                if index >= 1 {
                    break
                }
            }
        }
    }
    
    func setUpView() {
        backgroundColor = .white
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15.0)
            make.top.equalToSuperview().offset(11)
            make.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(30)
        }
        addSubview(rightView)
        rightView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(titleLabel)
            make.right.equalToSuperview()
            make.width.equalTo(71)
        }
        rightImg.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15.scalValue)
            make.width.equalTo(10)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        moreLabel.snp.makeConstraints { (make) in
            make.right.equalTo(rightImg.snp.left).offset(-8.scalValue)
            make.top.left.bottom.equalToSuperview()
        }
        addSubview(tagListBackView)
        tagListBackView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right)
            make.top.bottom.equalTo(titleLabel)
            make.right.equalTo(rightView.snp.left).priority(800)
        }
    }
    
    
    @objc func tapMore(_ sender: UITapGestureRecognizer) {
        delegate?.tapMore(index)
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = ESColor.color(hexColor: 0x2D2D34, alpha: 1.0)
        label.font = ESFont.font(name: .medium, size: 18.0)
        return label
    }()
    
    private lazy var rightView: UIView = {
        let view = UIView()
        let tgr = UITapGestureRecognizer(target: self, action: #selector(tapMore(_:)))
        view.addGestureRecognizer(tgr)
        view.addSubview(moreLabel)
        view.addSubview(rightImg)
        return view
    }()
    
    private lazy var moreLabel: UILabel = {
        let label = UILabel()
        label.text = "更多"
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textColor = ESColor.color(hexColor: 0x222222, alpha: 1.0)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var rightImg: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.image = UIImage(named: "home_arrow_right")
        return imgView
    }()
    
    private lazy var tagListBackView: UIView = {
        let view = UIView()
        return view
    }()
    
    private func tagBackView() -> UIView {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xEEEEEE, alpha: 1.0)
        view.layer.cornerRadius = 7.0
        return view
    }
    
    private func tagLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = ESColor.color(hexColor: 0x999999, alpha: 1.0)
        label.font = ESFont.font(name: .light, size: 9.0)
        label.textAlignment = .center
        return label
    }
    
    private func getTagView(_ text: String?) -> UIView {
        let tagView = tagBackView()
        let label = tagLabel()
        label.text = text
        tagView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5).priority(800)
            make.width.greaterThanOrEqualTo(20)
        }
        return tagView
    }
}
