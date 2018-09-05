
#import "MPDecorationBaseModel.h"

@implementation MPDecorationBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (![dictionary isKindOfClass:[NSNull class]]) {
            [self dictionaryChangeToModel:dictionary];
        }
    }
    return self;
}

- (void)dictionaryChangeToModel:(NSDictionary *)dict {
    if ([dict allKeys].count == 0) return;
    
    self.count = dict[@"count"];
    self.limit = dict[@"limit"];
    self.offset = dict[@"offset"];
    
    NSMutableArray * arrayNeeds = [NSMutableArray array];
    for (NSDictionary *dic in dict[@"needs_list"]) {
        MPDecorationNeedModel * model = [[MPDecorationNeedModel alloc] initWithDictionary:dic];
        [arrayNeeds addObject:model];
    }
    self.needs_list = (id)arrayNeeds;
}

+ (void)getDataWithParameters:(NSDictionary *)dictionary success:(void (^)(NSArray *, NSInteger ))success failure:(void (^)(NSError *))failure{

}

+ (NSArray *)checkNeeds:(NSArray *)array {
    NSMutableArray *arr1 = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    for (MPDecorationNeedModel *modelNeed in array) {

        NSString *wktemp_id = [modelNeed.wk_template_id description];
        if ([wktemp_id integerValue] == 1)
        {
            [arr1 addObject:modelNeed];
            [arr2 addObject:[NSNumber numberWithBool:YES]];
        }
    }

    return @[[arr1 copy],[arr2 copy]];
}

+ (void)createMarkHallWithUrlDict:(NSDictionary *)dictionary success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {


}

+ (void)issueDemandWithSelection:(BOOL)isSelection
                           param:(NSDictionary *)param
                         success:(void (^)(NSDictionary* dict))success
                         failure:(void(^) (NSError *error))failure{

}

+ (void)measureByConsumerSelfChooseDesignerNoNeedIdWithParam:(NSDictionary *)param
                                               requestHeader:(NSDictionary *)header
                                                     success:(void (^)(NSDictionary* dict))success
                                                     failure:(void(^) (NSURLSessionDataTask *task, NSError *error))failure {
    
}

+ (void)createModifyDecorateDemandWithNeedsId:(NSString *)needsId
                               withParameters:(NSDictionary *)parametersDict
                            withRequestHeader:(NSDictionary *)header
                                      success:(void(^) (NSDictionary *dict))success
                                      failure:(void(^) (NSError *error))failure {

}

+ (void)createDecorateDetailWithNeedsId:(NSString *)needsId
                                success:(void(^) (NSDictionary *dict))success
                                failure:(void(^) (NSError *error))failure {

}

+ (void)measureByConsumerSelfChooseDesignerParam:(NSDictionary *)param
                                         success:(void (^)(NSDictionary* dict))success
                                         failure:(void(^) (NSURLSessionDataTask *task,
                                                           NSError *error))failure
{

}

//+ (void)measureForSelectionWithParam:(NSDictionary *)param
//                             success:(void (^)(CoRequirement* assetInfo))success
//                             failure:(void(^) (NSError *error))failure
//{
//    NSDictionary *headerDict = [self getHeaderAuthorization];
//    
//    [MPDesignAPIManager measureForSelectionWithParam:param requestHeader:headerDict
//                                             success:^(NSDictionary *dictionary)
//     {
//         CoRequirement *assetInfo = [CoRequirement modelFromDict:dictionary];
//         if (success)
//             success(assetInfo);
//         
//     } failure:^(NSError *error) {
//         
//         if (failure)
//             failure(error);
//     }];
//}

+ (void)deleteDesignerWithNeedId:(NSString *)needId
                      designerId:(NSString *)designerId
                  withParameters:(NSDictionary *)parametersDict
               withRequestHeader:(NSDictionary *)header
                         success:(void(^) (NSDictionary *dictionary))success
                         failure:(void(^) (NSError *error))failure {
    
}

@end
