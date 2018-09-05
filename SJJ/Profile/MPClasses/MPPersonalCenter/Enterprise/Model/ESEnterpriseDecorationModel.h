
#import "ESBaseModel.h"

@interface ESEnterpriseDecorationModel : ESBaseModel

@property (nonatomic, copy) NSString *showName;
@property (nonatomic, copy) NSString *code;

+ (NSString *)getCodeWithKey:(NSString *)key
                  dataSource:(NSArray *)arrayDS;

@end
