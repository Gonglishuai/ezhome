//
//  ESDesignDetailListView.swift
//  EZHome
//
//  Created by shiyawei on 1/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESDesignDetailListViewDelegate {
    func scrollViewDidScroll(index:Int)
    func loadMoreData(index:Int)
}

class ESDesignDetailListView: UIView,UIScrollViewDelegate,ESPlanListViewRefreshDelegate,ESCaseListViewRefreshDelegate {

    
    
    
    
    var delegate:ESDesignDetailListViewDelegate?
    var index:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.scrollView)
        self.scrollView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: frame.size.height)
        
        
        self.planListView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: frame.size.height)
        
        self.scrollView.addSubview(self.planListView)
        
        self.caseListView.frame = CGRect(x: ScreenWidth, y: 0, width: ScreenWidth, height: frame.size.height)
        
        self.scrollView.addSubview(self.caseListView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
    }
    
    
    //    MARK:publick
    func changeScrollView(index:Int) {
        self.index = CGFloat(index)
        self.scrollView.setContentOffset(CGPoint(x: CGFloat(index) * ScreenWidth, y: 0), animated: true)
        
    }
    
    //MARK:UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.index = scrollView.contentOffset.x / ScreenWidth
        delegate?.scrollViewDidScroll(index: Int(self.index))
    }
    
    //    MARK:ESPlanListViewRefreshDelegate
    func loadMore() {
        self.delegate?.loadMoreData(index: Int(index))
    }
    
    //    MARK:懒加载
    lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: ScreenWidth * 2, height: 0)
        scrollView.backgroundColor = UIColor.white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    //2d效果
    lazy var planListView:ESPlanListView = {
        let view = ESPlanListView()
        view.delegate = self
        return view
    }()
    //3d案例
    lazy var caseListView:ESCaseListView = {
        let view = ESCaseListView()
        view.delegate = self
        return view
    }()
}
