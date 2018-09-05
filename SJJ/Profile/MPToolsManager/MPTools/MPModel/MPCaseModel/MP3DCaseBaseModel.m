//
//  MP3DCaseBaseModel.m
//  Consumer
//
//  Created by 董鑫 on 16/8/22.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "MP3DCaseBaseModel.h"
#import "ESDesignCaseAPI.h"

@implementation MP3DCaseBaseModel


- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.count  = [CoStringManager judgeNSInteger:dict forKey:@"count"];
        self.limit  = [CoStringManager judgeNSInteger:dict forKey:@"limit"];
        self.offset = [CoStringManager judgeNSInteger:dict forKey:@"offset"];
        self.cases3D = [NSMutableArray array];
        if (dict && dict[@"cases"] && ![dict[@"cases"] isKindOfClass:[NSNull class]]) {
            for (NSDictionary *dic in dict[@"cases"]) {

//                if (dic && (!dic[@"hs_design_id"] ||
//                            [dic[@"hs_design_id"] isKindOfClass:[NSNull class]]))
//                    continue;
                
                [self.cases3D addObject:[MP3DCaseModel getModelFromDict:dic]];
            }
        }
    }
    return self;
}

+ (void)getDataWithParameters:(NSDictionary *)dictionary success:(void (^)(NSArray<ESDesignCaseList *> *, NSString *))success failure:(void (^)(NSError *))failure{
    
    [ESDesignCaseAPI get3DListOfDesignerCasesWithUrl:dictionary header:nil body:nil success:^(NSDictionary * _Nullable dictionary) {
        SHLog(@"getDataWithParameters  %@",dictionary);
        
        NSMutableArray *cases = [NSMutableArray array];
        NSString *count = [NSString stringWithFormat:@"%@", dictionary[@"count"] ];
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

//3D 首页案例-详情
+ (void)get3DCaseDetailInfoWithCaseId:(NSString *)caseid success:(void (^)(MP3DCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure {
    
}
//点赞状态
+ (void)getCaseDetailInfoThumbStatusWithCaseId:(NSString *)caseid success:(void (^)(MP3DCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure {
    
    
}

//asset_id -long 和X-Token -string 点赞请求

+(void)getCaseDetailInfoWithAsset_Id:(NSString*)asset_Id success:(void (^)(MP3DCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure{
    
    SHLog(@"调用网络请求2");
    
    
}

+ (void)get3DCasesListWithOffset:(NSString *)offset
                       withLimit:(NSString *)limit
                  withSearchTerm:(NSString *)searchTerm
                       withFacet:(NSString *)facet
                     withSuccess:(void (^)(NSArray <ESDesignCaseList *> *array))success
                      andFailure:(void(^)(NSError *error))failure {
    [ESDesignCaseAPI get3DCasesWithSearchTerm:searchTerm
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
@end
