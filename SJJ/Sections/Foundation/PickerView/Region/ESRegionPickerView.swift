//
//  ESRegionPickerView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/4.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESRegionPickerViewDelegate: NSObjectProtocol {
    
    /// 确认地址
    ///
    /// - Parameter info: ESSelectedRegion
    func confirmAddress(info: ESSelectedRegion)
}

fileprivate let ADDR_PICKERVIEW_HEIGHT = 260
fileprivate let ADDR_TOOLBAR_HEIGHT = 44

public class ESRegionPickerView: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private weak var delegate: ESRegionPickerViewDelegate?
    private var province_arr: [ESRegion] = []
    private var city_arr: [ESRegion] = []
    private var district_arr: [ESRegion] = []
    private var manager: ESRegionDataManager
    
    init(controller: ESRegionPickerViewDelegate?, manager: ESRegionDataManager) {
        self.manager = manager
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
    
    func show(province: String?, city: String?, district: String?) {
        preparePickerView(province, city, district)
        self.backView.isHidden = false
        UIView.transition(with: containerView, duration: 0.2, options: .curveEaseOut, animations: {
            //self.topConstraint?.update(offset: -ADDR_PICKERVIEW_HEIGHT)
            self.backView.frame = CGRect.init(x: 0, y: ScreenHeight - 260, width: ScreenWidth, height: 260)
            self.backView.layoutIfNeeded()

        }, completion: nil)
    }
    
    @objc private func cancelBtnClick() {
    
        UIView.transition(with: containerView, duration: 0.2, options: .curveEaseOut, animations: {
            //self.topConstraint?.update(offset: 0)
            self.backView.frame = CGRect.init(x: 0, y: ScreenHeight, width: ScreenWidth, height: 260)
            self.backView.layoutIfNeeded()
        }) { (finish) in
            if finish {
                self.backView.isHidden = true
            }
        }
    }
    
    @objc private func doneBtnClick() {
        checkSelected()
        delegate?.confirmAddress(info: self.selectedRegion)
        
        UIView.transition(with: containerView, duration: 0.2, options: .curveEaseOut, animations: {
            //self.topConstraint?.update(offset: 0)
            self.backView.frame = CGRect.init(x: 0, y: ScreenHeight, width: ScreenWidth, height: 260)
            self.backView.layoutIfNeeded()
        }) { (finish) in
            if finish {
                self.backView.isHidden = true
            }
        }
    }
    
    private func checkSelected() {
        let p_index = self.pickerView.selectedRow(inComponent: 0)
        let c_index = self.pickerView.selectedRow(inComponent: 1)
        let d_index = self.pickerView.selectedRow(inComponent: 2)
        
        if self.province_arr.count > p_index {
            let province = self.province_arr[p_index]
            self.selectedRegion.province = province.name ?? ""
            self.selectedRegion.provinceCode = province.id ?? ""
        }
        if self.city_arr.count > c_index {
            let city = self.city_arr[c_index]
            self.selectedRegion.city = city.name ?? ""
            self.selectedRegion.cityCode = city.id ?? ""
        }
        if self.district_arr.count > d_index {
            let district = self.district_arr[d_index]
            self.selectedRegion.district = district.name ?? ""
            self.selectedRegion.districtCode = district.id ?? ""
        }
    }
    
    private func preparePickerView(_ province: String?, _ city: String?, _ district: String?) {
        self.province_arr = self.manager.getProvinces()
        var p_index = -1
        var c_index = -1
        var d_index = -1
        if let p_code = province, !ESStringUtil.isEmpty(p_code) {
            for (index, p) in self.province_arr.enumerated() {
                if let pid = p.id, pid == p_code {
                    p_index = index
                    break
                }
            }
            self.city_arr = self.manager.getCitys(provinceCode: p_code)
            if let c_code = city, !ESStringUtil.isEmpty(c_code) {
                for (index, c) in self.city_arr.enumerated() {
                    if let cid = c.id, cid == c_code {
                        c_index = index
                        break
                    }
                }
                self.district_arr = self.manager.getDistricts(cityCode: c_code)
                if let d_code = district, !ESStringUtil.isEmpty(d_code) {
                    for (index, d) in self.district_arr.enumerated() {
                        if let did = d.id, did == d_code {
                            d_index = index
                            break
                        }
                    }
                }
            }
        } else {
            if self.province_arr.count > 0 {
                let p = self.province_arr[0]
                self.city_arr = self.manager.getCitys(provinceCode: p.id ?? "")
                if self.city_arr.count > 0 {
                    let c = self.city_arr[0]
                    self.district_arr = self.manager.getDistricts(cityCode: c.id ?? "")
                }
            }
        }
        updatePickerView(province_index: p_index, city_index: c_index, district_index: d_index)
    }
    
    private func updatePickerView(province_index: Int, city_index: Int, district_index: Int) {
        DispatchQueue.main.async {
            self.pickerView.reloadComponent(0)
            self.pickerView.reloadComponent(1)
            self.pickerView.reloadComponent(2)
            if province_index >= 0 {
                self.pickerView.selectRow(province_index, inComponent: 0, animated: false)
            }
            if city_index >= 0 {
                self.pickerView.selectRow(city_index, inComponent: 1, animated: false)
            }
            if district_index >= 0 {
                self.pickerView.selectRow(district_index, inComponent: 2, animated: false)
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return self.province_arr.count
        }
        if component == 1 {
            return self.city_arr.count
        }
        if component == 2 {
            return self.district_arr.count
        }
        return 0
    }
    
    // MARK: - UIPickerViewDelegate
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let arr = getData(component: component)
        let region = arr[row]
        return region.name
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let label = view as? UILabel else {
            let view = UILabel(frame: CGRect(x: 0, y: 0, width: ESDeviceUtil.screen_w / 3, height: 30))
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
        reload(component: component, row: row)
    }
    
    private func reload(component: Int, row: Int) {
        switch component {
        case 0:
            if self.province_arr.count > row {
                let province = self.province_arr[row]
                self.city_arr = self.manager.getCitys(provinceCode: province.id ?? "")
                if self.city_arr.count > 0 {
                    let city = self.city_arr[0]
                    self.district_arr = self.manager.getDistricts(cityCode: city.id ?? "")
                    DispatchQueue.main.async {
                        self.pickerView.reloadComponent(1)
                        self.pickerView.reloadComponent(2)
                        self.pickerView.selectRow(0, inComponent: 1, animated: true)
                        self.pickerView.selectRow(0, inComponent: 2, animated: true)
                    }
                }
            }
        case 1:
            if self.city_arr.count > row {
                let city = self.city_arr[row]
                self.district_arr = self.manager.getDistricts(cityCode: city.id ?? "")
                DispatchQueue.main.async {
                    self.pickerView.reloadComponent(2)
                    self.pickerView.selectRow(0, inComponent: 2, animated: true)
                }
            }
        default:
            break
        }
    }
    
    private func getData(component: Int) -> [ESRegion] {
        switch component {
        case 0:
            return self.province_arr
        case 1:
            return self.city_arr
        case 2:
            return self.district_arr
        default:
            return []
        }
    }
    
    private func addSubviews() {
        backView.addSubview(maskerView)
        backView.addSubview(containerView)
        containerView.addSubview(toolbar)
        containerView.addSubview(pickerView)
    }
    
    private func setConstraints() {
        backView.frame = CGRect.init(x: 0, y: ScreenHeight, width: ScreenWidth, height: 260)
        maskerView.frame = backView.frame
        containerView.frame = CGRect.init(x: 0, y: 0, width:Int(ScreenWidth), height: ADDR_PICKERVIEW_HEIGHT)
        toolbar.frame = CGRect.init(x: 0, y: 0, width: Int(ScreenWidth), height: ADDR_TOOLBAR_HEIGHT)
        pickerView.frame = CGRect.init(x: 0, y: ADDR_TOOLBAR_HEIGHT, width: Int(ScreenWidth), height: ADDR_PICKERVIEW_HEIGHT - ADDR_TOOLBAR_HEIGHT)
    }
    
    // MARK: - lazy loading
    private lazy var pickerView: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        var items: [UIBarButtonItem] = []
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(ESRegionPickerView.cancelBtnClick))
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
        
        let doneBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(ESRegionPickerView.doneBtnClick))
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
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ESRegionPickerView.cancelBtnClick))
        view.addGestureRecognizer(tgr)
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private lazy var selectedRegion: ESSelectedRegion = {
        var region: ESSelectedRegion = ESSelectedRegion()
        return region
    }()
}
