
#import "SHModel.h"
#import "MPDecorationNeedModel.h"

@interface MPDecorationBaseModel : SHModel

@property (nonatomic, retain) NSNumber *count;

@property (nonatomic, retain) NSNumber *offset;

@property (nonatomic, retain) NSNumber *limit;

@property (nonatomic, retain) NSArray<MPDecorationNeedModel> *needs_list;

/// Using the dictionary to initialize the model
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/// mark hall.
+ (void)createMarkHallWithUrlDict:(NSDictionary *)dictionary
                          success:(void (^)(NSArray *array))success
                          failure:(void (^)(NSError *error))failure;

+ (void)issueDemandWithSelection:(BOOL)isSelection
                           param:(NSDictionary *)param
                         success:(void (^)(NSDictionary* dict))success
                         failure:(void(^) (NSError *error))failure;

/// 自选量房
+ (void)measureByConsumerSelfChooseDesignerNoNeedIdWithParam:(NSDictionary *)param
                                               requestHeader:(NSDictionary *)header success:(void (^)(NSDictionary* dict))success
                                                     failure:(void(^) (NSURLSessionDataTask *task, NSError *error))failure;

+ (void)createModifyDecorateDemandWithNeedsId:(NSString *)needsId
                               withParameters:(NSDictionary *)parametersDict
                            withRequestHeader:(NSDictionary *)header
                                      success:(void(^) (NSDictionary *dict))success
                                      failure:(void(^) (NSError *error))failure;

+ (void)createDecorateDetailWithNeedsId:(NSString *)needsId
                                success:(void(^) (NSDictionary *dict))success
                                failure:(void(^) (NSError *error))failure;

/// 竞优量房
+ (void)measureByConsumerSelfChooseDesignerParam:(NSDictionary *)param
                                         success:(void (^)(NSDictionary* dict))success
                                         failure:(void(^) (NSURLSessionDataTask *task,
                                                           NSError *error))failure;

///// 精选量房
//+ (void)measureForSelectionWithParam:(NSDictionary *)param
//                             success:(void (^)(CoRequirement* assetInfo))success
//                             failure:(void(^) (NSError *error))failure;

+ (void)deleteDesignerWithNeedId:(NSString *)needId
                      designerId:(NSString *)designerId
                  withParameters:(NSDictionary *)parametersDict
               withRequestHeader:(NSDictionary *)header
                         success:(void(^) (NSDictionary *dictionary))success
                         failure:(void(^) (NSError *error))failure;

+ (void)getDataWithParameters:(NSDictionary *)dictionary
                      success:(void (^)(NSArray *, NSInteger ))success
                      failure:(void (^)(NSError *))failure;

@end
