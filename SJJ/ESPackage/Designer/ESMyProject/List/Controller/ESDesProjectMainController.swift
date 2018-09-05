//
//  ESDesProjectMainController.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/11.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  设计师我的项目

import UIKit
import SnapKit

public class ESDesProjectMainController: ESBasicViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, ESSegmentControlDelegate {

    var pageController: UIPageViewController!
    var viewControllers: [UIViewController] = []
    var currentIndex: Int = 0
    
    private lazy var titleList: [String] = {
        return ["全部", "设计装修中", "待评价", "交易完成", "交易关闭"]
    }()
    
    private lazy var segmentControl: ESSegmentControl = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40)
        var segControl = ESSegmentControl(frame: frame)
        segControl.backgroundColor = UIColor.white
        segControl.delegate = self
        segControl.lineColor = ESColor.color(hexColor: 0x2696c4, alpha: 1.0)
        segControl.titleColor = ESColor.color(hexColor: 0x2696c4, alpha: 1.0)
        segControl.titlePlaceColor = ESColor.color(hexColor: 0x2d2d34, alpha: 1.0)
        segControl.titleFont = ESFont.font(name: .regular, size: 15.0)
        segControl.createSegUI(titles: titleList)
        return segControl
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        return view
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ESColor.color(sample: .backgroundView)
        self.view.addSubview(container)
        
        setupNavigationTitleWithBack(title: "我的项目")
        setupNavigationBarRightWithImage(image: ESPackageAsserts.bundleImage(named: "nav_search"))
        
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey:NSNumber(value: 10)])
        pageController.view.backgroundColor = ESColor.color(sample: .backgroundView)
        pageController.delegate = self
        pageController.dataSource = self

        self.view.addSubview(segmentControl)

        setUpViewControllers()

        pageController.setViewControllers([viewControllers[0]], direction: .reverse, animated: true, completion: nil)

        self.addChildViewController(pageController)
        container.addSubview(pageController.view)
        
        setConstraint()
    }
    
    private func setConstraint() {
        segmentControl.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
            }
            make.height.equalTo(39)
        }
        
        container.snp.makeConstraints { (make) in
            make.top.equalTo(segmentControl.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        pageController.view.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(container)
        }
    }
    
    func setUpViewControllers() {
        // 全部
        viewControllers.append(ESDesProjectListController(type: .all))
        // 设计装修中
        viewControllers.append(ESDesProjectListController(type: .inProgress))
        // 待评价
        viewControllers.append(ESDesProjectListController(type: .evaluate))
        // 交易完成
        viewControllers.append(ESDesProjectListController(type: .dealComplete))
        // 交易关闭
        viewControllers.append(ESDesProjectListController(type: .dealClose))
    }
    
    override func navigationBarRightAction() {

       self.navigationController?.pushViewController(ESDesProjectSearchController(), animated: true)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func index(vc: UIViewController) -> Int? {
        return viewControllers.index(of: vc)
    }

    // MARK: UIPageViewControllerDataSource    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if var index = self.index(vc: viewController) {
            if index == 0 {
                return nil
            }
            index -= 1
            return viewControllers[index]
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if var index = self.index(vc: viewController) {
            index += 1
            if index == viewControllers.count {
                return nil
            }
            
            return viewControllers[index]
        }
        return nil
    }
    
    // MARK: UIPageViewControllerDelegate
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if pageViewController.viewControllers != nil && completed{
            let currentVC = pageViewController.viewControllers![0]
            if let index = index(vc: currentVC) {
                currentIndex = index
                segmentControl.updateSelectedSegment(index: index)
            }
        }
    }
    
    // MARK: ESSegmentControlDelegate
    public func segBtnClick(index: Int) {
        if index > currentIndex {
            currentIndex = index
            pageController.setViewControllers([viewControllers[index]], direction: .forward, animated: true, completion: nil)
        }else if index < currentIndex {
            currentIndex = index
            pageController.setViewControllers([viewControllers[index]], direction: .reverse, animated: true, completion: nil)
        }
    }
}
