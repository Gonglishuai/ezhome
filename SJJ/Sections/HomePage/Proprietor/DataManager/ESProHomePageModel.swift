//
//  ESProHomePageModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/2/28.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

struct ESProHomePageModel: Codable {
    /// 轮播
    var banner: [ESProHomePageCommon]?
    /// 分类
    var navigations: [ESProHomePageCommon]?
    /// 头条
    var headline: [ESProHomePageCommon]?
    /// 推荐
    var recommend: [ESProHomePageCommon]?
    /// 推荐套餐样板间
    var recommendSampleroom: ESProHomePageSampleRoom?
    /// 推荐的案例
    var recommendCases: ESProHomePageCases?
    /// 推荐的家装试衣间
    var recommendFitting: [[ESProHomePageFittingCase]?]?
    /// 案例、社区、广告
    var recommendEspot: [ESProHomePageCommon]?
}

//====================================
// MARK: - CMS配置项通用模型
//====================================
struct ESProHomePageCommon: Codable {
    /// 操作类型
    var operation_type: String?
    /// 标题
    var title: String?
    /// 副标题
    var subTitle: String?
    /// 扩展信息
    var extend_dic: ESProHomePageExtension?
    /// 位置
    var order: Int?
    /// 点赞数
    var likeCount: Int?
    /// 评论数
    var commentCount: Int?
}

struct ESProHomePageExtension: Codable {
    /// 图片
    var image: String?
    /// 链接
    var url: String?
    /// 资源id
    var resourceId: String?
    /// 作者姓名
    var author_name: String?
    /// 标签
    var esportTag: String?
    /// 作者头像
    var author_avatar: String?
    /// 设计师头像
    var designerAvatar: String?
    /// 状态
    var status: String?
    /// title
    var title: String?
    /// 项目id
    var design_id: Int?
    /// 案例id
    var case_id: String?
    /// 是否为新案例
    var is_new: String?
    /// 案例类型
    var case_type: String?
}

//====================================
// MARK: - 推荐案例
//====================================
struct ESProHomePageCases: Codable {
    /// 标签
    var tag: [String]?
    /// 案例列表
    var list: [ESProHomePageCase]?
}

struct ESProHomePageCase: Codable {
    /// 封面图
    var cover: String?
    /// 设计师头像
    var designer_image: String?
    /// 是否为新案例
    var is_new: String?
    /// 房屋面积
    var house_area: String?
    /// 案例id
    var case_id: String?
    /// 设计师姓名
    var designer_name: String?
    /// 案例风格
    var style: String?
    /// 房屋类型
    var house_type: String?
    /// 案例名称
    var case_name: String?
    /// 案例类型 (2D / 3D)
    var case_type: String?
}

//====================================
// MARK: - 推荐样板间
//====================================
struct ESProHomePageSampleRoom: Codable {
    /// 标签
    var tag: [String]?
    /// 样板间列表
    var list: [ESProHomePageSample]?
}

struct ESProHomePageSample: Codable {
    /// 设计师头像
    var designer_image: String?
    /// 金额
    var price: String?
    /// 类型
    var package_name: String?
    /// 样板间图片
    var sampleroom_image: String?
    /// 样板间id
    var case_id: String?
    /// 描述
    var description: String?
    /// 类型
    var case_type: String?
    /// 设计师姓名
    var designer_name: String?
    /// 样板间名称
    var sampleroom_name: String?
}

//====================================
// MARK: - 推荐试衣间
//====================================
//struct ESProHomePageFitting: Codable {
//    var fengmianImage: String?
//    var caseContent: [ESProHomePageFittingCase]?
//}

struct ESProHomePageFittingCase: Codable {
    /// 试衣间案例图片
    var case_image: String?
    /// 试衣间案例id
    var case_id: String?
    /// 试衣间案例类型
    var case_type: String?
}
