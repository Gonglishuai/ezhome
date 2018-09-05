
#import "ESProductAttributeValueModel.h"
#import <ESBasic/ESDevice.h>

@implementation ESProductAttributeValueModel

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self initData];
    
    return self;
}

- (void)initData
{
    self.valueStatus = ESCartLabelStatusEnableDisSelected;
    self.size = CGSizeZero;
    
    // font需跟ESProductCartLabelCell中使用的font一致
    UIFont *valueFont = [UIFont stec_subTitleFount];
    
    if (self.value
        && [self.value isKindOfClass:[NSString class]])
    {
        CGRect rect = [self.value boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 16 * 2, MAXFLOAT)
                                               options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : valueFont}
                                               context:nil];
        CGFloat width = rect.size.width + 16 * 2;
        width = width > 74.0 ? width : 74.0f;
        CGFloat height = rect.size.height + 4 * 2;
        self.size = CGSizeMake(width, height);
    }
}

#pragma mark - Public Methods
+ (ESProductAttributeValueModel *)copyValueModel:(ESProductAttributeValueModel *)valueModel
{
    if (!valueModel
        || ![valueModel isKindOfClass:[ESProductAttributeValueModel class]])
    {
        return nil;
    }

    ESProductAttributeValueModel *model = [[ESProductAttributeValueModel alloc] init];
    model.identifier = valueModel.identifier;
    model.value = valueModel.value;
    model.sequence = valueModel.sequence;
    model.customizable = valueModel.customizable;
    model.valueStatus = valueModel.valueStatus;
    model.couldEdit = valueModel.couldEdit;
    model.size = valueModel.size;
    
    return model;
}

@end
