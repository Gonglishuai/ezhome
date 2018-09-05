//
//  ESProprietorHomePageController.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

public class ESProHomePageController: ESBasicViewController {
    
    private var dataModel = ESProHomePageModel()
    private var cells: [(section: ESProHomePageSection, items: [String])] = []
    private var newMsgRead = 0
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: Selector(("getData")), name: NSNotification.Name.homePageReload, object: nil)
        
        ESLoginManager.shared().addLoginDelegate(self)
        ESNIMManager.shared().addESIMDelegate(self)
//        view.backgroundColor = ESColor.color(hexColor: 0xEEEEEE, alpha: 1.0)
        view.backgroundColor = .white
        view.addSubview(naviBar)
        naviBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(NAVBAR_HEIGHT)
        }
        view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
//            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.left.right.equalToSuperview()
//            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }

        getData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateLocation()
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.homePageReload, object: nil)
    }
    func updateLocation() {
        let unread = ESNIMManager.shared().getNIMAllUnreadCount()
        naviBar.unreadStatusView.isHidden = unread <= 0
        
        JRLocationServices.sharedInstance().requestLocation { (info) in
            DispatchQueue.main.async {
                var cityName = "北京"
                if var city = info?.locatedCityName {
                    if city.count > 2, city.hasSuffix("市") {
                        let index = city.index(before: city.endIndex)
                        city = String(city[..<index])
                    }
                    cityName = city
                }
                self.naviBar.cityLabel.text = cityName
            }
        }
    }
    
    deinit {
        ESLoginManager.shared().removeLoginDelegate(self)
        ESNIMManager.shared().removeESIMDelegate(self)
    }
    
    public func getData() {
        ESProgressHUD.show(in: self.view)
        ESProHomePageDataManager.getProHomePageData(success: { (model) in
            DispatchQueue.main.async {
                self.dataModel = model
                self.manageData()
                ESProgressHUD.hide(for: self.view)
            }
        }) { (errMsg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: errMsg)
                self.manageData()
            }
        }
    }
    
    func manageData() {
        self.cells = ESProHomePageDataManager.getCellsId(dataModel: dataModel)
        self.newMsgRead = ESProHomePageViewManager.getNewsReadNum(self.cells)
        self.mainView.refreshMainView()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private lazy var mainView: ESHomePageView = {
        let view = ESHomePageView(delegate: self)
        return view
    }()
    
    private lazy var naviBar: ESHomePageNavigatorBar = {
        let view = Bundle.main.loadNibNamed("ESHomePageNavigatorBar", owner: nil, options: nil)?.first
        let bar = view as! ESHomePageNavigatorBar
        bar.delegate = self
        return bar
    }()
}

// MARK: - ESProHomePageCaseSectionViewDelegate
extension ESProHomePageController: ESProHomePageCaseSectionViewDelegate {
    func getContent(_ index: Int) -> (title: String?, tags: [String?])? {
        return ESProHomePageDataManager.getCaseSectionData(dataModel, index, cells)
    }
    
    func tapMore(_ index: Int) {
        ESProHomePageDataManager.tapSectionMore(index, cells)
    }
}

// MARK: - ESProHomePageViewDelegate
extension ESProHomePageController: ESHomePageViewDelegate {
    func getCellSize(_ indexPath: IndexPath) -> CGSize? {
        let size = ESProHomePageViewManager.getCellSize(indexPath, cells)
        return size
    }
    
    func getSectionInset(_ index: Int) -> UIEdgeInsets? {
        let inset = ESProHomePageViewManager.getSectionInset(index, cells)
        return inset
    }
    
    func getSectionViewSize(_ kind: String, _ section: Int) -> CGSize? {
        let size = ESProHomePageViewManager.getSectionViewSize(kind, section, cells)
        return size
    }
    
    func getRegisterSections() -> [(sectionClass: AnyClass, kind: String, identifier: String)] {
        return ESProHomePageViewManager.getRegisterSections()
    }
    
    func getSectionView(_ collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? {
        return ESProHomePageViewManager.getSectionView(collectionView, self, kind, indexPath, cells)
    }
    
    func mainViewRefresh() {
        getData()
    }
    
    func getRegisterCells() -> [(cellClass: Swift.AnyClass, identifier: String)] {
        let registerCells = ESProHomePageViewManager.getRegisterCells()
        return registerCells
    }
    
    func getSectionNums() -> Int {
        let sectionNums = cells.count
        return sectionNums
    }
    
    func getItemsNums(index: Int) -> Int {
        if cells.count <= index {
            return 0            
        }
        let itmesNums = cells[index].items.count
        return itmesNums
    }
    
    func getCollectionCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = ESProHomePageViewManager.getCell(collectionView, self, indexPath, cells)
        if newMsgRead > 0 {
            newMsgRead = newMsgRead - 1
        }
        return cell
    }
    
    func didSelcted(_ collectionView: UICollectionView, indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 4 {
            let SJJAppdelegate = UIApplication.shared.delegate as! AppDelegate
            SJJAppdelegate.gotoDIY()            
        }else{
            ESProHomePageDataManager.didSelectCommonItem(self, dataModel, indexPath, cells)
        }
    }
}

// MARK: - ESHomePageLoopCellDelegate
extension ESProHomePageController: ESHomePageLoopCellDelegate {
    func cycleViewDidSelect(_ index: Int) {
        ESProHomePageDataManager.didSelectLoopItem(self, dataModel, index)
    }
    
    func needReload() -> Bool {
        return newMsgRead > 0
    }
    
    func getImages(_ indexPath: IndexPath) -> [String] {
        let imgs = ESProHomePageDataManager.getCycleViewData(dataModel)
        return imgs
    }
}

// MARK: - ESHomePageHeadlineCellDelegate
extension ESProHomePageController: ESHomePageHeadlineCellDelegate {
    func getText(_ indexPath: IndexPath) -> [String] {
        let texts = ESProHomePageDataManager.getHeadlineData(dataModel)
        return texts
    }
    func headlineSelect(_ index: Int) {
        ESProHomePageDataManager.didSelectHeadlineItem(self, dataModel, index)
    }
}

// MARK: - ESProHomePageCommonCellDelegate
extension ESProHomePageController: ESProHomePageCommonCellDelegate {
    
    /// 导航分类
    func getNavigaionData(_ indexPath: IndexPath) -> (img: String?, title: String?) {
        let navi = ESProHomePageDataManager.getNavigationData(dataModel, indexPath)
        return navi
    }
    
    /// 推荐
    func getRecommend() -> [ESProHomePageCommon]? {
        return dataModel.recommend
    }
    
    func didSelectRecommend(_ index: Int) {
        ESProHomePageDataManager.didSelectRecommend(self, dataModel, index)
    }

    /// 样板间
    func getSampleData(_ index: Int) -> ESProHomePageSample? {
        let sample = ESProHomePageDataManager.getSampleData(dataModel, index)
        return sample
    }
    
    /// 推荐案例
    func getRecommendCases() -> [ESProHomePageCase]? {
        return dataModel.recommendCases?.list
    }
    
    func didSelectCase(_ index: Int) {
        ESProHomePageDataManager.selectRecommendCase(dataModel, index)
    }
    
    /// 家装试衣间
    func getFittingList(_ index: Int) -> [ESProHomePageFittingCase]? {
        let fitting = ESProHomePageDataManager.getFittingData(dataModel, index)
        return fitting
    }
    
    func didSFittingCase(_ indexPath: IndexPath) {
        ESProHomePageDataManager.selectFittingCase(dataModel, indexPath)
    }
    
    
    
    /// 其他
    func getOtherData(_ index: Int) -> ESProHomePageCommon? {
        return ESProHomePageDataManager.getEspotData(dataModel, index)
    }
}

extension ESProHomePageController: ESLoginManagerDelegate {
    public func onLogin() {
        getData()
    }
    
    public func onLogout() {
        getData()
    }
}

extension ESProHomePageController: ESNIMManagerDelegate {
    public func hasNewMessage(_ newMsg: Bool) {
        naviBar.unreadStatusView.isHidden = !newMsg
    }
}

extension ESProHomePageController: ESHomePageNavigatorBarDelegate {
    public func leftButtonDidTapped() {
        updateLocation()
        ESProgressHUD.showText(in: view, text: "不好意思，现在只开通了北京地区哦~")
    }
    
    public func searchButtonDidTapped() {
        MGJRouter.openURL("/Case/Search")
    }
    
    public func rightButtonDidTapped() {
        MGJRouter.openURL("/IM/ChatList")
    }
}
