//
//  ESCycleTextCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESCycleText {
    var text: String?
    var font: UIFont = ESFont.font(name: .regular, size: 15.0)
    var alignment: NSTextAlignment = .left
}

protocol ESCycleTextCellDelegate: NSObjectProtocol {
    func getText(index: Int) -> ESCycleText?
}

class ESCycleTextCell: UICollectionViewCell {
    weak var delegate: ESCycleTextCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(index: Int) {
        if let model = delegate?.getText(index: index) {
            textLabel.text = model.text
            textLabel.font = model.font
            textLabel.textAlignment = model.alignment
        }
    }
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
}
