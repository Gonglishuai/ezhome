
#import "ESAppConstantInfo.h"
#import "ESModel.h"

@implementation ESAppConstantInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
    @try {
        return [ESAppConstantInfo es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        
        return self;
    }
}

@end
