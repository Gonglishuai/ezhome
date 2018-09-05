//
//  ESDatePickerView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/23.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit
import SnapKit

protocol ESDatePickerViewDelegate: NSObjectProtocol {
    
    /// 确认时间
    ///
    /// - Parameter date: Date
    func confirmDate(date: Date)
}

fileprivate let ADDR_PICKERVIEW_HEIGHT = 260
fileprivate let ADDR_TOOLBAR_HEIGHT = 44

public class ESDatePickerView: NSObject {
    private weak var delegate: ESDatePickerViewDelegate?
    private var topConstraint: Constraint?
    private var selectedDate: Date!
    
    init(controller: ESDatePickerViewDelegate?) {
        super.init()
        self.delegate = controller
        
        if let vc = self.delegate as? UIViewController {
            vc.view.addSubview(self.backView)
            addSubviews()
            setConstraints()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(mode: UIDatePickerMode = .date, defaultDate: Date? = nil, minDate: Date? = nil, maxDate: Date? = nil) {
        if let deDate = defaultDate {
            selectedDate = deDate
        } else {
            selectedDate = Date()
        }
        
        pickerView.datePickerMode = mode
        pickerView.minimumDate = minDate
        pickerView.maximumDate = maxDate
        pickerView.setDate(selectedDate, animated: false)
        
        self.backView.isHidden = false
        
        UIView.transition(with: containerView, duration: 0.2, options: .curveEaseOut, animations: {
            self.topConstraint?.update(offset: -ADDR_PICKERVIEW_HEIGHT)
            self.backView.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @objc private func cancelBtnClick() {
        UIView.transition(with: containerView, duration: 0.2, options: .curveEaseOut, animations: {
            self.topConstraint?.update(offset: 0)
            self.backView.layoutIfNeeded()
        }) { (finish) in
            if finish {
                self.backView.isHidden = true
            }
        }
    }
    
    @objc private func doneBtnClick() {
        delegate?.confirmDate(date: selectedDate)
        
        UIView.transition(with: containerView, duration: 0.2, options: .curveEaseOut, animations: {
            self.topConstraint?.update(offset: 0)
            self.backView.layoutIfNeeded()
        }) { (finish) in
            if finish {
                self.backView.isHidden = true
            }
        }
    }
    
    @objc private func dateChanged() {
        selectedDate = pickerView.date
    }
    
    private func addSubviews() {
        backView.addSubview(maskerView)
        backView.addSubview(containerView)
        containerView.addSubview(toolbar)
        containerView.addSubview(pickerView)
    }
    
    private func setConstraints() {
        backView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        maskerView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        containerView.snp.makeConstraints { (make) in
            self.topConstraint = make.top.equalTo(backView.snp.bottom).constraint
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(ADDR_PICKERVIEW_HEIGHT)
        }
        toolbar.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(ADDR_TOOLBAR_HEIGHT)
        }
        pickerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(toolbar.snp.bottom)
            make.height.equalTo(ADDR_PICKERVIEW_HEIGHT - ADDR_TOOLBAR_HEIGHT)
        }
    }
    
    // MARK: - lazy loading
    private lazy var pickerView: UIDatePicker = {
        let view = UIDatePicker()
        view.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return view
    }()
    
    private lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        var items: [UIBarButtonItem] = []
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelBtnClick))
        items.append(cancelBtn)
        
        let space1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        items.append(space1)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.text = ""
        label.font = ESFont.font(name: .regular, size: 15.0)
        let title = UIBarButtonItem(customView: label)
        items.append(title)
        
        let space2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        items.append(space2)
        
        let doneBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneBtnClick))
        items.append(doneBtn)
        
        bar.items = items
        return bar
    }()
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.isHidden = true
        return view
    }()
    
    private lazy var maskerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        let tgr = UITapGestureRecognizer(target: self, action: #selector(cancelBtnClick))
        view.addGestureRecognizer(tgr)
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
}
