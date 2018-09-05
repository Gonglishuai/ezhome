//
//  ESCycleScrollView.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//  轮播控件

import UIKit

@objc public protocol ESCycleScrollViewDelegate {
    /// 已选择哪个条目
    @objc optional func cycleScrollView(_ cycleScrollView: ESCycleScrollView, didSelectItemAt indexPath: IndexPath)
    
    /// 图片滚动回调
    @objc optional func cycleScrollView(_ cycleScrollView:ESCycleScrollView, didScrollTo index:Int)
    
    /// 如果 ESCycleType 为 Custom 类型， 则需要实现此方法获取自定义cell
    @objc optional func getCustomCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

enum ESCycleType {
    /// 纯图片
    case Image
    /// 纯文字
    case Text
    /// 自定义
    case Custom
}

public class ESCycleScrollView: UIView {

    //==================================
    // MARK: - 可配置参数
    //==================================
    override public var frame: CGRect {
        didSet {
            flowLayout.itemSize = frame.size
            mainView.frame = bounds
        }
    }
    
    /// 轮播控件默认背景图
    var placeholderImage: UIImage? {
        didSet {
            backgroundImageView.image = placeholderImage
        }
    }
    
    /// 轮播方向(默认为横向)
    var direction: UICollectionViewScrollDirection = .horizontal {
        didSet {
            flowLayout.scrollDirection = direction
        }
    }
    
    var panGestureEnable: Bool = true
    
    /// 数据源
    var dataArray: [Any?] = [] {
        didSet {
            reloadData()
        }
    }
    
    /// 自动轮播定时器
    var timer: Timer?
    
    /// 是否自动滚动
    var isAutoScroll: Bool = false {
        didSet {
            timer?.invalidate()
            timer = nil
            if isAutoScroll == true {
                setupTimer()
            }
        }
    }
    
    /// 自动滚动时间间隔
    var autoScrollInterval: TimeInterval = 2.0
    
    /// 是否无线轮播
    var isEndlessScroll:Bool = true {
        didSet {
            reloadData()
        }
    }
    
    /// pageControl相关
    var pageControl: ESCyclePageControl?
    
    var outerPageControlFrame: CGRect? {
        didSet {
            setupPageControl()
        }
    }
    
    var defaultPageDotImage: UIImage? {
        didSet {
            setupPageControl()
        }
    }
    var currentPageDotImage: UIImage? {
        didSet {
            setupPageControl()
        }
    }
    
    var pageControlAliment: ESCyclePageControlAliment = .CenterBottom
    
    var pageControlPointSpace: CGFloat = 15 {
        didSet {
            setupPageControl()
        }
    }
    
    var showPageControl: Bool = false {
        didSet {
            setupPageControl()
        }
    }
    
    var currentDotColor: UIColor = UIColor.orange {
        didSet {
            self.pageControl?.currentPageIndicatorTintColor = currentDotColor
        }
    }
    
    var otherDotColor: UIColor = UIColor.gray {
        didSet {
            self.pageControl?.pageIndicatorTintColor = otherDotColor
        }
    }
    
    //==================================
    // MARK: - 构造方法
    //==================================
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - delegate: 设置代理
    ///   - type: 轮播控件类型
    init(delegate: ESCycleScrollViewDelegate?, type: ESCycleType, frame: CGRect) {
        super.init(frame: frame)
        self.delegate = delegate
        self.type = type
        flowLayout.itemSize = frame.size
        setUpMainView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //==================================
    // MARK: - 公共方法
    //==================================
    /// 注册自定义cell
    ///
    /// - Parameters:
    ///   - viewClass: 自定义cell的class
    ///   - reuseIdentifier: 复用标识
    func setUpCustomCell(_ viewClass: Swift.AnyClass?, reuseIdentifier: String) {
        mainView.register(viewClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func reloadData() {
        invalidateTimer()
        mainView.reloadData()
        
        setupPageControl()
        mainView.isScrollEnabled = canScroll
        if !canScroll {
            isAutoScroll = false
        }
        changeToFirstCycleCell(animated: false, collectionView: mainView)
        if isAutoScroll {
            setupTimer()
        }
        guard let pageControl = self.pageControl else {
            return
        }
        
        if showPageControl == true {
            if let outFrame = outerPageControlFrame {
                self.relayoutPageControl(pageControl: pageControl, outerFrame: outFrame)
            } else {
                self.relayoutPageControl(pageControl: pageControl)
            }
        }
    }
    
    
    //==================================
    // MARK: - 私有方法
    //==================================
    /// 配置主View
    private func setUpMainView() {
        addSubview(backgroundImageView)
        addSubview(mainView)
    }
    
    fileprivate func changeCycleCell(collectionView: UICollectionView) {
        guard totalItems > 1 else {
            return
        }
        
        let curItem = getCurrentIndex()
        let targetIndex = curItem + 1
        scrollToIndex(targetIndex)
    }
    
    func scrollToIndex(_ targetIndex: Int) {
        if targetIndex >= totalItems {
            let animated = isEndlessScroll ? false : true
            changeToFirstCycleCell(animated: animated, collectionView: mainView)
            return
        }
        mainView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: .init(rawValue: 0), animated: true)
    }
    
    fileprivate func getCurrentIndex() -> Int {
        let w = frame.size.width
        let h = frame.size.height
        if w == 0 || h == 0 {
            return 0
        }
        
        var index = 0
        if direction == .horizontal {
            index = Int((mainView.contentOffset.x + flowLayout.itemSize.width * 0.5) / flowLayout.itemSize.width)
        } else {
            index = Int((mainView.contentOffset.y + flowLayout.itemSize.height * 0.5) / flowLayout.itemSize.height)
        }
        return max(0, index)
    }
    
    fileprivate func changeToFirstCycleCell(animated: Bool, collectionView: UICollectionView) {
        guard totalItems != 0 else {
            return
        }
        
        let firstItem = (isEndlessScroll == true) ? (totalItems / 2) : 0
        let indexPath = IndexPath(item: firstItem, section: 0)
        mainView.scrollToItem(at: indexPath, at: .init(rawValue: 0), animated: animated)
    }
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        mainView.contentInset = .zero
        if isLoadOver == false && canScroll == true {
            changeToFirstCycleCell(animated: false, collectionView: mainView)
        }
        
        guard let pageControl = self.pageControl else {
            return
        }
        
        if showPageControl == true {
            if let outFrame = outerPageControlFrame {
                self.relayoutPageControl(pageControl: pageControl, outerFrame: outFrame)
            } else {
                self.relayoutPageControl(pageControl: pageControl)
            }
        }
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        // 解决定时器导致的循环引用
        super.willMove(toSuperview: newSuperview)
        // 展现的时候newSuper不为nil，离开的时候newSuper为nil
        guard let _ = newSuperview else {
            timer?.invalidate()
            timer = nil
            return
        }
    }
    
    deinit {
        mainView.delegate = nil
        mainView.dataSource = nil
        print("ESCycleScrollView  deinit")
    }
    
    //==================================
    // MARK: - 私有参数
    //==================================
    /// 代理
    private var delegate: ESCycleScrollViewDelegate?
    
    /// 背景图
    private lazy var backgroundImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    /// 轮播控件类型(默认为图片)
    private var type: ESCycleType = .Image
    
    let endlessScrollTimes: Int = 200
    
    fileprivate var totalItems: Int {
        var total = dataArray.count
        if dataArray.count > 1, isEndlessScroll {
            total = dataArray.count * endlessScrollTimes
        }
        return total
    }
    
    fileprivate var firstItem: Int {
        return isEndlessScroll ? (totalItems / 2) : 0
    }
    
    fileprivate var canScroll: Bool {
        return totalItems  > 1
    }
    
    fileprivate var indexOnPageControl: Int {
        var curIndex = getCurrentIndex()
        curIndex = max(0, curIndex)
        return curIndex % dataArray.count
    }
    
    /// 布局
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = direction
        return layout
    }()
    
    /// CollectionView
    private lazy var mainView: UICollectionView = {
        let view = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        view.backgroundColor = UIColor.clear
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.register(ESCycleImageCell.self, forCellWithReuseIdentifier: "ESCycleImageCell")
        view.register(ESCycleTextCell.self, forCellWithReuseIdentifier: "ESCycleTextCell")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    // 标识子控件是否布局完成，布局完成后在layoutSubviews方法中就不执行 changeToFirstCycleCell 方法
    fileprivate var isLoadOver = false
}

// MARK: - UICollectionViewDelegate
extension ESCycleScrollView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let curIndex = indexPath.item % dataArray.count
        delegate?.cycleScrollView?(self, didSelectItemAt: IndexPath(item: curIndex, section: 0))
    }
}

// MARK: - UICollectionViewDataSource
extension ESCycleScrollView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let curIndex = indexPath.item % dataArray.count

        switch type {
        case .Image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESCycleImageCell", for: indexPath) as! ESCycleImageCell
            cell.delegate = self
            cell.updateCell(index: curIndex)
            return cell
        case .Text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ESCycleTextCell", for: indexPath) as! ESCycleTextCell
            cell.delegate = self
            cell.updateCell(index: curIndex)
            return cell
        case .Custom:
            if let cell = delegate?.getCustomCell?(collectionView, cellForItemAt: indexPath) {
                return cell
            }

            return UICollectionViewCell(frame: .zero)
        }
    }
}

// MARK: - ESCycleImageCellDelegate
extension ESCycleScrollView: ESCycleImageCellDelegate {
    func getImgModel(index: Int) -> ESCycleImage? {
        if dataArray.count <= index {
            return nil
        }
        if let cycleImg = dataArray[index] as? ESCycleImage {
            return cycleImg
        }
        return nil
    }
}

// MARK: - ESCycleTextCellDelegate
extension ESCycleScrollView: ESCycleTextCellDelegate {
    func getText(index: Int) -> ESCycleText? {
        if dataArray.count <= index {
            return nil
        }
        if let text = dataArray[index] as? ESCycleText {
            return text
        }
        return nil
    }
}

// MARK: - 定时器、自动滚动、scrollView代理方法
extension ESCycleScrollView: UIScrollViewDelegate
{
    func setupTimer() {
        timer = Timer(timeInterval: autoScrollInterval, target: self, selector: #selector(autoChangeCycleCell), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    @objc func autoChangeCycleCell() {
        if canScroll == true {
            changeCycleCell(collectionView: mainView)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoScroll == true {
            setupTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard canScroll else {
            return
        }
        delegate?.cycleScrollView?(self, didScrollTo: indexOnPageControl)
        
        if indexOnPageControl >= firstItem {
            isLoadOver = true
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.panGestureRecognizer.isEnabled = panGestureEnable
        
        guard canScroll else {
            return
        }
        pageControl?.currentPage = indexOnPageControl
    }
}

// MARK: - pageControl页面
extension ESCycleScrollView {
    fileprivate func setupPageControl() {
        pageControl?.removeFromSuperview()
        if showPageControl == true {
            pageControl = ESCyclePageControl(frame: .zero, currentImage: currentPageDotImage, defaultImage: defaultPageDotImage)
            pageControl?.numberOfPages = dataArray.count
            pageControl?.hidesForSinglePage = true
            pageControl?.currentPageIndicatorTintColor = self.currentDotColor
            pageControl?.pageIndicatorTintColor = self.otherDotColor
            pageControl?.isUserInteractionEnabled = false
            pageControl?.pointSpace = pageControlPointSpace
            
            if let _ = outerPageControlFrame {
                superview?.addSubview(pageControl!)
            } else {
                addSubview(pageControl!)
            }
        }
    }
    
    fileprivate func relayoutPageControl(pageControl: ESCyclePageControl) {
        if pageControl.isHidden == false {
            let pageH:CGFloat = 20//pageControl.pageSize.height
            let pageY = bounds.height - pageH
            let pageW = pageControl.pageSize.width
            var pageX:CGFloat = 0
            
            switch self.pageControlAliment {
            case .CenterBottom:
                pageX = CGFloat(self.bounds.width / 2) - pageW * 0.5
            case .RightBottom:
                pageX = bounds.width - pageW - 15
            case .LeftBottom:
                pageX = bounds.origin.x + 15
            }
            pageControl.frame = CGRect(x:pageX, y:pageY, width:pageW, height:pageH)
        }
    }
    
    func relayoutPageControl(pageControl: ESCyclePageControl, outerFrame: CGRect) {
        if pageControl.isHidden == false {
            pageControl.frame = CGRect(x:outerFrame.origin.x, y:outerFrame.origin.y, width:pageControl.pageSize.width, height:pageControl.pageSize.height)
        }
    }
}
