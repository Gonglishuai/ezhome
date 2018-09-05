
#import "JRBaseAPI.h"

@interface ESEnterpriseAPI : JRBaseAPI

+ (void)getDecorationsSuccess:(void (^) (NSArray *array))success
                      failure:(void (^) (NSError *error))failure;

+ (void)createEnterpriseWithBody:(NSDictionary *)body
                         success:(void (^) (NSDictionary *dict))success
                         failure:(void (^) (NSError *error))failure;

+ (void)getConstructListWithOffset:(NSInteger)offset
                             limlt:(NSInteger)limit
                           success:(void (^) (NSDictionary *dict))success
                           failure:(void (^) (NSError *error))failure;

+ (void)getConstructDetailWithPid:(NSString *)projectId
                          success:(void (^) (NSDictionary *dict))success
                          failure:(void (^) (NSError *error))failure;

+ (void)getTransactionListWithOffset:(NSInteger)offset
                               limlt:(NSInteger)limit
                            orderNum:(NSString *)orderNum
                             success:(void (^) (NSArray *array))success
                             failure:(void (^) (NSError *error))failure;

@end
