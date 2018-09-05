//
//  ESProProjectEmptyView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProProjectEmptyViewDelegate: NSObjectProtocol {
    func booking()
}

class ESProProjectEmptyView: UIView {

    private weak var delegate: ESProProjectEmptyViewDelegate?
    
    static func showEmptyView(in view: UIView, delegate: ESProProjectEmptyViewDelegate?) {
        var emptyView: ESProProjectEmptyView
        if let empty = defaultView(view: view) {
            emptyView = empty
        } else {
            emptyView = ESProProjectEmptyView(in: view)
        }
        emptyView.delegate = delegate
    }
    
    static func hideEmptyView(in view: UIView) {
        if let empty = defaultView(view: view) {
            empty.removeFromSuperview()
        }
    }
    
    private static func defaultView(view: UIView) -> ESProProjectEmptyView? {
        for subView in view.subviews.reversed() {
            if subView is ESProProjectEmptyView {
                let result = subView as! ESProProjectEmptyView
                return result
            }
        }
        return nil
    }
    
    private init(in view: UIView) {
        super.init(frame: .zero)
        view.addSubview(self)
        self.backgroundColor = ESColor.color(sample: .backgroundView)
        self.addSubview(topBackView)
        self.addSubview(lineView)
        self.addSubview(bottomBackView)
        self.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        topBackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            let height = CGFloat(144)
            make.height.equalTo(height.scalValue)
        }
        textLabel.snp.makeConstraints { (make) in
            make.height.greaterThanOrEqualTo(18)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(topBackView.snp.bottom)
            make.height.equalTo(10)
        }
        
        bottomBackView.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().priority(800)
        }
        let scale = 750.0 / 898.0
        imgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(imgView.snp.height).multipliedBy(scale)
            make.bottom.equalToSuperview().priority(800)
        }
        let btn_h = CGFloat(43)
        let btn_w = CGFloat(223)
        bookingBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-35)
            make.height.equalTo(btn_h.scalValue)
            make.width.equalTo(btn_w.scalValue)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func bookingBtnClick() {
        delegate?.booking()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var topBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(textLabel)
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: .light, size: 14.0)
        label.textAlignment = .center
        label.text = "暂无装修项目哦~"
        return label
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        return view
    }()
    
    lazy var bottomBackView: UIView = {
        let view = UIView()
        view.addSubview(imgView)
        view.addSubview(bookingBtn)
        return view
    }()
    
    private lazy var imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = ESPackageAsserts.bundleImage(named: "consumer_list_order")
        return imageView
    }()
    
    private lazy var bookingBtn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(ESProProjectEmptyView.bookingBtnClick), for: .touchUpInside)
        let height = CGFloat(43)
        btn.layer.cornerRadius = height.scalValue / 2.0
        btn.layer.masksToBounds = true
        btn.backgroundColor = ESColor.color(hexColor: 0xCDA86E, alpha: 1.0)
        btn.setTitle("立即预约", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        return btn
    }()
}
