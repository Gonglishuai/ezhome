//
//  ESDesignFilterData.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESFilter.h"

@interface ESFilterData : NSObject

/**
 初始化数据

 @param tags 已筛选的数据
 @param allTags 所有标签
 @param filterList 筛选列表
 @param selectItems 选择的tags集合
 @param refresh 是否需要刷新视图
 */
+ (void)initFilterData:(NSArray *)tags
           withAllTags:(NSArray *)allTags
              withList:(NSMutableArray <ESFilter *> *)filterList
          withSelected:(NSMutableSet <ESFilterItem *> *)selectItems
            andRefresh:(void(^)(void))refresh;

/**
 获取每个筛选类目下的tag数量

 @param section 组索引
 @param filterList 筛选列表
 @return tag数量
 */
+ (NSInteger)getTagsNum:(NSInteger)section
                andList:(NSMutableArray <ESFilter *> *)filterList;

/**
 选择一个tag
 
 @param section 组索引
 @param index item索引
 @param filterList 筛选列表
 @param selectItems 已选择集合
 */
+ (void)selectTagWithSection:(NSInteger)section
                   withIndex:(NSInteger)index
                    withList:(NSMutableArray <ESFilter *> *)filterList
              andSelected:(NSMutableSet <ESFilterItem *> *)selectItems;

/**
 获取筛选组头的title

 @param section 组索引
 @param filterList 筛选列表
 @return title
 */
+ (NSString *)getTagsHeader:(NSInteger)section
                    andList:(NSMutableArray <ESFilter *> *)filterList;

/**
 获取某个标签的名称

 @param section 组索引
 @param index item索引
 @param filterList 筛选列表
 @return 标签名称
 */
+ (NSString *)getTagTitle:(NSInteger)section
                withIndex:(NSInteger)index
                  andList:(NSMutableArray <ESFilter *> *)filterList;

/**
 标签是否已选择

 @param section 组索引
 @param index item索引
 @param filterList 筛选列表
 @param selectItems 已选择集合
 @return YES:已选择
 */
+ (BOOL)tagIsSelected:(NSInteger)section
            withIndex:(NSInteger)index
             withList:(NSMutableArray <ESFilter *> *)filterList
          andSelected:(NSMutableSet <ESFilterItem *> *)selectItems;

/**
 重置筛选项

 @param filterList 筛选列表
 @param selectItems 已选择集合
 */
+ (void)resetFilter:(NSMutableArray <ESFilter *> *)filterList
        andSelected:(NSMutableSet <ESFilterItem *> *)selectItems;

/**
 获取最终筛选项

 @param selectItems 已筛选集合
 @return 选择的数据
 */
+ (NSArray *)getFilterResult:(NSMutableSet <ESFilterItem *> *)selectItems;
@end
