//
//  ESCycleImageCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import Kingfisher

protocol ESCycleImageCellDelegate: NSObjectProtocol {
    /// 获取image模型
    func getImgModel(index: Int) -> ESCycleImage?
}

public class ESCycleImageCell: UICollectionViewCell {
    var delegate: ESCycleImageCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(index: Int) {
        if let model = delegate?.getImgModel(index: index) {
            switch model.type {
            case .Local(let name):
                let img = UIImage(named: name ?? "")
                imageView.image = img
            case .Net(let url):
                let imgUrl = URL(string: url ?? "")
                let options: KingfisherOptionsInfo = [.transition(.fade(1.0))]
                imageView.kf.setImage(with: imgUrl,
                                      placeholder: ESPackageAsserts.bundleImage(named: model.placeHolder ?? ""),
                                      options: options,
                                      progressBlock: nil,
                                      completionHandler: nil)
            }
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
}
