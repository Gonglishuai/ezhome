
#import "ESProductImagesModel.h"

@implementation ESProductImagesModel

#pragma mark - Super Methods
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [super setValue:value forUndefinedKey:key];
    
    if ([@"description" isEqualToString:key])
    {
        self.desc = value;
    }
}

@end
