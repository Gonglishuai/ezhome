
#import "MPCaseBaseModel.h"
#import "ESDesignCaseAPI.h"

@implementation MPCaseBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        if ([dict objectForKey:@"design_file"]) {
            [self create3DModelWithDict:dict];
        }else{
            
        [self createModelWithDict:dict];
            
        }
    }
    return self;
}

- (void)createModelWithDict:(NSDictionary *)dict {
    if ([dict allKeys].count == 0) return;
    
    self.limit = dict[@"limit"];
    self.offset = dict[@"offset"];
    self.count = dict[@"count"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in dict[@"cases"]) {
        
        if (dic && (!dic[@"hs_designer_uid"] ||
                    [dic[@"hs_designer_uid"] isKindOfClass:[NSNull class]]))
            continue;
        MPCaseModel *model = [[MPCaseModel alloc] initWithDictionary:dic];
        [array addObject:model];
    }
    self.cases = (id)array;
}
- (void)create3DModelWithDict:(NSDictionary *)dict {
    if ([dict allKeys].count == 0) return;
    
    self.limit = dict[@"limit"];
    self.offset = dict[@"offset"];
    self.count = dict[@"count"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in dict[@"cases"]) {
        
        if (dic && (!dic[@"hs_designer_uid"] ||
                    [dic[@"hs_designer_uid"] isKindOfClass:[NSNull class]]))
            continue;
        
        MP3DCaseModel *model = [[MP3DCaseModel alloc] initWithDict:dic];
        [array addObject:model];
    }
    self.cases3D = (id)array;
}

+ (void)getDataWithParameters:(NSDictionary *)dictionary success:(void (^)(NSArray<ESDesignCaseList *> *, NSString *))success failure:(void (^)(NSError *))failure {

    [ESDesignCaseAPI getListOfDesignerCasesWithUrl:dictionary header:nil body:nil success:^(NSDictionary * _Nullable dictionary) {
        NSMutableArray *cases = [NSMutableArray array];
        NSString *count = [NSString stringWithFormat:@"%@", dictionary[@"count"]];
        if (dictionary && dictionary[@"cases"] && ![dictionary isKindOfClass:[NSNull class]] &&
            ![dictionary[@"cases"] isKindOfClass:[NSNull class]]) {
            for (NSDictionary *dic in dictionary[@"cases"]) {
                ESDesignCaseList *caseList = [ESDesignCaseList objFromDict:dic];
                if (caseList) {
                    [cases addObject:caseList];
                }
            }
        }
        if (success) {
            success(cases,count);
        }
    } failure:^(NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getCaseDetailInfoWithCaseId:(NSString *)caseid success:(void (^)(MPCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure {

}
//点赞状态
+ (void)getCaseDetailInfoThumbStatusWithCaseId:(NSString *)caseid success:(void (^)(MPCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure {
    
    
}

//asset_id -long 和X-Token -string 点赞请求

+(void)getCaseDetailInfoWithAsset_Id:(NSString*)asset_Id success:(void (^)(MPCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure{
    
    SHLog(@"调用网络请求2");

}

+ (void)get2DCasesListWithOffset:(NSString *)offset
                       withLimit:(NSString *)limit
                  withSearchTerm:(NSString *)searchTerm
                       withFacet:(NSString *)facet
                     withSuccess:(void (^)(NSArray <ESDesignCaseList *> *array))success
                      andFailure:(void(^)(NSError *error))failure {
    [ESDesignCaseAPI get2DCasesWithSearchTerm:searchTerm
                                    withFacet:facet
                                     withSort:@""
                                   withOffset:offset
                                    withLimit:limit
                                   andSuccess:^(NSDictionary * _Nullable dict)
    {
        NSMutableArray *cases = [NSMutableArray array];
        if (dict && dict[@"cases"] && ![dict isKindOfClass:[NSNull class]] &&
            ![dict[@"cases"] isKindOfClass:[NSNull class]]) {
            for (NSDictionary *dic in dict[@"cases"]) {
                ESDesignCaseList *caseList = [ESDesignCaseList objFromDict:dic];
                if (caseList) {
                    [cases addObject:caseList];
                }
            }
        }
        if (success) {
            success(cases);
        }
    } andFailure:failure];
}

+ (void)get2DCaseDetailWithAssetId:(NSString *)assetId
                       withSuccess:(void(^)(ES2DCaseDetail *caseDetail))success
                        andFailure:(void(^)(NSError *error))failure {
    [ESDesignCaseAPI get2DCaseDetail:assetId withSuccess:^(NSDictionary * _Nullable dict) {
        ES2DCaseDetail *caseDetail = [ES2DCaseDetail objFromDict:dict];
        if (success) {
            success(caseDetail);
        }
    } andFailure:failure];
}
@end
