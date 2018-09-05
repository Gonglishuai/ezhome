
#import "ESProductDetailCouponsModel.h"

@implementation ESProductDetailCouponsModel

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([@"list" isEqualToString:key])
    {
        if (value
            && [value isKindOfClass:[NSArray class]])
        {
            self.list = value;
        }
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self updateModel];
    
    return self;
}

- (void)updateModel
{
    if (!self.list
        || ![self.list isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    CGSize nameSize = [ESProductDetailCouponsModel getTextSize:self.name spaceStatus:NO];
    CGFloat maxWidth = SCREEN_WIDTH - 16 * 2 - nameSize.width;
    CGFloat itemX = 0.0f;
    CGFloat itemY = 0.0f;
    CGFloat cellheight = 0.0f;
    CGFloat itemHeight = 22.0f;
    CGFloat space = 6.0f;
    cellheight += itemHeight;
        
    NSMutableArray *arrM = [NSMutableArray array];
    if (self.list
        && [self.list isKindOfClass:[NSArray class]])
    {
        for (NSString *message in self.list)
        {
            CGSize size = [ESProductDetailCouponsModel getTextSize:message
                                                       spaceStatus:YES];
            if (size.width <= 0)
            {
                continue;
            }
            
            if (size.width > maxWidth)
            {
                itemY = itemY + itemHeight + space;
                [arrM addObject:@{
                                  @"message" : message,
                                  @"x"       : @(itemX),
                                  @"y"       : @(itemY),
                                  @"width"   : @(maxWidth),
                                  @"height"  : @(itemHeight),
                                  }];
            }
            else if (itemX + size.width < maxWidth)
            {
                [arrM addObject:@{
                                  @"message" : message,
                                  @"x"       : @(itemX),
                                  @"y"       : @(itemY),
                                  @"width"   : @(size.width),
                                  @"height"  : @(itemHeight),
                                  }];
                itemX = itemX + size.width + space;
            }
            else
            {
                itemX = 0.0f;
                itemY = itemY + itemHeight + space;
                cellheight = cellheight + itemHeight + space;
                [arrM addObject:@{
                                  @"message" : message,
                                  @"x"       : @(itemX),
                                  @"y"       : @(itemY),
                                  @"width"   : @(size.width),
                                  @"height"  : @(itemHeight),
                                  }];
                itemX = itemX + size.width + space;
            }
        }
    }
    self.listArr = [arrM copy];
    self.height = cellheight + 15.0f * 2;
}

#pragma mark - ESProductDetailCouponLabelCell
+ (CGSize)getTextSize:(NSString *)text spaceStatus:(BOOL)spaceStatus
{
    if (!text
        || ![text isKindOfClass:[NSString class]]
        || text.length <= 0)
    {
        return CGSizeZero;
    }
    
    if (spaceStatus)
    {
        text = [NSString stringWithFormat:@"  %@  ", text];
    }
    // font需跟ESProductCouponItemView中使用的font一致
    UIFont *font = [UIFont stec_remarkTextFount];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 22)
                                     options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName : font}
                                     context:nil];
    return rect.size;
}

@end
