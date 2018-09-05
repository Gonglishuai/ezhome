
#import "ESMaterialHomeModel.h"

@implementation ESMaterialHomeModel

+ (CGFloat)geiHeightWithIndex:(NSInteger)index arr:(NSArray *)arr
{
    if (!arr
        || ![arr isKindOfClass:[NSArray class]])
    {
        arr = @[];
    }
    
    CGFloat height = 0.0f;
    NSInteger status = index/2;
    for (NSInteger i = 0; i < arr.count; i++)
    {
        if (i/2 == status)
        {
            NSDictionary *dic = arr[i];
            if ([dic isKindOfClass:[NSDictionary class]])
            {
                CGFloat itemHeight = [dic[@"height"] floatValue];
                if (height < itemHeight)
                {
                    height = itemHeight;
                }
            }
        }
    }
    
    return height;
}

+ (CGFloat)geiListHeightWithIndex:(NSInteger)index arr:(NSArray *)arr
{
    if (!arr
        || ![arr isKindOfClass:[NSArray class]])
    {
        arr = @[];
    }
    
    NSInteger itemIndex = 0;
    if (index >= 2)
    {
        itemIndex = index - 2;
    }
    CGFloat height = 0.0f;
    NSInteger status = index/2;
    for (NSInteger i = itemIndex; i < arr.count; i++)
    {
        if ((status + 1) * 2 <= i)
        {
            break;
        }
        
        if (i/2 == status)
        {
            NSDictionary *dic = arr[i];
            if ([dic isKindOfClass:[NSDictionary class]])
            {
                CGFloat itemHeight = [dic[@"height"] floatValue];
                if (height < itemHeight)
                {
                    height = itemHeight;
                }
            }
        }
    }

    return height;
}

+ (NSDictionary *)updateHomeDic:(NSDictionary *)dict
{
    if (!dict
        || ![dict isKindOfClass:[NSDictionary class]])
    {
        dict = @{};
    }
    NSMutableDictionary *dictM = [[NSMutableDictionary alloc] initWithDictionary:dict];
    if (dictM[@"extend_dic"]
        && [dictM[@"extend_dic"] isKindOfClass:[NSDictionary class]]
        && dictM[@"extend_dic"])
    {
        CGFloat height = 0.0f;
        CGFloat width = 0.0;
        CGFloat widSpace = 6.0f;
        CGFloat heiSpace = 6.0f;
        // 商城首页给item的最大宽度
        CGFloat maxWidth = (SCREEN_WIDTH-41)/2;
        CGFloat strMaxHeight = 16.0f;
        
        NSDictionary *info = dictM[@"extend_dic"];
        NSMutableArray *arrTags = [NSMutableArray array];
        if ([info[@"proTag"] isKindOfClass:[NSArray class]])
        {
            NSArray *tags = info[@"proTag"];
            for (NSInteger i = 0; i < tags.count; i++)
            {
                NSString *str = tags[i];
                if (str
                    && [str isKindOfClass:[NSString class]]
                    && str.length > 0)
                {
                    if (height <= 0) height = strMaxHeight;
                    
                    str = [NSString stringWithFormat:@"%@ ",str];
                    CGFloat strWidth = [self getWidthWithStr:str maxWidth:maxWidth maxHeight:strMaxHeight];
                    [arrTags addObject:@{
                                         @"tag": str,
                                         @"width": @(strWidth)
                                         }];
                    if (width + strWidth >= maxWidth)
                    {
                        height = height + heiSpace + strMaxHeight;
                        width = 0.0f;
                    }
                    else
                    {
                        width = width + widSpace + strWidth;
                    }
                }
            }
        }
        if ([info[@"discountTag"] isKindOfClass:[NSString class]])
        {
            NSString *discountTag = info[@"discountTag"];
            if (discountTag.length > 0)
            {
                if (height <= 0) height = strMaxHeight;

                NSString *str = [NSString stringWithFormat:@"%@ ",discountTag];
                CGFloat strWidth = [self getWidthWithStr:str maxWidth:maxWidth maxHeight:strMaxHeight];
                [arrTags addObject:@{
                                     @"tag": str,
                                     @"width": @(strWidth)
                                     }];
                
                if (width + strWidth >= maxWidth)
                {
                    height = height + heiSpace + strMaxHeight;
                    width = 0.0f;
                }
                else
                {
                    width = width + widSpace + strWidth;
                }
            }
        }

        NSMutableDictionary *extend_dicM = [[NSMutableDictionary alloc] initWithDictionary:dictM[@"extend_dic"]];
        [extend_dicM setObject:[arrTags copy] forKey:@"tags"];
        [dictM setObject:[extend_dicM copy] forKey:@"extend_dic"];
        [dictM setObject:[@(height) stringValue] forKey:@"height"];
    }
    
    return [dictM copy];
}

+ (NSDictionary *)updateListDic:(NSDictionary *)dict
{
    if (!dict
        || ![dict isKindOfClass:[NSDictionary class]])
    {
        dict = @{};
    }
    NSMutableDictionary *dictM = [[NSMutableDictionary alloc] initWithDictionary:dict];

    CGFloat height = 0.0f;
    CGFloat width = 0.0;
    CGFloat widSpace = 6.0f;
    CGFloat heiSpace = 6.0f;
    // 商城给item的最大宽度
    CGFloat maxWidth = (SCREEN_WIDTH-41)/2;
    CGFloat strMaxHeight = 16.0f;
    
    NSMutableArray *arrTags = [NSMutableArray array];
    if ([dictM[@"tags"] isKindOfClass:[NSArray class]])
    {
        NSArray *tags = dictM[@"tags"];
        for (NSInteger i = 0; i < tags.count; i++)
        {
            NSString *str = tags[i];
            if (str
                && [str isKindOfClass:[NSString class]]
                && str.length > 0)
            {
                str = [NSString stringWithFormat:@"%@ ",str];
                CGFloat strWidth = [self getWidthWithStr:str maxWidth:maxWidth maxHeight:strMaxHeight];
                [arrTags addObject:@{
                                     @"tag": str,
                                     @"width": @(strWidth)
                                     }];
                if (width + strWidth >= maxWidth)
                {
                    height = height + heiSpace + strMaxHeight;
                    width = 0.0f;
                }
                else
                {
                    width = width + widSpace + strWidth;
                }
            }
        }
        if (tags.count > 0)
        {
            height = height + strMaxHeight + heiSpace;
        }
    }
    if ([dictM[@"discount"] isKindOfClass:[NSArray class]])
    {
        NSArray *discountTags = dictM[@"discount"];
        for (NSInteger i = 0; i < discountTags.count; i++)
        {
            NSString *str = discountTags[i];
            if (str
                && [str isKindOfClass:[NSString class]]
                && str.length > 0)
            {
                str = [NSString stringWithFormat:@"%@ ",str];
                CGFloat strWidth = [self getWidthWithStr:str maxWidth:maxWidth maxHeight:strMaxHeight];
                [arrTags addObject:@{
                                     @"tag": str,
                                     @"width": @(strWidth)
                                     }];
                if (width + strWidth >= maxWidth)
                {
                    height = height + heiSpace + strMaxHeight;
                    width = 0.0f;
                }
                else
                {
                    width = width + widSpace + strWidth;
                }
            }
        }
        if (discountTags.count > 0)
        {
            height = height + strMaxHeight + heiSpace;
        }
    }
    
    [dictM setObject:[arrTags copy] forKey:@"tags"];
    [dictM setObject:[@(height) stringValue] forKey:@"height"];
    
    return [dictM copy];
}

+ (CGFloat)getWidthWithStr:(NSString *)str maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    // font需跟GoodsItemCell中taglabel使用的font一致
    UIFont *valueFont = [UIFont stec_remarkTextFount];
    if (str
        && [str isKindOfClass:[NSString class]])
    {
        CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, 15)
                                               options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : valueFont}
                                               context:nil];
        CGFloat width = rect.size.width;
        if (width > maxWidth)
        {
            width = maxWidth;
        }
        return width;
    }
    
    return 0;
}

@end
