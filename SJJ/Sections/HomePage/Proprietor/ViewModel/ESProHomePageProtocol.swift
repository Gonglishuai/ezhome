//
//  ESProHomePageProtocol.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProHomePageCommonCellDelegate: ESProHomePageNavigationCellDelegate,
ESProHomePageRecommendCellDelegate,
ESProHomePageSampleRoomCellDelegate,
ESProHomePageCasesCellDelegate,
ESProHomePageFittingListCellDelegate,
ESProHomePageOtherCaseCellDelegate {
    
}

protocol ESProHomePageCellCommonProtocol {
    weak var delegate: ESProHomePageCommonCellDelegate? {get set}
    func updateCell(_ indexPath: IndexPath)
}

enum ESProHomePageCellID: String {
    /// 轮播图
    case CarouselsCell = "ESHomePageLoopCell"
    /// 导航类目
    case Category = "ESProHomePageNavigationCell"
    /// 头条
    case Headline = "ESHomePageHeadlineCell"
    /// 推荐
    case Recommend = "ESProHomePageRecommendCell"
    /// 样板间
    case Sample = "ESProHomePageSampleRoomCell"
    /// 推荐案例位
    case CaseList = "ESProHomePageCasesCell"
    /// 家装试衣间
    case FittingRoom = "ESProHomePageFittingListCell"
    /// 其他栏位 案例
    case OtherCase = "ESProHomePageOtherCaseCell"
    /// 其他栏位 社区
    case OtherCommunity = "ESProHomePageOtherCommunityCell"
    /// 其他栏位 广告
    case OtherAD = "ESProHomePageOtherADCell"
}
