
#import "ESProductPriceModel.h"

@implementation ESProductPriceModel

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self updatePrice];
    
    return self;
}

- (void)updatePrice
{
    CGFloat priceNum = [self.value doubleValue];
    if (priceNum <= 0)
    {
        self.showValue = @"";
        return;
    }
    
    NSString *strPrice = nil;
    if (priceNum > 10000000.0)
    {
        strPrice = [NSString stringWithFormat:@"%.2f万", priceNum/10000.0];
    }
    else
    {
        strPrice = [NSString stringWithFormat:@"%.2f", priceNum];
    }
    self.showValue = strPrice;
}

@end
