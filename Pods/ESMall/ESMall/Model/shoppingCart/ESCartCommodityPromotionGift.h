
#import "ESBaseModel.h"

/**
 @ApiModelProperty("标签key")
 private String tagKey;
 @ApiModelProperty("商品id")
 private String catentryId;
 @ApiModelProperty("赠品名称")
 private String objName;
 @ApiModelProperty("赠送数量")
 private String objQuantity;
 */

@interface ESCartCommodityPromotionGift : ESBaseModel

@property (nonatomic, copy) NSString *tagKey;
@property (nonatomic, copy) NSString *catentryId;
@property (nonatomic, copy) NSString *objName;
@property (nonatomic, copy) NSString *objQuantity;
@property (nonatomic, copy) NSString *objType;

@property (nonatomic, assign) BOOL productStatus;

@end
