//
//  ESProProjectRejectCancelCell.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit

protocol ESProProjectRejectCancelCellDelegate {
    func goToBooking()
}

class ESProProjectRejectCancelCell: UITableViewCell, ESProProjectDetailCellProtocol {

    weak var delegate: ESProProjectDetailCellDelegate?
    private var topViewHeight: Constraint?
    private var itemModel = ESProProjectRejectCancelViewModel()
    
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
    
    func updateCell(index: Int, section: Int) {
        delegate?.getViewModel(index: index, section: section, cellId: "ESProProjectRejectCancelCell", viewModel: itemModel)
        
        switch itemModel.type {
        case let .canceled(reasion):
            self.topViewHeight?.update(offset: 10)
            topTitle.isHidden = true
            reasonLabel.text = reasion
            reasonLabel.snp.remakeConstraints({ (make) in
                make.top.equalToSuperview().offset(42.5)
                make.width.greaterThanOrEqualTo(30)
                make.height.equalTo(19)
                make.centerX.equalToSuperview()
            })
            reasonLabel.textAlignment = .center
            reasonLabel.textColor = ESColor.color(sample: .subTitleColorB)
            bookingBtn.snp.remakeConstraints({ (make) in
                make.top.equalTo(reasonLabel.snp.bottom).offset(13)
                make.width.equalTo(73)
                make.height.equalTo(24)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-42)
            })
        case let .rejected(title, reason):
            self.topViewHeight?.update(offset: 52.5)
            topTitle.isHidden = false
            topTitle.text = title
            reasonLabel.text = reason
            reasonLabel.snp.remakeConstraints({ (make) in
                make.top.equalToSuperview().offset(15)
                make.left.equalToSuperview().offset(15)
                make.right.equalToSuperview().offset(-15)
                make.height.greaterThanOrEqualTo(60)
            })
            reasonLabel.textAlignment = .left
            reasonLabel.textColor = ESColor.color(sample: .mainTitleColor)
            bookingBtn.snp.remakeConstraints({ (make) in
                make.top.equalTo(reasonLabel.snp.bottom).offset(13)
                make.width.equalTo(73)
                make.height.equalTo(24)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-30)
            })
        default:
            break
        }
    }

    @objc private func booking() {
        delegate?.goToBooking()
    }
    
    private func addSubviews() {
        contentView.addSubview(topView)
        contentView.addSubview(bottomView)
    }
    
    private func setConstraint() {
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            self.topViewHeight = make.height.equalTo(10).constraint
        }
        bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().priority(800)
        }
    }
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        view.addSubview(topTitle)
        topTitle.snp.makeConstraints({ (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(ScreenWidth - 30)
        })
        return view
    }()
    
    private lazy var topTitle: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(sample: .subTitleColorA)
        label.font = ESFont.font(name: .regular, size: 13.0)
        return label
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(reasonLabel)
        view.addSubview(bookingBtn)
        return view
    }()
    
    private lazy var reasonLabel: UILabel = {
        let label = UILabel()
        label.font = ESFont.font(name: .regular, size: 13.0)
        return label
    }()
    
    private lazy var bookingBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = ESColor.color(sample: .buttonBlue)
        btn.layer.cornerRadius = 12.0
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 12.0)
        btn.setTitle("前往预约", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(ESProProjectRejectCancelCell.booking), for: .touchUpInside)
        return btn
    }()
}
