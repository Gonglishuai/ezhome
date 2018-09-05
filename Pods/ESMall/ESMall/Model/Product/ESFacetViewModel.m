
#import "ESFacetViewModel.h"

@implementation ESFacetViewModel

#pragma mark - Super Methods
- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([@"values" isEqualToString:key])
    {
        if (value
            && [value isKindOfClass:[NSArray class]])
        {
            self.entry = (id)[self createModelsWithArray:value
                                               modelName:NSStringFromClass([ESFacetViewEntryModel class])];
        }
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

@end
