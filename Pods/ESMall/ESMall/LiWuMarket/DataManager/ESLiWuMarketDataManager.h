//
//  ESLiWuMarketDataManager.h
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESLiWuHomeModel.h"

@interface ESLiWuMarketDataManager : NSObject

/**
 获取丽屋超市首页数据

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getLiWuHomeDataWithSuccess:(void(^)(ESLiWuHomeModel *model))success
                        andFailure:(void(^)(void))failure;

/**
 获取类目条数

 @param homeModel 页面模型
 @return 条目数量
 */
+ (NSInteger)getCategoryNumsWithModel:(ESLiWuHomeModel *)homeModel;

/**
 获取热卖商品数量

 @param homeModel 页面模型
 @return 商品数量
 */
+ (NSInteger)getProductNumsWithModel:(ESLiWuHomeModel *)homeModel;

/**
 获取某项类目模型

 @param homeModel 页面模型
 @param index 索引
 @return 类目
 */
+ (ESLiWuCategoryModel *)getCategoryWithModel:(ESLiWuHomeModel *)homeModel andIndex:(NSInteger)index;

/**
 获取某项热卖商品模型

 @param homeModel 页面模型
 @param index 索引
 @return 商品
 */
+ (ESCMSModel *)getProductWithModel:(ESLiWuHomeModel *)homeModel andIndex:(NSInteger)index;

/**
 获取所有轮播图

 @param homeModel 页面模型
 @return 轮播图片组
 */
+ (NSArray <NSString *>*)getLoopImageUrlsWithModel:(ESLiWuHomeModel *)homeModel;

/**
 获取某个banner模型

 @param homeModel 页面模型
 @param index 索引
 @return banner
 */
+ (ESCMSModel *)getBannerWithModel:(ESLiWuHomeModel *)homeModel andIndex:(NSInteger)index;
@end
