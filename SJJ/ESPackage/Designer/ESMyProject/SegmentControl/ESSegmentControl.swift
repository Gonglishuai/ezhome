//
//  ESSegmentControl.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/13.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

@objc
public protocol ESSegmentControlDelegate: NSObjectProtocol {
    @objc optional func segBtnClick(index: Int)
}

public class ESSegmentControl: UIView {
    
    public weak var delegate: ESSegmentControlDelegate?
    public var lineColor: UIColor = UIColor.red
    public var titleColor: UIColor = UIColor.red
    public var titlePlaceColor: UIColor = UIColor.lightGray
    public var time: TimeInterval = 0.2
    public var selectedIndex: Int = 0
    public var titleFont: UIFont = ESFont.font(name: .regular, size: 17.0)
    
    private var titles: [String] = []
    private var titleBtns: [UIButton] = []
    private var lineView: UIView = UIView()
    private var lastTag: Int = 0
    private var titlesWidth: CGFloat = 0.0
    private var selectedBtn: UIButton!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initUI() {
        lineView.clipsToBounds = true
        lineView.layer.cornerRadius = 1.0
        self.addSubview(lineView)
    }
    
    
    // MARK: Public Methods
    public func createSegUI(titles: [String]) {
        self.titles = titles
        let widths = getButtonsWidth(titles)
        let spaceWidth = (self.frame.size.width - titlesWidth) / CGFloat(titles.count + 1)
        var x = spaceWidth
        let y = CGFloat(0.0)
        let btnHeight = self.frame.size.height

        // create buttons.
        for (index, value) in titles.enumerated() {
            let title = value
            let btnWidth = CGFloat(widths[index].doubleValue)
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.setTitleColor(titleColor, for: .selected)
            button.setTitleColor(titlePlaceColor, for: .normal)
            button.titleLabel?.font = titleFont
            button.frame = CGRect(x: x, y: y, width: btnWidth, height: btnHeight)
            button.addTarget(self, action: #selector(segButtonClick), for: .touchUpInside)
            button.tag = index
            
            self.addSubview(button)
            x += btnWidth + spaceWidth
            
            if index == selectedIndex {
                button.isSelected = true
                self.selectedBtn = button;
                lastTag = index;
            }
            titleBtns.append(button)
        }
    
        lineView.backgroundColor = titles.count > 1 ? lineColor : UIColor.clear
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.01) {
            DispatchQueue.main.async {
                self.setNeedsLayout()
            }
        }
        
    }
    
    public func updateSelectedSegment(index: Int) {
        if lastTag == index {
            return
        }
        lastTag = index
        self.changeButtonStatus(btnTag: index)
        
        var lineViewX = selectedBtn.frame.origin.x
        if let label = selectedBtn.titleLabel {
            lineViewX += label.frame.origin.x
        }
        let lineViewW = self.selectedBtn.titleLabel?.frame.size.width;
        
        UIView.animate(withDuration: time) {
            self.lineView.frame = CGRect(x: lineViewX, y: self.frame.size.height - 2, width: lineViewW ?? 0, height: CGFloat(2))
        }
    }
    
    private func getButtonsWidth(_ titles: [String]) -> [NSNumber]{
        var widths: [NSNumber] = [];
    
        for title in titles {
            let size = NSString(format: "%@", title).size(withAttributes: [NSAttributedStringKey.font : titleFont])
            let width = size.width;
            titlesWidth += width;
            let widthObj = NSNumber(value: Float(width))
            widths.append(widthObj)
        }
    
        return widths;
    }
    
    // MARK: Button Click
    @objc private func segButtonClick(btn: UIButton) {
        if (btn.tag == lastTag) {
            return;
        }
        
        updateSelectedSegment(index: btn.tag)

        delegate?.segBtnClick?(index: btn.tag)
    }
    
    
    
    private func changeButtonStatus(btnTag: Int) {
        for button in titleBtns {
            if button.tag == btnTag {
                button.isSelected = true;
                selectedBtn = button
                self.setNeedsLayout()
            } else {
                button.isSelected = false
            }
        }
    }
    
    // MARK: Super Method
    override public func layoutSubviews() {
        super.layoutSubviews()
        var lineViewX = selectedBtn.frame.origin.x
        if let label = selectedBtn.titleLabel {
            lineViewX += label.frame.origin.x
        }
        let lineViewW = selectedBtn.titleLabel?.frame.size.width;
        lineView.frame = CGRect(x: lineViewX, y: self.frame.size.height - 2, width: lineViewW ?? 0, height: 2)
    }
}


