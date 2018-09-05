//
//  ESBasicViewController.swift
//  ESPackage
//
//  Created by zhang dekai on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

let ScreenWidth = UIScreen.main.bounds.size.width;
let ScreenHeight = UIScreen.main.bounds.size.height;

let SCREEN_SCALE = (ScreenWidth / 375.0) as CGFloat
let TABBAR_HEIGHT = 49.0 as CGFloat
let STATUSBAR_HEIGHT = UIApplication.shared.statusBarFrame.size.height as CGFloat
let NAVBAR_HEIGHT = (STATUSBAR_HEIGHT+44) as CGFloat
let DECORATION_SEGMENT_HEIGHT = 40 as CGFloat
let BOTTOM_SAFEAREA_HEIGHT = ((STATUSBAR_HEIGHT == 44) ? 17:0) as CGFloat//底部非安全区域高度

public class ESBasicViewController: UIViewController {
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
    }
    
    func initNavigationBar() {
        
        view.backgroundColor = UIColor.white
        navigationItem.hidesBackButton = true
        
        findHairlineImageViewUnder(view: (navigationController?.navigationBar)!).isHidden = true
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
        
//        let image = ESColor.getImage(color: UIColor.white)
//        navigationController?.navigationBar.setBackgroundImage(image, for: .any, barMetrics: .default)
        
        addBottomLine()
        
    }
    
    //MARK: - NavigationBar Public Method
    
    /// 设置导航返回键加标题
    ///
    /// - Parameter title: 标题
    public func setupNavigationTitleWithBack(title:String?) {
        setupNavigationBarBack()
        navigationItem.title = title ?? ""
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font:ESFont.font(name: ESFont.ESFontName.regular, size: 16)]
    }
    
    
    /// 设置导航返回键（灰色箭头）
    public func setupNavigationBarBack() {
        
        let leftItem = UIBarButtonItem(image: nil, style: UIBarButtonItemStyle.plain, target: self, action: #selector(navigationBarBackAction))
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.leftBarButtonItem?.image = ESPackageAsserts.bundleImage(named: "navigation_back").withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    }
    
    /// 设置导航leftItem标题
    ///
    /// - Parameter title: title
    public func setupNavigationBarLeftWithTitle(title:String?) {
        
        let leftItem = UIBarButtonItem(title: title ?? "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(navigationBarLeftAction))
        navigationItem.leftBarButtonItem = leftItem
    }
    
    /// setup 导航LeftItem 图片
    ///
    /// - Parameter image: UIImage
    public func setupNavigationBarLeftWithImage(image:UIImage?) {
        
        let rightItem = UIBarButtonItem(image: image ?? nil, style: UIBarButtonItemStyle.plain, target: self, action: #selector(navigationBarLeftAction))
        navigationItem.leftBarButtonItem = rightItem
        navigationItem.leftBarButtonItem?.image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
    }
    
    /// setup RightItem 标题（标题原生的，非定制）
    ///
    /// - Parameter title: String
    public func setupNavigationBarRightWithTitle(title:String?) {
        
        let rightItem = UIBarButtonItem(title: title ?? "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(navigationBarRightAction))
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    /// setup RightItem 图片
    ///
    /// - Parameter image: UIImage
    public func setupNavigationBarRightWithImage(image:UIImage?) {
        
        let rightItem = UIBarButtonItem(image: image ?? nil, style: UIBarButtonItemStyle.plain, target: self, action: #selector(navigationBarRightAction))
        self.navigationItem.rightBarButtonItem = rightItem
        navigationItem.rightBarButtonItem?.image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
    }
    
    /// setup RightItem 标题（定制的）
    ///
    /// - Parameters:
    ///   - title: String
    ///   - color: UIColor
    ///   - font: UIFont
    public func setupCustomRightItemWithTitle(title:String?, color:UIColor?, font:UIFont?) {
        
        let rightItem = UIBarButtonItem(title: title ?? "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(navigationBarRightAction))
        
        navigationItem.rightBarButtonItem = rightItem
        navigationItem.rightBarButtonItem?.tintColor = color
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font : font ?? UIFont.systemFont(ofSize: 16)], for: .normal)
        
    }
    
    //MARK: - NavigationBar Action
    @objc func navigationBarBackAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func navigationBarLeftAction(){
        
    }
    
    @objc func navigationBarRightAction(){
        
    }

    
    //MARK: - Memory Warning
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     隐藏导航底部黑线
     
     - parameter view: self.navigationController?.navigationBar
     
     - returns: 底部线的UIImageView
     */
    func findHairlineImageViewUnder(view : UIView)-> UIImageView! {
        
        if view.isKind(of: UIImageView.self) && view.bounds.size.height <= 1.0  {
            
            return view as! UIImageView
            
        }
        
        for subview in view.subviews {
            
            let imageView = self .findHairlineImageViewUnder(view: subview)
            
            if (imageView != nil) {
                return imageView
            }
        }
        return nil
    }
    
    private func addBottomLine() {
        
        
        let line = UIView(frame: CGRect(x: 0, y:44 , width: ScreenWidth, height: 0.5))
        
        navigationController?.navigationBar.addSubview(line)
        
        line.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        line.backgroundColor = ESColor.color(hexColor: 0xE5E5E5, alpha: 1)

    }
    
}
