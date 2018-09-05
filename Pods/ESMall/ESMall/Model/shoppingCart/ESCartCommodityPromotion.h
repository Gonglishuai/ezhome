
#import "ESBaseModel.h"
#import "ESCartCommodityPromotionGift.h"

/**
 tagId = 248996605919764480,
 tagKey = 272571836028903424,
 tagType = 101,
 tagDesc = ,
 tagName = 满减促销121801,
 tagUrl = https://shejijia-alpha.oss-cn-beijing.aliyuncs.com/sjj‘’
 */

@interface ESCartCommodityPromotion : ESBaseModel

@property (nonatomic, copy) NSString *tagId;
@property (nonatomic, copy) NSString *tagKey;
@property (nonatomic, copy) NSString *tagType;
@property (nonatomic, copy) NSString *tagDesc;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, copy) NSString *tagUrl;
@property (nonatomic, copy) NSArray <ESCartCommodityPromotionGift *> *rewardInfos;

// 我的新增
/// 赠品数量
@property (nonatomic, assign) NSInteger giftsCount;

@end
