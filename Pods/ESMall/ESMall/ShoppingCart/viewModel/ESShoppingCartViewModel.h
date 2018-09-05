//
//  ESShoppingCartViewModel.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/30.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESCartInfo.h"

typedef NS_ENUM(NSUInteger, ESCommodityType) {//商品类型
    ESCommodityTypeNone,
    ESCommodityTypeValid,      //有效商品
    ESCommodityTypeNonsupport, //不支持购买类型
    ESCommodityTypeInvalid,    //无效商品
};

@class ESProductModel;

@interface ESShoppingCartViewModel : NSObject

@property (nonatomic, assign) ESCommodityType type;
@property (nonatomic, strong) NSMutableArray *data;


/**
 获取购物车信息

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)retrieveCartInfoWithSuccess:(void(^)(NSArray *dataList, ESCartInfo *info))success
                         andFailure:(void(^)(void))failure;

/// 获取spu标签和sku信息
+ (void)requestForAttributesSpuId:(NSString *)spuId
                          success:(void(^)(ESProductModel *model))success
                          failure:(void(^)(void))failure;

/// 获取sku属性信息
+ (NSDictionary *)getSkuAttributesFromArray:(NSArray *)array
                                withSection:(NSInteger)section
                                   andIndex:(NSInteger)index;

/// 更新item状态, 选中或取消
+ (void)requestForItemSelectedStatus:(BOOL)status
                         cartItemIds:(NSString *)cartItemIds
                             success:(void(^)(ESCartInfo *cartInfo))success
                             failure:(void(^)(NSString *errorMsg))failure;

/**
 获取组数

 @param array 数据源
 @param editAll 是否是编辑全部状态
 @return 组数
 */
+ (NSInteger)getSectionNumsFromArray:(NSArray *)array
                         withEditAll:(BOOL)editAll;

/**
 获取组内条数

 @param array 数据源
 @param section 组索引
 @return 组内条数
 */
+ (NSInteger)getItemNumsFromArray:(NSArray *)array
                      withSection:(NSInteger)section;

/**
 组的类型

 @param section 组索引
 @return 类型
 */
+ (ESCommodityType)getSectionTypeFromArray:(NSArray *)array withSection:(NSInteger)section;

/**
 判断商品是否为选中状态

 @param array 数据源
 @param section 组索引
 @param index item索引
 @return YES:为选中状态
 */
+ (BOOL)isSelectedFromArray:(NSArray *)array
                withSection:(NSInteger)section
                   andIndex:(NSInteger)index;

/**
 品牌是否为选择状态

 @param array 数据源
 @param section 组索引
 @return YES:品牌为选择状态
 */
+ (BOOL)isSelectBrandFromArray:(NSArray *)array
                   withSection:(NSInteger)section;

/// 生效品牌选择状态
+ (void)effectiveSelectBrandFromArray:(NSArray *)array
                          withSection:(NSInteger)section;

/**
 品牌是否处于编辑状态
 
 @param array 数据源
 @param section 组索引
 @return YES:品牌为编辑状态
 */
+ (BOOL)brandIsEditingFromArray:(NSArray *)array
                       editDict:(NSMutableDictionary *)dict
                    withSection:(NSInteger)section;

/**
 获取品牌名

 @param array 数据源
 @param section 组索引
 @return 品牌名
 */
+ (NSString *)getBrandNameFromArray:(NSArray *)array
                        withSection:(NSInteger)section;

/**
 选择一个品牌

 @param array 数据源
 @param section 组索引
 */
+ (NSDictionary *)selectBrandFromArray:(NSArray *)array withSection:(NSInteger)section;


/**
 编辑品牌

 @param array 数据源
 @param section 组索引
*/
+ (void)updateBrandSelectedStatusFromArray:(NSArray *)array
                                  editDict:(NSMutableDictionary *)editStatusDict
                               withSection:(NSInteger)section;

/**
 获取商品缩略图

 @param array 数据源
 @param section 组索引
 @param index item索引
 @return 缩略图url
 */
+ (NSString *)getItemImageFromArray:(NSArray *)array
                        withSection:(NSInteger)section
                           andIndex:(NSInteger)index;

/**
 获取商品名称

 @param array 数据源
 @param section 组索引
 @param index itemsuoyin
 @return 商品名
 */
+ (NSString *)getItemNameFromArray:(NSArray *)array
                       withSection:(NSInteger)section
                          andIndex:(NSInteger)index;

/**
 获取商品SKU

 @param array 数据源
 @param section 组索引
 @param index item索引
 @return 商品sku
 */
+ (NSString *)getItemSKUFromArray:(NSArray *)array
                      withSection:(NSInteger)section
                         andIndex:(NSInteger)index;

/**
 获取商品价格

 @param array 数据源
 @param section 组索引
 @param index item索引
 @return 单价
 */
+ (double)getItemPriceFromArray:(NSArray *)array
                    withSection:(NSInteger)section
                       andIndex:(NSInteger)index;

/**
 获取商品数量

 @param array 数据源
 @param section 组索引
 @param index item索引
 @return 数量
 */
+ (NSInteger)getItemAmountFromArray:(NSArray *)array
                        withSection:(NSInteger)section
                           andIndex:(NSInteger)index;

/**
 选中一件商品

 @param array 数据源
 @param section 组索引
 @param index item索引
 */
+ (NSDictionary *)selectItemFromArray:(NSArray *)array
                          withSection:(NSInteger)section
                             andIndex:(NSInteger)index;
/// 生效选中一件商品
+ (void)effectiveSelectItemFromArray:(NSArray *)array
                         withSection:(NSInteger)section
                            andIndex:(NSInteger)index;

/**
 删除一件商品

 @param array 数据源
 @param section 组索引
 @param index item索引
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteItemFromArray:(NSMutableArray *)array
                   editDict:(NSMutableDictionary *)dict
                withSection:(NSInteger)section
                  withIndex:(NSInteger)index
                withSuccess:(void(^)(BOOL refreshStatus, BOOL delSection))success
                 andFailure:(void(^)(void))failure;

/**
 清除 不支持或失效商品

 @param array 数据源
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)clearInvalidItemsFromArray:(NSMutableArray *)array
                       withSection:(NSInteger)section
                       withSuccess:(void(^)(void))success
                        andFailure:(void(^)(void))failure;

/**
 获取一个商品模型

 @param array 数据源
 @param section 组索引
 @param index item索引
 @return 商品ID
 */
+ (ESCartCommodity *)getCommodityFromArray:(NSArray *)array
                               withSection:(NSInteger)section
                                  andIndex:(NSInteger)index;

/**
 获取合计金额

 @param array 数据源
 @return 合计金额
 */
+ (NSString *)getTotalPriceFromArray:(NSArray *)array;

/**
 获取已选择的商品总数

 @param array 数据源
 @return 已选择商品数
 */
+ (NSInteger)getSelectedTotoalNumsFromArray:(NSArray *)array
                                   withType:(ESCommodityType)type;

/**
 删除选择的商品

 @param array 数据源
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteSelectedItemsFromArray:(NSMutableArray *)array
                            editDict:(NSMutableDictionary *)editDictM
                         withSuccess:(void(^)(void))success
                          andFailure:(void(^)(void))failure;

/**
 所有商品是否全选了

 @param array 数据源
 @return YES:全选了
 */
+ (BOOL)isSelectedAllItemsFromArray:(NSArray *)array;

/**
 标记所有商品是否全选

 @param select YES:全选
 */
+ (NSDictionary *)markAllItemsSelected:(BOOL)select
                             withArray:(NSArray *)array;

/// 生效选中状态
+ (void)effectiveMarkAllItemsSelected:(BOOL)select
                            withArray:(NSArray *)array;
/**
 标记所有商品是否为编辑状态

 @param editing YES:编辑状态
 */
+ (void)markAllItemsEditingStatus:(BOOL)editing
                         withDict:(NSMutableDictionary *)dict;

/**
 是否有编辑状态的商品

 @param array 数据源
 @return YES:有
 */
+ (BOOL)hasEditingBrandFromDict:(NSMutableDictionary *)dict;

/**
 生成结算订单

 @param array 数据源
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)createPendingOrderSuccess:(void(^)(NSDictionary *dict))success
                         andFailure:(void(^)(NSString *errMsg))failure;

/**
 修改sku的属性
 
 @param array 数据源
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)updateSkuAttributesFromArray:(NSArray *)array
                         withSection:(NSInteger)section
                            andIndex:(NSInteger)index
                            newSkuId:(NSString *)skuId
                        itemQuantity:(NSInteger)itemQuantity
                         withSuccess:(void(^)(void))success
                          andFailure:(void(^)(NSString *errorMsg))failure;

/**
 是否有定位信息

 @param success 有定位信息回调
 @param noPermission 没有权限回调
 @param failure 没有定位信息（定位失败）
 */
+ (void)checkLocalRegionInfoWithSuccess:(void(^)(void))success
                      withNoPermission:(void(^)(void))noPermission
                           withFailure:(void(^)(void))failure;

/**
 获取定位信息

 @param success 成功回调
 */
+ (void)getLocalInfoWithSuccess:(void(^)(BOOL success))success;

/**
 获取减操作按钮是否可用

 @param array 数据源
 @param section 组索引
 @param index item索引
 @return YES:可用
 */
+ (NSInteger)getMinAmountFromArray:(NSMutableArray *)array
                       withSection:(NSInteger)section
                          andIndex:(NSInteger)index;

/**
 获取加操作按钮是否可用
 
 @param array 数据源
 @param section 组索引
 @param index item索引
 @return YES:可用
 */
+ (NSInteger)getMaxAmountFromArray:(NSMutableArray *)array
                       withSection:(NSInteger)section
                          andIndex:(NSInteger)index;

/// 获取促销信息
+ (ESCartCommodityPromotion *)getItemPromotionFromArray:(NSArray *)array
                                            withSection:(NSInteger)section
                                               andIndex:(NSInteger)index;

/// 获取赠品id
+ (NSString *)getGiftIdFromArray:(NSArray *)array
                     withSection:(NSInteger)section
                        andIndex:(NSInteger)index;

@end
