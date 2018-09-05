//
//  ESCommonPickerView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  通用pickerView 1栏

import UIKit
import SnapKit

protocol ESCommonPickerViewDelegate: NSObjectProtocol {
    
    /// 确认选择
    ///
    /// - Parameter info: ESPickerModel
    func confirm(info: ESPickerModel)
}

fileprivate let ADDR_PICKERVIEW_HEIGHT = 260
fileprivate let ADDR_TOOLBAR_HEIGHT = 44

public struct ESPickerModel {
    var key: String = ""
    var value: String = ""
}

public class ESCommonPickerView: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    private weak var delegate: ESCommonPickerViewDelegate?
    private var topConstraint: Constraint?
    private var dataArr: [ESPickerModel] = []
    
    init(controller: ESCommonPickerViewDelegate?, dataArr: [ESPickerModel]) {
        super.init()

        assert(dataArr.count > 0, "picker data not null")

        self.delegate = controller
        self.dataArr = dataArr
        self.selectedItem = dataArr[0]
        if let vc = self.delegate as? UIViewController {
            vc.view.addSubview(self.backView)
            addSubviews()
            setConstraints()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(model: ESPickerModel?) {
        self.backView.isHidden = false
        
        if let item = model, !ESStringUtil.isEmpty(item.key) {
            selectedItem = item
            for (index, picker) in dataArr.enumerated() {
                if item.key == picker.key {
                    pickerView.selectRow(index, inComponent: 0, animated: false)
                }
            }
        }
        
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
        delegate?.confirm(info: selectedItem!)
        
        UIView.transition(with: containerView, duration: 0.2, options: .curveEaseOut, animations: {
            self.topConstraint?.update(offset: 0)
            self.backView.layoutIfNeeded()
        }) { (finish) in
            if finish {
                self.backView.isHidden = true
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArr.count
    }
    
    // MARK: - UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = dataArr[row]
        return item.value
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let label = view as? UILabel else {
            let view = UILabel(frame: CGRect(x: 0, y: 0, width: ESDeviceUtil.screen_w, height: 30))
            view.font = ESFont.font(name: .regular, size: 14.0)
            view.textColor = UIColor.black
            view.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
            view.textAlignment = .center
            view.adjustsFontSizeToFitWidth = true
            return view
        }
        
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = dataArr[row]
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
            self.topConstraint = make.top.equalTo(self.maskerView.snp.bottom).constraint
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
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.isHidden = true
        return view
    }()
    
    private lazy var maskerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.isHidden = true
        view.frame = CGRect(x: 0, y: 0, width: ESDeviceUtil.screen_w, height: ESDeviceUtil.screen_h)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESCommonPickerView.cancelBtnClick))
        view.addGestureRecognizer(tgr)
        return view
    }()
    
    private lazy var pickerView: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        var items: [UIBarButtonItem] = []
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(ESCommonPickerView.cancelBtnClick))
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
        
        let doneBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(ESCommonPickerView.doneBtnClick))
        items.append(doneBtn)
        
        bar.items = items
        return bar
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private var selectedItem: ESPickerModel!
}
