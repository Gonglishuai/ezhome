
#import "ESBaseModel.h"

typedef NS_ENUM(NSInteger,ESCartLabelStatus)
{
    ESCartLabelStatusUnKnow = 0,
    ESCartLabelStatusEnableDisSelected,
    ESCartLabelStatusEnableSelected,
    ESCartLabelStatusDisEnable,
};

/**
 identifier (string, optional): 属性值标识 ,
 value (string, optional): 属性值 ,
 sequence (number, optional): 属性值次序
 */

@interface ESProductAttributeValueModel : ESBaseModel

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *sequence;

@property (nonatomic, assign) BOOL customizable;

// 我的新增
@property (nonatomic, assign) ESCartLabelStatus valueStatus;
@property (nonatomic, assign) BOOL couldEdit;
@property (nonatomic, assign) CGSize size;

+ (ESProductAttributeValueModel *)copyValueModel:(ESProductAttributeValueModel *)valueModel;

@end
