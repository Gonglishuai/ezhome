
#import "ESEnterpriseDecorationModel.h"

@implementation ESEnterpriseDecorationModel

+ (NSString *)getCodeWithKey:(NSString *)key
                  dataSource:(NSArray *)arrayDS
{
    if (!key
        || ![key isKindOfClass:[NSString class]]
        || !arrayDS
        || ![arrayDS isKindOfClass:[NSArray class]])
    {
        return @"";
    }
    
    for (ESEnterpriseDecorationModel *model in arrayDS)
    {
        if ([model isKindOfClass:[ESEnterpriseDecorationModel class]]
            && [model.showName isKindOfClass:[NSString class]])
        {
            if ([key isEqualToString:model.showName]
                && [model.code isKindOfClass:[NSString class]])
            {
                return model.code;
            }
        }
    }
    
    return @"";
}

@end
