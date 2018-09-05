//
//  ESFaceToFaceController.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/14.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public class ESFaceToFaceController: ESBasicViewController, ESFaceToFaceViewDelegate {
    
    init(assetId: String, amount: Double, payType: ESFaceToFacePayType) {
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.amount = amount
        self.payType = payType
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitleWithBack(title: "面对面收款")
        
        view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        freshQRCode()
    }
    
    private func freshQRCode() {
        ESProgressHUD.show(in: self.view)
        ESFaceToFaceManager.requestQRUrl(assetId, amount, payType.rawValue.value, success: { (qrUrl) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.createQRImage(qrUrl)
                self.getStartTimer()
            }
        }) { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
                let qr_error = ESPackageAsserts.bundleImage(named: "qrcode_error")
                let payImg = ESPackageAsserts.bundleImage(named: self.payType.rawValue.img)
                let payText = self.payType.rawValue.text
                self.mainView.updateView(qr_error, self.amount, payImg, payText)
            }
        }
    }
    
    private func getStartTimer() {
        if !timerStarted {
            timer.resume()
            timerStarted = true
        }
    }
    
    private func checkPaymentSuccess() {
        ESFaceToFaceManager.checkPayStatus(assetId, success: { (status) in
            if status {
                self.timer.cancel()
                self.timerStarted = false
                self.mainView.doneBtn.isEnabled = true
            }
        }) { (msg) in
            
        }
    }
    
    private func createQRImage(_ url: String?) {
        ESFaceToFaceManager.createQRCode(url) { (image) in
            let payImg = ESPackageAsserts.bundleImage(named: self.payType.rawValue.img)
            let payText = self.payType.rawValue.text
            self.mainView.updateView(image, self.amount, payImg, payText)
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if self.timerStarted {
            self.timer.cancel()
        }
    }
    
    private lazy var mainView: ESFaceToFaceView = {
        let view = ESFaceToFaceView(delegate: self)
        return view
    }()
    
    // MARK: ESFaceToFaceViewDelegate
    func completeBtnClick() {
        if let dvc = ESPackageManager.refreshDesProjectDetail(navigationController) {
            let vc = ESPaySuccessController()
            vc.config = ESPaySuccessConfig(amount: self.amount, detailVC: dvc)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func refreshBtnClick() {
        freshQRCode()
    }

    private var payType: ESFaceToFacePayType = .Alipay
    private var assetId: String = ""
    private var amount: Double = 0.0
    private var timerStarted = false
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        t.schedule(deadline: .now(), repeating: 5.0)
        t.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.async {
                self?.checkPaymentSuccess()
            }
        })
        return t
    }()
}
