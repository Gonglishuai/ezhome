//
//  ESPackageMainViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

/// 套餐入口
public  class ESPackageMainViewController: ESBasicViewController {
    
    private var container:ESPackageMainView!
    private var tabBarManager = CoTabBarControllerManager()
    private var blurImg:UIImageView!
    
    //MARK: - Life Style
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        blurImg = UIImageView(frame: view.bounds)
        
        view.addSubview(blurImg)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let back = UIVisualEffectView(effect: blurEffect)
        back.frame = blurImg.frame
        
        view.addSubview(back)
        
        container = ESPackageMainView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        view.addSubview(container)
        container.setContainerAction(self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selfDismiss))
        container.addGestureRecognizer(tap)
        
        let swip = UISwipeGestureRecognizer(target: self, action: #selector(selfDismiss))
        swip.direction = .down
        container.addGestureRecognizer(swip)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        let image = tabBarManager.backImage
        blurImg.image = image
        
        tabBarManager.tabBarController.tabBar.isHidden = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - Action
    
    @objc func selfDismiss(){
        let index:NSString = tabBarManager.selectedIndexs[0]as!NSString
        tabBarManager.setCurrentController(index.integerValue)
    }
    
    @objc func orderButtonClick(){
        print("预约")

        let appointVC = UIStoryboard.init(name: "ESAppointVC", bundle: nil).instantiateViewController(withIdentifier: "AppointVC") as! ESAppointTableVC
        appointVC.selectedType = 5
        navigationController?.pushViewController(appointVC, animated: true)
//        jumpToVC(ESFreeAppointViewController())
    }
    
    @objc func personalButtonClick(){
        print("个性化")
        jumpToVC(ESPersonalAppointViewController())
    }
    
    @objc func packageButtonClick(){
        print("套餐")
        jumpToVC(ESPackageListViewController())
    }
    
    private func jumpToVC(_ vc:ESBasicViewController){
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
