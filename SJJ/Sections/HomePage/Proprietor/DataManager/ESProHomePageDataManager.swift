//
//  ESProHomePageDataManager.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

enum ESProHomePageSection {
    /// 轮播
    case Carousels
    /// 类目(navigation)
    case Category
    /// 头条
    case Headline
    /// 推荐位
    case Recommend
    /// 推荐的套餐样板间
    case SampleRoom
    /// 推荐的案例
    case Case
    /// 推荐的家装试衣间
    case FittingRoom
    /// 案例、社区、广告
    case Other
}

class ESProHomePageDataManager: NSObject {

    static func getProHomePageData(success: @escaping (ESProHomePageModel) -> Void,
                                   failure: @escaping (String) -> Void) {
        
        ESHomePageApi.getHomePageData(type: .Proprietor, isLogin: ESLoginManager.shared().isLogin, success: { (response) in
            
            if let data = response {
                print("业主主页: \(String(data: data, encoding: .utf8) ?? "error")")
                let model = try? JSONDecoder().decode(ESProHomePageModel.self, from: data)
                if model != nil {
                    success(model!)
                    return
                }
            }
            failure("网络错误, 请稍后重试!")
        }) { (error) in
            let msg = SHRequestTool.getErrorMessage(error)
            failure(msg!)
        }
    }
    
    static func getCellsId(dataModel: ESProHomePageModel) -> [(ESProHomePageSection, [String])] {
        var cells: [(section: ESProHomePageSection, data: [String])] = []
        
        /// 轮播
        cells.append((.Carousels, [ESProHomePageCellID.CarouselsCell.rawValue]))
        
        /// 导航类目
        if let naviArr = dataModel.navigations, naviArr.count > 0 {
            let categories = [String](repeatElement(ESProHomePageCellID.Category.rawValue, count: naviArr.count))
            cells.append((.Category, categories))
        }
        
        /// 头条
        cells.append((.Headline, [ESProHomePageCellID.Headline.rawValue]))
        
        /// 推荐位
        cells.append((.Recommend, [ESProHomePageCellID.Recommend.rawValue]))

        /// 推荐套餐样板间
        if let sampleArr = dataModel.recommendSampleroom?.list, sampleArr.count > 0 {
            let samples = [String](repeatElement(ESProHomePageCellID.Sample.rawValue, count: sampleArr.count))
            cells.append((.SampleRoom, samples))
        }
        
        /// 推荐的案例
        cells.append((.Case, [ESProHomePageCellID.CaseList.rawValue]))
        
        /// 推荐的家装试衣间
        if let fittingArr = dataModel.recommendFitting, fittingArr.count > 0 {
            let fittings = [String](repeatElement(ESProHomePageCellID.FittingRoom.rawValue, count: fittingArr.count))
            cells.append((.FittingRoom, fittings))
        }

        /// 其他
        if let otherArr = dataModel.recommendEspot, otherArr.count > 0 {
            var others: [String] = []
            for item in otherArr {
                if let type = item.operation_type {
                    if type == "H5"{
                        others.append(ESProHomePageCellID.OtherAD.rawValue)
                    } else if type == "EXAMPLE_DATAIL" {
                        others.append(ESProHomePageCellID.OtherCase.rawValue)
                    } else if type == "H5_BBS" {
                        others.append(ESProHomePageCellID.OtherCommunity.rawValue)
                    }
                }
            }
            cells.append((.Other, others))
        }
        
        return cells
    }
    
    // MARK: - 配置轮播图数据
    static func getCycleViewData(_ model: ESProHomePageModel) -> [String] {
        var imgs: [String] = []
        
        if let banners = model.banner, banners.count > 0 {
            let images = banners.map({(banner) -> String in
                let url = banner.extend_dic?.image ?? ""
                return url
            })
            imgs = images
        }
        
        return imgs
    }
    
    // MARK: - 导航类目数据
    static func getNavigationData(_ model: ESProHomePageModel,
                                  _ indexPath: IndexPath) -> (img: String?, title: String?) {
        if let navigations = model.navigations, navigations.count > indexPath.item {
            let navi = navigations[indexPath.item]
            return (img: navi.extend_dic?.image, title: navi.title)
        }
        return (nil, nil)
    }
    
    // MARK: - 配置头条数据
    static func getHeadlineData(_ model: ESProHomePageModel) -> [String] {
        var resultArr: [String] = []
        
        if let headlines = model.headline, headlines.count > 0 {
            let textArr = headlines.map({(headline) -> String in
                let url = headline.title ?? ""
                return url
            })
            resultArr = textArr
        }
        
        return resultArr
    }
    
    // MARK: - 配置样板间和案例、试衣间的组头数据
    static func getCaseSectionData(_ model: ESProHomePageModel,
                                   _ index: Int,
                                   _ cells: [(section: ESProHomePageSection, items: [String])]) -> (title: String?, tags: [String?])? {
        let section = cells[index]
        switch section.section {
        case .SampleRoom:
            let text = "推荐套餐样板间"
            let tags = model.recommendSampleroom?.tag
            return (text, tags ?? [])
        case .Case:
            let text = "推荐的案例"
            let tags = model.recommendCases?.tag
            return (text, tags ?? [])
        case .FittingRoom:
            let text = "推荐的家装试衣间"
            return (text, [])
        default:
            break
        }
        return nil
    }
    
    // MARK: - 获取样板间
    static func getSampleData(_ model: ESProHomePageModel,
                              _ index: Int) -> ESProHomePageSample? {
        if let samples = model.recommendSampleroom?.list, samples.count > 0 {
            let sample = samples[index]
            return sample
        }
        return nil
    }
    
    // MARK: - 试衣间
    static func getFittingData(_ model: ESProHomePageModel,
                               _ index: Int) -> [ESProHomePageFittingCase]? {
        if let fittingList = model.recommendFitting, fittingList.count > 0 {
            let room = fittingList[index]
            return room
        }
        return nil
    }
    
    // MARK: - 广告
    static func getEspotData(_ model: ESProHomePageModel,
                             _ index: Int) -> ESProHomePageCommon? {
        if let others = model.recommendEspot, others.count > 0 {
            let espot = others [index]
            return espot
        }
        return nil
    }
    
    // MARK: - 选择条目
    static func didSelectCommonItem(_ controller: ESProHomePageController,
                                    _ model: ESProHomePageModel,
                                    _ indexPath: IndexPath,
                                    _ cells: [(section: ESProHomePageSection, items: [String])]) {
        let section = cells[indexPath.section]
        switch section.section {
        case .Category:
            if let navis = model.navigations, navis.count > 0 {
                let navi = navis[indexPath.item]
                if let data = try? JSONEncoder().encode(navi) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        if let dict = json as? [AnyHashable: Any] {
                            Assistant.jump(withShowCaseDic: dict, viewController: controller)
                        }
                    } catch _ {
                    }
                }
            }
        case .SampleRoom:
            if let samples = model.recommendSampleroom?.list, samples.count > 0 {
                let sample = samples[indexPath.item]
                var dict = ["caseId": sample.case_id ?? ""]
                dict["caseType"] = sample.case_type ?? "3d"
                
                MGJRouter.openURL("/Case/CaseDetail/PackageRoom", withUserInfo: dict, completion: nil)
            }
        case .Other:
            if let espots = model.recommendEspot, espots.count > 0 {
                let espot = espots[indexPath.item]
                if espot.operation_type == "EXAMPLE_DATAIL" {
                    if let case_id = espot.extend_dic?.case_id, case_id.count > 0 {
                        var dict = ["operation_type" : "EXAMPLE_DATAIL"]
                        dict["case_id"] = case_id
                        dict["is_new"] = espot.extend_dic?.is_new ?? "1"
                        dict["type"] = espot.extend_dic?.case_type ?? "1"
                        Assistant.jump(withShowCaseDic: dict, viewController: controller)
                        return
                    }
                    
                }
                if let data = try? JSONEncoder().encode(espot) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        if let dict = json as? [AnyHashable: Any] {
                            Assistant.jump(withShowCaseDic: dict, viewController: controller)
                        }
                    } catch _ {
                    }
                }
            }
        default:
            break
        }
    }
    
    static func didSelectLoopItem(_ controller: ESProHomePageController,
                                  _ model: ESProHomePageModel,
                                  _ index: Int) {
        if let banners = model.banner, banners.count > 0 {
            let banner = banners[index]
            if banner.operation_type == "EXAMPLE_DATAIL" {
                if let case_id = banner.extend_dic?.case_id, case_id.count > 0 {
                    var dict = ["operation_type" : "EXAMPLE_DATAIL"]
                    dict["case_id"] = case_id
                    dict["is_new"] = banner.extend_dic?.is_new ?? "1"
                    dict["type"] = banner.extend_dic?.case_type ?? "1"
                    Assistant.jump(withShowCaseDic: dict, viewController: controller)
                    return
                }
            }
            if let data = try? JSONEncoder().encode(banner) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let dict = json as? [AnyHashable: Any] {
                        Assistant.jump(withShowCaseDic: dict, viewController: controller)
                    }
                } catch _ {
                }
            }
        }
    }
    
    static func didSelectHeadlineItem(_ controller: ESProHomePageController,
                                      _ model: ESProHomePageModel,
                                      _ index: Int) {
        if let items = model.headline, items.count > 0 {
            let item = items[index]
            if let data = try? JSONEncoder().encode(item) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let dict = json as? [AnyHashable: Any] {
                        Assistant.jump(withShowCaseDic: dict, viewController: controller)
                    }
                } catch _ {
                }
            }
        }
    }
    
    static func didSelectRecommend(_ controller: ESProHomePageController,
                                   _ model: ESProHomePageModel,
                                   _ index: Int) {
        if let recommends = model.recommend, recommends.count > 0 {
            let recommend = recommends[index]
            if let data = try? JSONEncoder().encode(recommend) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let dict = json as? [AnyHashable: Any] {
                        Assistant.jump(withShowCaseDic: dict, viewController: controller)
                    }
                } catch _ {
                }
            }
        }
    }
    
    static func selectRecommendCase(_ model: ESProHomePageModel,
                                    _ index: Int) {
        if let caseList = model.recommendCases?.list, caseList.count > 0 {
            let caseItem = caseList[index]
            var dict = ["caseid": caseItem.case_id ?? ""]
            dict["isnew"] = caseItem.is_new ?? ""
            
            if let type = caseItem.case_type, type == "2d" {
                dict["type"] = "2"
            } else {
                dict["type"] = "1"
            }
            MGJRouter.openURL("/Design/Example", withUserInfo: dict, completion: nil)
        }
    }
    
    static func selectFittingCase(_ model: ESProHomePageModel,
                                  _ indexPath: IndexPath) {
        if let fittingSection = model.recommendFitting, fittingSection.count > 0 {
            if let fittingList = fittingSection[indexPath.section], fittingList.count > 0 {
                let fitting = fittingList[indexPath.item]
                var dict = ["caseId": fitting.case_id ?? ""]
                dict["caseType"] = fitting.case_type ?? "3d"
                
                MGJRouter.openURL("/Case/CaseDetail/FittingRoom", withUserInfo: dict, completion: nil)
            }
        }
    }
    
    static func tapSectionMore(_ index: Int,
                               _ cells: [(section: ESProHomePageSection, items: [String])]) {
        let section = cells[index]
        switch section.section {
        case .SampleRoom:
            MGJRouter.openURL("/Design/PackageHomeList")
        case .Case:
            MGJRouter.openURL("/Case/List/CaseList")
        case .FittingRoom:
            MGJRouter.openURL("/Case/List/FittingRoom")
        default:
            break
        }
    }
}
