
#import "ESProductAttributeSelectedValueModel.h"

@implementation ESProductAttributeSelectedValueModel

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self initData];
    
    return self;
}

- (void)initData
{
    self.nameSize = CGSizeZero;
    self.valueSize = CGSizeZero;
    
    // font需跟ESProductDetailParametersCell中使用的font一致
    UIFont *valueFont = [UIFont stec_paramsFount];
    
    if (self.value
        && [self.value isKindOfClass:[NSString class]]
        && self.name
        && [self.name isKindOfClass:[NSString class]])
    {
        CGRect valueRect = [self.value boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 106 - 20, MAXFLOAT)
                                                    options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName : valueFont}
                                                    context:nil];
        self.valueSize = valueRect.size;
        
        CGRect nameRect = [self.name boundingRectWithSize:CGSizeMake(80, MAXFLOAT)
                                                  options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName : valueFont}
                                                  context:nil];
        self.nameSize = nameRect.size;
    }
}

@end
