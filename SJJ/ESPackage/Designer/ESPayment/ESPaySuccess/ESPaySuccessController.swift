//
//  ESPaySuccessController.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/14.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESPaySuccessConfig {
    var amount: Double?
    var detailVC: UIViewController?
}

class ESPaySuccessController: UIViewController {

    var config = ESPaySuccessConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
        show()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let res = navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)), res {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let res = navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)), res {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    private func show() {
        let amountStr = String(format: "¥%.2f", config.amount ?? 0.0)
        amountLabel.text = amountStr
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func detailBtnClick(_ sender: UIButton) {
        navigationController?.navigationBar.isHidden = false
        popToVC(config.detailVC)
    }
    
    @IBAction func returnHomeBtnClick(_ sender: UIButton) {
        navigationController?.navigationBar.isHidden = false
        MGJRouter.openURL("/Shejijia/Home")
    }
    
    private func popToVC(_ vc: UIViewController?) {
        var result: UIViewController?
        if let viewControllers = navigationController?.viewControllers {
            for controller in viewControllers.reversed() {
                if controller == vc {
                    result = vc
                    break
                }
            }
        }
        
        if result != nil {
            navigationController?.popToViewController(result!, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func configView() {
        detailButton.backgroundColor = UIColor.white
        detailButton.setTitleColor(ESColor.color(sample: .buttonBlue), for: .normal)
        configCorner(detailButton, ESColor.color(sample: .buttonBlue))
        
        returnHomeButton.backgroundColor = ESColor.color(sample: .buttonBlue)
        returnHomeButton.setTitleColor(UIColor.white, for: .normal)
        configCorner(returnHomeButton, ESColor.color(sample: .buttonBlue))
        
        detailButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(-50)
            make.centerX.equalToSuperview().offset(-(156.scalValue / 2 + 5))
            make.width.equalTo(156.scalValue)
            make.height.equalTo(45.scalValue)
        }
        
        returnHomeButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(-50)
            make.centerX.equalToSuperview().offset(156.scalValue / 2 + 5)
            make.width.equalTo(156.scalValue)
            make.height.equalTo(45.scalValue)
        }
        
    }
    
    private func configCorner(_ btn: UIButton, _ borderColor: UIColor) {
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5.0
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = borderColor.cgColor
    }
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var returnHomeButton: UIButton!
    
}
