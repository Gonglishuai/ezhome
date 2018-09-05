//
//  ESDesignerDetailViewController.swift
//  EZHome
//
//  Created by shiyawei on 27/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//设计师详情页

import UIKit

class ESDesignerDetailViewController: ESBasicViewController,UIScrollViewDelegate,ESDesignOtherMsgViewDelegate,ESDesignHeaderViewDelegate,ESDesignDetailListViewDelegate,ESSwitchViewDelegate,ESDesignHeaderWithoutMsgViewDelegate,ESPlanListViewScrollDelegate {
    
    
    
///设计师ID
    @objc var designId = String()
    private var designInfo = ESDesignerInfoModel()
    private var planListArr = Array<ESDesignCaseList>()
    private var caseListArr = Array<ESDesignCaseList>()
    
    private var offsetPlan = 0
    private var limitPlan = 10
    
    private var offsetCase = 0
    private var limitCase = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "详情"
        //        MARK:技术数据 需要删除
        
        
        setupNavigationBarBack()//左侧返回
        
//        let image = UIImage.init(named: "nav_share")
//        setupNavigationBarRightWithImage(image: image)//右侧分享
        
        
       
        createUIView()
        loadDesignerDetal()
        
        
        let queue = DispatchQueue.global(qos: .default)
        let group = DispatchGroup()
        
        queue.async(group: group) {
            self.loadPlanListData(isLoadMore: false)
        }
        queue.async {
            self.loadCaseListData(isLoadMore: false)
        }
        queue.async {
            self.loadEvaluateCount()
        }
    }
    //    MARK:private method
    override func navigationBarLeftAction() {
        
    }
    
    //    MARK:创建UI
    func createUIView() {
        self.view.addSubview(self.scrollView)
        
        
        self.scrollView.addSubview(self.headerView)
        self.headerView.snp.makeConstraints { (make) in
            make.top.left.equalTo(self.scrollView)
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(170)
        }
        
        self.scrollView.addSubview(self.designOtherMsgView)
        self.designOtherMsgView.snp.makeConstraints { (make) in
            make.left.equalTo(self.scrollView)
            make.width.equalTo(ScreenWidth)
            make.top.equalTo(self.headerView.snp.bottom).offset(3)
            make.height.equalTo(92)
        }
        
        self.scrollView.addSubview(self.switchView)
        self.switchView.setUIView()
        
        
        self.scrollView.addSubview(self.listScrollView)
        
        self.view.addSubview(self.designHeaderWithoutMsgView)
        self.designHeaderWithoutMsgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(85)
        }
    }
    
    //拉取评价数据，重新布置评论数页面坐标
    func resetDesignOtherMsgView(model:ESGradeModel) {
        self.designOtherMsgView.analysiEvaluateModel(model:model)
        let h = ESDesignOtherMsgView.getHeight(datas: (model.data?.comments)!)

        var rect = self.designOtherMsgView.frame
        rect.size.height = h + 3
        
        self.designOtherMsgView.frame = rect
        
        self.switchView.frame = CGRect(x: 0, y: self.designOtherMsgView.frame.maxY + 3, width: ScreenWidth, height: 60)
        self.listScrollView.frame = CGRect(x: 0, y: self.switchView.frame.maxY, width: ScreenWidth, height: ScreenHeight - 214)
        
        self.scrollView.contentSize = CGSize(width: ScreenWidth, height: ScreenHeight + 53 + self.designOtherMsgView.frame.size.height)
    }
    
    
    //    MARK:************NET Request ****************
    //    MARK:获取设计师详情
    private func loadDesignerDetal() {
        
        ESMBProgressToast.showAdd(to: self.view)
        ESDesignAPI.getDesignerInfo(withDesignerId: self.designId, success: { (dict) in
            ESMBProgressToast.hide(for: self.view)
            self.designInfo = ESDesignerInfoModel.createModel(withDic: dict) as! ESDesignerInfoModel

            self.headerView.analysisUserModel(model: self.designInfo)
            self.designOtherMsgView.analysisUserModel(model: self.designInfo)
            self.designHeaderWithoutMsgView.analysisUserModel(model: self.designInfo)
        }) { (error) in
            ESMBProgressToast.hide(for: self.view)
            ESMBProgressToast.showErrorAdd(to: self.view, text: "用户信息拉取失败")
        }
    }
    
    //    MARK:关注+取消关注
    func attentionRequest(followsType:String) {
        if followsType == "0" {//当前为：未关注状态
            ESCommentAPI.addFollow(withFollowId: self.designId, type: "0", withSuccess: { (dict) in
                self.headerView.addAttioned()
                self.designInfo.isFollowing = "1"
                
            }) { (error) in
                
            }
        }else {
            ESCommentAPI.deleteFollow(withFollowId: self.designId, type: "0", withSuccess: { (dict) in
                self.headerView.cancelAttioned()
                self.designInfo.isFollowing = "0"
            }) { (error) in
                
            }
        }
    }
    //    MARK:获取效果图list数据
    private func loadPlanListData(isLoadMore:Bool) {
        let dic = ["designer_id":self.designId,"offset":self.offsetPlan,"limit":self.limitPlan] as [String:Any]
        MPCaseBaseModel.getDataWithParameters(dic, success: { (array,count) in
            if array?.count == 0 && self.planListArr.count == 0 {
                self.listScrollView.planListView.showTopView()
                self.listScrollView.planListView.endRefresh(index: 0)
            }else {
                self.listScrollView.planListView.hidenTopView()
                self.planListArr = self.planListArr + array!
                self.offsetPlan = self.planListArr.count
                self.listScrollView.planListView.analysisPlanListModel(array:self.planListArr )
                self.listScrollView.planListView.endRefresh(index: (array?.count)!)
            }
            
            self.switchView.resetCountLabel(type: .planType,count:count!)
        }, failure: { (error) in
            
        })
        
    }
    
    //    MARK:获取3D案例list数据
    func loadCaseListData(isLoadMore:Bool) {
        let dic = ["designer_id":self.designId,"offset":self.offsetCase,"limit":self.limitCase] as [String:Any]
        MP3DCaseBaseModel.getDataWithParameters(dic, success: { (array,count) in
            
            if array?.count == 0 && self.caseListArr.count == 0 {
                self.listScrollView.caseListView.showTopView()
                self.listScrollView.caseListView.endRefresh(index: 0)
            }else {
                self.listScrollView.caseListView.hidenTopView()
                self.caseListArr = self.caseListArr + array!
                self.offsetCase = self.caseListArr.count
                self.listScrollView.caseListView.analysisCaseListModel(array:self.caseListArr)
                self.listScrollView.caseListView.endRefresh(index: (array?.count)!)
            }
            self.switchView.resetCountLabel(type: .caseType,count:count!)
            
        }) { (error) in
            
        }
    }
    //    MARK:获取评价数量
    func loadEvaluateCount() {
        ESDesignerApi.loadEvaluateList(designId: self.designId, offset: 1, limit: 1, success: { (response) in

            
            let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted) as Data
            
            let model = try? JSONDecoder().decode(ESGradeModel.self, from: data!) as ESGradeModel
            
            
            self.resetDesignOtherMsgView(model: model!)
            
        }) { (error) in
            
        }
    }
    //    MARK:UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollH = scrollView.contentOffset.y
        let originY = self.switchView.frame.origin.y
        let endY = self.designHeaderWithoutMsgView.frame.size.height
        
        let per = scrollH / (originY - endY)
        print(scrollH)
        self.designHeaderWithoutMsgView.alpha = per
        self.designOtherMsgView.alpha = 1 - per
        
        if scrollH < 182 {
            self.listScrollView.planListView.tableView.contentOffset.y = scrollH
            self.listScrollView.caseListView.tableView.contentOffset.y = scrollH
        }
        
        

    }
    //    MARK:ESPlanListViewScrollDelegate
    func didscrollView(y: CGFloat) {
        
        self.scrollView.contentOffset.y = y
        
        if y >= 182 {
            self.scrollView.contentOffset.y = 182
        }
        self.scrollViewDidScroll(self.scrollView)
        
    }
    //    MARK:ESDesignOtherMsgViewDelegate
    func showGradeDetailView() {
        print("进入评分详情")
        let vc = ESGradeListViewController()
        vc.designId = self.designId
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    //    MARK:ESDesignHeaderViewDelegate
    func attentionAction() {
        print("关注+取消关注")
        if ESLoginManager.shared().isLogin {
            attentionRequest(followsType: self.designInfo.isFollowing)
        }else {
            MGJRouter.openURL("/UserCenter/LogIn")
        }
    }
    
    func chatOnlineAction() {
        print("在线聊天")
        if ESLoginManager.shared().isLogin {
            ESNIMManager.startP2PSession(fromVc: self, withJMemberId: self.designId, andSource: .designerHome)
        }else {
            MGJRouter.openURL("/UserCenter/LogIn")
        }
        
    }
    
    func makeAppointmentAction() {
        print("立即预约")
        if !ESLoginManager.shared().isLogin {
            
            MGJRouter.openURL("/UserCenter/LogIn")
            return
        }

        let appointVC = UIStoryboard.init(name: "ESAppointVC", bundle: nil).instantiateViewController(withIdentifier: "AppointVC") as! ESAppointTableVC
        appointVC.selectedType = 7
        appointVC.isShowStyle = false
        self.navigationController?.pushViewController(appointVC, animated: true)
        
        
    }
    //    MARK:ESDesignHeaderWithoutMsgViewdelegate
    func makeAppointAction() {
        self.makeAppointmentAction()
    }
    
    func contactOnlineAction() {
        self.chatOnlineAction()
    }
    //    MARK:ESDesignDetailListViewDelegate
    func scrollViewDidScroll(index: Int) {
        self.switchView.changeSliderFrame(index: index)
    }
    func loadMoreData(index: Int) {
        if index == 0 {//效果图列表
            loadPlanListData(isLoadMore: true)
        }else {
            loadCaseListData(isLoadMore: true)
        }
    }
    
    //    MARK:ESSwitchViewDelegate
    func didSelectedIndex(index: Int) {
        self.listScrollView.changeScrollView(index: index)
    }
    
    
    //    MARK:lazy
    lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = CGSize(width: ScreenWidth, height: ScreenHeight + 230)
        scrollView.backgroundColor = UIColor.gray
        scrollView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.stec_viewBackground()
        return scrollView
    }()
    
    lazy var headerView:ESDesignHeaderView = {
        let nibView = Bundle.main.loadNibNamed("ESDesignHeaderView", owner: nil, options: nil)?.first as! ESDesignHeaderView
        nibView.delegate = self
        
        return nibView
    }()
    
    lazy var designOtherMsgView:ESDesignOtherMsgView = {
        let nibView = Bundle.main.loadNibNamed("ESDesignOtherMsgView", owner: nil, options: nil)?.first as! ESDesignOtherMsgView
        nibView.delegate = self
        return nibView
    }()
    
    lazy var switchView:ESSwitchView = {
        let view = ESSwitchView(frame: CGRect(x: 0, y: self.designOtherMsgView.frame.maxY, width: ScreenWidth, height: 60))
        view.backgroundColor = UIColor.white
        view.delegate = self
        return view
    }()
    
    lazy var listScrollView:ESDesignDetailListView = {
        let view = ESDesignDetailListView.init(frame: CGRect(x: 0, y: self.switchView.frame.maxY, width: ScreenWidth, height: ScreenHeight - 214))
        view.delegate = self
        view.planListView.sDelegate = self
        view.caseListView.sDelegate = self
        return view
    }()
    
    
    
    lazy var designHeaderWithoutMsgView:ESDesignHeaderWithoutMsgView = {
        let view = Bundle.main.loadNibNamed("ESDesignHeaderWithoutMsgView", owner: nil, options: nil)?.first as! ESDesignHeaderWithoutMsgView
        view.delegate = self
        view.alpha = 0
        view.loadView()
        return view
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}




