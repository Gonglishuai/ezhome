
#import "SHModel.h"
#import "MPDesignerInfoModel.h"

@interface MPDesignerBaseModel : SHModel            /// i am base, i request data.

@property (nonatomic, retain) NSNumber *count;
@property (nonatomic, retain) NSNumber *offset;
@property (nonatomic, retain) NSNumber *limit;
@property (nonatomic, retain) NSArray<MPDesignerInfoModel> *designer_list;

- (instancetype)initWithDictionary:(NSDictionary *)dict;


+ (void)getDataWithParameters:(NSDictionary *)dictionary success:(void(^) (NSArray *array))success failure:(void(^) (NSError *error))failure;


+ (void)getDesignerInfoWithParam:(NSDictionary *)param
                         success:(void (^)(MPDesignerInfoModel* model))success
                         failure:(void(^) (NSError *error))failure;

+ (void)getDesignerFilterTagsWithSuccess:(void(^)(NSArray *arr))success
                              andFailure:(void(^)(NSError *error))failure;
@end
