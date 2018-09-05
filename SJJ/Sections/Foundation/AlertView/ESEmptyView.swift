//
//  ESEmptyView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public class ESEmptyView: UIView {

    static func showEmptyView(in view: UIView, image: String, text: String) {
        var emptyView: ESEmptyView
        if let empty = defaultView(view: view) {
            emptyView = empty
        } else {
            emptyView = ESEmptyView(in: view)
        }
        emptyView.imgView.image = UIImage(named: image)
        emptyView.textLabel.text = text
    }
    
    static func hideEmptyView(in view: UIView) {
        if let empty = defaultView(view: view) {
            empty.removeFromSuperview()
        }
    }
    
    private static func defaultView(view: UIView) -> ESEmptyView? {
        for subView in view.subviews.reversed() {
            if subView is ESEmptyView {
                let result = subView as! ESEmptyView
                return result
            }
        }
        return nil
    }
    
    private init(in view: UIView) {
        super.init(frame: .zero)
        view.addSubview(self)
        self.backgroundColor = ESColor.color(sample: .backgroundView)
        self.addSubview(imgView)
        self.addSubview(textLabel)
        self.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        textLabel.snp.makeConstraints { (make) in
            make.height.greaterThanOrEqualTo(18)
            make.top.equalTo(self.snp.centerY)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        imgView.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(textLabel.snp.top).offset(-37)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: .light, size: 14.0)
        label.textAlignment = .center
        return label
    }()
}
