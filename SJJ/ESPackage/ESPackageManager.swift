//
//  ESPackageManager.swift
//  ESPackage
//
//  Created by 焦旭 on 2018/1/3.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public class ESPackageManager: NSObject {
    public static let sharedInstance = ESPackageManager()
    
    public var host: String
    public var sign: Bool
    public var header: [String: String]?
    
    private override init() {
        self.host = ""
        self.sign = false
    }
    
    @discardableResult
    public static func configPackageModule(host: String, sign: Bool, header: [String: String]?) -> ESPackageManager {
        let manager = ESPackageManager.sharedInstance
        manager.host = host
        manager.sign = sign
        manager.header = header
        return manager
    }
    
    @objc public class func refreshDesProjectList(_ navigationController: UINavigationController?) -> ESDesProjectListController? {
        for vc in (navigationController?.viewControllers.reversed())! {
            if let dvc = vc as? ESDesProjectListController {
                dvc.requestData(more: false)
                return dvc
            }
        }
        return nil
    }
    
    @objc public class func refreshDesProjectDetail(_ navigationController: UINavigationController?) -> ESDesProjectDetailController? {
        for vc in (navigationController?.viewControllers.reversed())! {
            if let dvc = vc as? ESDesProjectDetailController {
                dvc.requestData()
                return dvc
            }
        }
        return nil
    }
    
    @objc public class func refreshProProjectList(_ navigationController: UINavigationController?) -> ESProProjectListController? {
        for vc in (navigationController?.viewControllers.reversed())! {
            if let dvc = vc as? ESProProjectListController {
                dvc.requestData(more: false)
                return dvc
            }
        }
        return nil
    }
    
    @objc public class func refreshProProjectDetail(_ navigationController: UINavigationController?) -> ESProProjectDetailContoller? {
        for vc in (navigationController?.viewControllers.reversed())! {
            if let dvc = vc as? ESProProjectDetailContoller {
                dvc.requestData()
                return dvc
            }
        }
        return nil
    }
    
    
    /// 进入业主项目详情
    ///
    /// - Parameters:
    ///   - assetId: 项目id
    ///   - navigationController: 导航器
    @objc public static func openProProjectDetal(assetId: String, navigationController: UINavigationController?) {
        let vc = ESProProjectDetailContoller(assetId: assetId, pkgViewTag: "1")
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
