
#import <Foundation/Foundation.h>
#import "ESEnterpriseDecorationModel.h"

@interface ESCreateEnterpriseModel : NSObject

+ (NSArray *)getCreateEnterpriseItemsWithMemberInfo:(NSDictionary *)memberInfo;

+ (NSString *)checkDataCompleted:(NSArray *)array;

+ (NSMutableDictionary *)getCheckValueWithKey:(NSString *)key data:(NSArray *)data;

+ (void)getDecorationsSuccess:(void (^) (NSArray <ESEnterpriseDecorationModel *> *array))success
                      failure:(void (^) (NSError *error))failure;

+ (void)createEnterpriseWithData:(NSArray *)data
                      memberInfo:(NSDictionary *)memberInfo
                         success:(void (^) (NSDictionary *dict))success
                         failure:(void (^) (NSError *error))failure;

@end
