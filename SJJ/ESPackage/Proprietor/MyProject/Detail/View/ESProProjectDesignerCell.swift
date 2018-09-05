//
//  ESProProjectDesignerCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  消费者 - 设计师信息

import UIKit
import SnapKit

protocol ESProProjectDesignerCellDelegate {
    func designerDetail()
    func contactDesigner()
}

class ESProProjectDesignerCell: UITableViewCell, ESProDesignerInfoViewDelegate, ESProProjectDetailCellProtocol {
    weak var delegate: ESProProjectDetailCellDelegate?
    private var itemModel = ESProProjectDesignerViewModel()
    private var backViewBottom: Constraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.white
        
        addSubviews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(index: Int, section: Int) {
        delegate?.getViewModel(index: index, section: section, cellId: "ESProProjectDesignerCell", viewModel: itemModel)
        if itemModel.empty {
            designerView.isHidden = true
            backViewBottom?.deactivate()
            return
        }
        designerView.isHidden = false
        backViewBottom?.activate()
        
        designerView.updateView(header: itemModel.header, name: itemModel.name)
    }

    private func addSubviews() {
        contentView.addSubview(noDataLabel)
        contentView.addSubview(designerView)
    }
    
    private func setConstraint() {
        noDataLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(60)
            make.bottom.equalToSuperview().offset(-60).priority(800)
            make.height.equalTo(19)
        }
        designerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            self.backViewBottom = make.bottom.equalToSuperview().offset(-15).priority(800).constraint
        }
    }
    
    // MARK: - ESProDesignerInfoViewDelegate
    func designerDetailInfo() {
        delegate?.designerDetail()
    }
    
    func contactDesigner() {
        delegate?.contactDesigner()
    }
    
    private lazy var designerView: ESProDesignerInfoView = {
        let view = ESProDesignerInfoView(delegate: self)
        return view
    }()
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "暂时还没有分配设计师，请耐心等待"
        label.textColor = ESColor.color(sample: .subTitleColorB)
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textAlignment = .center
        return label
    }()
}
