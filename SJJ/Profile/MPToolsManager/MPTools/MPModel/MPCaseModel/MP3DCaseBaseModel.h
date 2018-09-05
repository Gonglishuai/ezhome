//
//  MP3DCaseBaseModel.h
//  Consumer
//
//  Created by 董鑫 on 16/8/22.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "SHModel.h"
#import "MP3DCaseModel.h"
#import "ESDesignCaseList.h"

@interface MP3DCaseBaseModel : SHModel
//@property (nonatomic, retain) NSArray<MPCaseModel> *cases;
@property (nonatomic, strong) NSMutableArray < MP3DCaseModel *> *cases3D;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger offset;

- (instancetype)initWithDictionary:(NSDictionary *)dict;


///获取3D案例列表
+ (void)getDataWithParameters:(NSDictionary *)dictionary success:(void(^) (NSArray<ESDesignCaseList*> *array,NSString *count))success failure:(void(^) (NSError *error))failure;



/// 获取案例详情
+ (void)get3DCaseDetailInfoWithCaseId:(NSString *)caseid success:(void (^)(MP3DCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure;

+(void)getCaseDetailInfoWithAsset_Id:(NSString*)asset_Id success:(void (^)(MP3DCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure;
//点赞状态
+ (void)getCaseDetailInfoThumbStatusWithCaseId:(NSString *)caseid success:(void (^)(MP3DCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure;

/**
 获取3D案例列表及搜索
 
 @param offset 开始位置
 @param limit 返回条数
 @param searchTerm 文字搜索项
 @param facet 标签搜索项
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)get3DCasesListWithOffset:(NSString *)offset
                       withLimit:(NSString *)limit
                  withSearchTerm:(NSString *)searchTerm
                       withFacet:(NSString *)facet
                     withSuccess:(void (^)(NSArray <ESDesignCaseList *> *array))success
                      andFailure:(void(^)(NSError *error))failure;
@end
