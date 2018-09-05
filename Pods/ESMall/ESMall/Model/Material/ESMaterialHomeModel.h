
#import <Foundation/Foundation.h>

@interface ESMaterialHomeModel : NSObject

/// 更新商城首页数据源
+ (NSDictionary *)updateHomeDic:(NSDictionary *)dict;

/// 更新商品列表数据源
+ (NSDictionary *)updateListDic:(NSDictionary *)dict;

/// 获取商城首页item高度;
+ (CGFloat)geiHeightWithIndex:(NSInteger)index arr:(NSArray *)arr;

/// 获取商城首页item高度;
+ (CGFloat)geiListHeightWithIndex:(NSInteger)index arr:(NSArray *)arr;

@end
