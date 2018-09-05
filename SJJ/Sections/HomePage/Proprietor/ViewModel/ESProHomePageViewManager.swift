//
//  ESProHomePageViewManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESProHomePageViewManager: NSObject {
    /// 获取需要单独通知的复用view数量
    static func getNewsReadNum(_ cells: [(ESProHomePageSection, [String])]) -> Int {
        /// 所有cell
        var nums = 0
        let cellNum = cells.map ({ (section) -> Int in
            return section.1.count
        })
        
        for num in cellNum {
            nums = nums + num
        }
        
        return nums
    }
    
    static func getRegisterCells() -> [(cellClass: Swift.AnyClass, identifier: String)] {
        var cells: [(cellClass: Swift.AnyClass, identifier: String)] = [(ESHomePageLoopCell.self, ESProHomePageCellID.CarouselsCell.rawValue)]
        cells.append((ESProHomePageNavigationCell.self, ESProHomePageCellID.Category.rawValue))
        cells.append((ESHomePageHeadlineCell.self, ESProHomePageCellID.Headline.rawValue))
        cells.append((ESProHomePageRecommendCell.self, ESProHomePageCellID.Recommend.rawValue))
        cells.append((ESProHomePageSampleRoomCell.self, ESProHomePageCellID.Sample.rawValue))
        cells.append((ESProHomePageCasesCell.self, ESProHomePageCellID.CaseList.rawValue))
        cells.append((ESProHomePageFittingListCell.self, ESProHomePageCellID.FittingRoom.rawValue))
        cells.append((ESProHomePageOtherCaseCell.self, ESProHomePageCellID.OtherCase.rawValue))
        cells.append((ESProHomePageOtherCommunityCell.self, ESProHomePageCellID.OtherCommunity.rawValue))
        cells.append((ESProHomePageOtherADCell.self, ESProHomePageCellID.OtherAD.rawValue))
        return cells
    }
    
    static func getCell(_ collectionView: UICollectionView,
                        _ delegate: ESProHomePageController,
                        _ indexPath: IndexPath,
                        _ cells: [(section: ESProHomePageSection, items: [String])]) -> UICollectionViewCell? {
        if cells.count <= 0 || cells.count < indexPath.section + 1{
            return nil
        }
        let section = cells[indexPath.section].items
        if section.count <= 0 || section.count < indexPath.row + 1 {
            return nil
        }
        let cellId = section[indexPath.item]
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        if var homeCell = cell as? ESProHomePageCellCommonProtocol {
            homeCell.delegate = delegate
            homeCell.updateCell(indexPath)
        }
        
        if let loopCell = cell as? ESHomePageLoopCell {
            loopCell.delegate = delegate
            loopCell.updateCell(indexPath)
        }
        
        if let headlineCell = cell as? ESHomePageHeadlineCell {
            headlineCell.delegate = delegate
            headlineCell.updateCell(indexPath)
        }
        
        return cell
    }
    
    static func getCellSize(_ indexPath: IndexPath,
                            _ cells: [(section: ESProHomePageSection, items: [String])]) -> CGSize? {
        let section = cells[indexPath.section]
        var w: CGFloat = 0
        var h: CGFloat = 0
        switch section.section {
        case .Carousels:
            w = ESDeviceUtil.screen_w
            h = 125.0 * w / 375.0
        case .Category:
            let itemNum = CGFloat(section.items.count)
            w = (ESDeviceUtil.screen_w - 7) / itemNum
            h = 62.scalValue
        case .Headline:
            w = ESDeviceUtil.screen_w
            h = 47
        case .Recommend:
            w = ESDeviceUtil.screen_w
            h = 166.scalValue
        case .SampleRoom:
            w = ESDeviceUtil.screen_w
            h = 193.scalValue
        case .Case:
            w = ESDeviceUtil.screen_w
            h = 194.scalValue
        case .FittingRoom:
            w = ESDeviceUtil.screen_w
            h = 178.scalValue
        case .Other:
            w = ESDeviceUtil.screen_w
            let cellId = section.items[indexPath.item]
            switch cellId {
            case ESProHomePageCellID.OtherCase.rawValue:
                fallthrough
            case ESProHomePageCellID.OtherCommunity.rawValue:
                h = 216.scalValue
            case ESProHomePageCellID.OtherAD.rawValue:
                h = 162.scalValue
            default:
                break
            }
        default:
            break
        }
        return CGSize(width: w, height: h)
    }
    
    static func getRegisterSections() -> [(sectionClass: Swift.AnyClass, kind: String, identifier: String)] {
        var sections: [(sectionClass: Swift.AnyClass, kind: String, identifier: String)] = []
        sections.append((ESProHomePageNaviSectionView.self, UICollectionElementKindSectionHeader, "ESProHomePageNaviSectionView"))
        sections.append((ESProHomePageNaviSectionView.self, UICollectionElementKindSectionFooter, "ESProHomePageNaviSectionView"))
        sections.append((ESProHomePageCaseSectionView.self, UICollectionElementKindSectionHeader, "ESProHomePageCaseSectionView"))
        return sections
    }
    
    static func getSectionView(_ collectionView: UICollectionView,
                               _ delegate: ESProHomePageController,
                               _ kind: String,
                               _ indexPath: IndexPath,
                               _ cells: [(section: ESProHomePageSection, items: [String])]) -> UICollectionReusableView? {
        let section = cells[indexPath.section]
        switch section.section {
        case .Category:
            if kind == UICollectionElementKindSectionHeader {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ESProHomePageNaviSectionView", for: indexPath) as! ESProHomePageNaviSectionView
                view.height = 4.0
                view.lineViewColor = ESColor.color(hexColor: 0x6A91FE, alpha: 1.0)
                return view
            }
        case .Recommend:
            if kind == UICollectionElementKindSectionFooter {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ESProHomePageNaviSectionView", for: indexPath) as! ESProHomePageNaviSectionView
                view.height = 10.0
                view.lineViewColor = ESColor.color(hexColor: 0xEEEEEE, alpha: 1.0)
                return view
            }
        case .SampleRoom:
            fallthrough
        case .Case:
            if kind == UICollectionElementKindSectionHeader {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ESProHomePageCaseSectionView", for: indexPath) as! ESProHomePageCaseSectionView
                view.delegate = delegate
                view.updateSection(indexPath)
                return view
            }
        case .FittingRoom:
            if kind == UICollectionElementKindSectionHeader {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ESProHomePageCaseSectionView", for: indexPath) as! ESProHomePageCaseSectionView
                view.delegate = delegate
                view.updateSection(indexPath)
                return view
            } else {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ESProHomePageNaviSectionView", for: indexPath) as! ESProHomePageNaviSectionView
                view.height = 10.0
                view.lineViewColor = ESColor.color(hexColor: 0xEEEEEE, alpha: 1.0)
                return view
            }
        default:
            break
        }
        return nil
    }
    
    static func getSectionViewSize(_ kind: String,
                                   _ index: Int,
                                   _ cells: [(section: ESProHomePageSection, items: [String])]) -> CGSize? {
        let section = cells[index]
        switch section.section {
        case .Category:
            if kind == UICollectionElementKindSectionHeader {
                let w = ESDeviceUtil.screen_w
                let h = 4.0.scalValue
                return CGSize(width: w, height: h)
            }
        case .Recommend:
            if kind == UICollectionElementKindSectionFooter {
                let w = ESDeviceUtil.screen_w
                let h = 10.0.scalValue
                return CGSize(width: w, height: h)
            }
        case .SampleRoom:
            fallthrough
        case .Case:
            if kind == UICollectionElementKindSectionHeader {
                let w = ESDeviceUtil.screen_w
                let h = CGFloat(40.0)
                return CGSize(width: w, height: h)
            }
        case .FittingRoom:
            if kind == UICollectionElementKindSectionHeader {
                let w = ESDeviceUtil.screen_w
                let h = CGFloat(40.0)
                return CGSize(width: w, height: h)
            } else {
                let w = ESDeviceUtil.screen_w
                let h = 10.0.scalValue
                return CGSize(width: w, height: h)
            }
        default:
            break
        }
        return nil
    }
    
    static func getSectionInset(_ index: Int,
                                _ cells: [(section: ESProHomePageSection, items: [String])]) -> UIEdgeInsets? {
        let section = cells[index]
        switch section.section {
        case .Category:
            return UIEdgeInsets(top: 0, left: 3.5, bottom: 0, right: 3.5)
        case .FittingRoom:
            return UIEdgeInsetsMake(3.5.scalValue, 0, 15.scalValue, 0)
        default:
            break
        }
        return nil
    }
}
