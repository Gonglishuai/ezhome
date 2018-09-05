//
//  ESProProjectDeliveryInfoCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit

protocol ESProProjectDeliveryInfoCellDelegate {
    /// 点击"查看详情"
    ///
    /// - Parameter index: 方案索引
    func deliveryDetailClick(index: Int)
    
    /// 点击 "查看方案报价"
    ///
    /// - Parameter index: 方案索引
    func deliveryQuoteClick(index: Int)
}

class ESProProjectDeliveryInfoCell: UITableViewCell, ESProjectDeliveryDelegate, ESProProjectDetailCellProtocol {

    weak var delegate: ESProProjectDetailCellDelegate?
    private var itemModel = ESProProjectDeliveryInfoViewModel()
    private var deliveryViewBottom: Constraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = ESColor.color(sample: .backgroundView)
        
        addSubviews()
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateCell(index: Int, section: Int) {
        delegate?.getViewModel(index: index, section: section, cellId: "ESProProjectDeliveryInfoCell", viewModel: itemModel)
        
        if let delivery = itemModel.delivery {
            deliveryView.isHidden = false
            deliveryView.updateView(index: index,
                                    title: delivery.name,
                                    imgUrl: delivery.url,
                                    showQuote: delivery.showQuote,
                                    pkgName: delivery.pkgName,
                                    isFinally: delivery.isFinally)
            
            self.deliveryViewBottom?.activate()
        } else {
            deliveryView.isHidden = true
            self.deliveryViewBottom?.deactivate()
        }
    }
    
    private func addSubviews() {
        self.contentView.addSubview(backView)
    }
    
    private func setConstraint() {
        backView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(800)
        }
        
        noDataLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(70)
            make.top.equalToSuperview().offset(60)
            make.bottom.equalToSuperview().offset(-60).priority(700)
            make.centerX.equalToSuperview()
        }
        
        deliveryView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            self.deliveryViewBottom = make.bottom.equalToSuperview().constraint
        }
    }
    
    // MARK: ESDesProjectDeliveryDelegate
    func detailClick(index: Int) {
        delegate?.deliveryDetailClick(index: index)
    }
    
    func quoteClick(index: Int) {
        delegate?.deliveryQuoteClick(index: index)
    }
    
    // MARK: - lazy loading
    /// 白色背景底
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(noDataLabel)
        view.addSubview(deliveryView)
        return view
    }()
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无方案信息"
        label.textColor = ESColor.color(sample: .subTitleColorB)
        label.font = ESFont.font(name: .regular, size: 13.0)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var deliveryView: ESProjectDeliveryView = {
        let view = ESProjectDeliveryView(delegate: self)
        return view
    }()

}
