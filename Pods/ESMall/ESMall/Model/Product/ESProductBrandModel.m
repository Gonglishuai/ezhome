
#import "ESProductBrandModel.h"

@implementation ESProductBrandModel

#pragma mark - Super Methods
- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([@"relatedCategory" isEqualToString:key])
    {
        if (value
            && [value isKindOfClass:[NSArray class]])
        {
            NSMutableArray *arrM = [NSMutableArray array];
            for (id obj in value)
            {
                NSString *strValue = [self descriptionValue:obj];
                [arrM addObject:strValue];
            }
            self.relatedCategory = [arrM copy];
        }
    }
    
    else if ([@"deliverTime" isEqualToString:key])
    {
        if (value
            && [value isKindOfClass:[NSArray class]])
        {
            NSMutableArray *arrM = [NSMutableArray array];
            for (id obj in value)
            {
                NSString *strValue = [self descriptionValue:obj];
                [arrM addObject:strValue];
            }
            self.deliverTime = [arrM copy];
        }
    }
    
    else if ([@"deposit" isEqualToString:key])
    {
        if (value
            && [value isKindOfClass:[NSArray class]])
        {
            NSMutableArray *arrM = [NSMutableArray array];
            for (id obj in value)
            {
                NSString *strValue = [self descriptionValue:obj];
                CGFloat priceNum = [strValue doubleValue];
                if (priceNum > 10000000.0)
                {
                    strValue = [NSString stringWithFormat:@"%.2f万", priceNum/10000.0];
                }
                else
                {
                    strValue = [NSString stringWithFormat:@"%.2f", priceNum];
                }
                [arrM addObject:strValue];
            }
            self.deposit = [arrM copy];
        }
    }
    
    else
    {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [super setValue:value forUndefinedKey:key];
    if ([@"description" isEqualToString:key])
    {
        self.desc = value;
    }
}

@end
