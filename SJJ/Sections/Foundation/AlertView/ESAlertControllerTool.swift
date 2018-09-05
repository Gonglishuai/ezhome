//
//  ESAlertControllerTool.swift
//  Consumer
//
//  Created by xiefei on 3/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESAlertControllerTool {
    
    /**
     两个按钮 处理otherBtn事件
     */
    static func showAlert(currentVC:UIViewController, meg:String, cancelBtn:String, otherBtn:String?, handler:((UIAlertAction) -> Void)?){
        //        guard let vc = self.getCurrentVC() else{ return }
        DispatchQueue.main.async { () -> Void in
            let alertController = UIAlertController(title:"提示",
                                                    message:meg ,
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:nil)
            
            alertController.addAction(cancelAction)
            
            if otherBtn != nil{
                let settingsAction = UIAlertAction(title: otherBtn, style: .default, handler: { (action) -> Void in
                    handler?(action)
                })
                alertController.addAction(settingsAction)
            }
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     一个按钮 不处理事件
     */
    static func showAlert(currentVC:UIViewController, cancelBtn:String, meg:String){
        showAlert(currentVC: currentVC, meg: meg, cancelBtn: cancelBtn, otherBtn: nil, handler: nil)
    }
    
    /**
     两个按钮 都处理事件
     */
    static func showAlert(currentVC:UIViewController, meg:String, cancelBtn:String, otherBtn:String?,cencelHandler:((UIAlertAction) -> Void)?, handler:((UIAlertAction) -> Void)?){
        DispatchQueue.main.async { () -> Void in
            let alertController = UIAlertController(title:"提示",
                                                    message:meg ,
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title:cancelBtn, style: .cancel, handler:{ (action) -> Void in
                cencelHandler?(action)
            })
            alertController.addAction(cancelAction)
            if otherBtn != nil{
                let settingsAction = UIAlertAction(title: otherBtn, style: .default, handler: { (action) -> Void in
                    handler?(action)
                })
                alertController.addAction(settingsAction)
            }
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
}
