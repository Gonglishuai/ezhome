
#import "SHModel.h"
#import "MPCaseModel.h"
#import "MP3DCaseModel.h"
#import "ESDesignCaseList.h"
#import "ES2DCaseDetail.h"

@interface MPCaseBaseModel : SHModel

@property (nonatomic, retain) NSArray<MPCaseModel> *cases;
@property (nonatomic, retain) NSArray<MP3DCaseModel> *cases3D;
@property (nonatomic, retain) NSNumber *count;
@property (nonatomic, retain) NSNumber *limit;
@property (nonatomic, retain) NSNumber *offset;


- (instancetype)initWithDictionary:(NSDictionary *)dict;

///获取3D案例列表
+ (void)getDataWithParameters:(NSDictionary *)dictionary success:(void(^) (NSArray<ESDesignCaseList*> *array,NSString* total))success failure:(void(^) (NSError *error))failure;

/// 获取案例详情
+ (void)getCaseDetailInfoWithCaseId:(NSString *)caseid success:(void (^)(MPCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure;

+(void)getCaseDetailInfoWithAsset_Id:(NSString*)asset_Id success:(void (^)(MPCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure;
//点赞状态
+ (void)getCaseDetailInfoThumbStatusWithCaseId:(NSString *)caseid success:(void (^)(MPCaseModel *caseDetailModel))success failure:(void(^) (NSError *error))failure;

/**
 获取2D案例列表及搜索

 @param offset 开始位置
 @param limit 返回条数
 @param searchTerm 文字搜索项
 @param facet 标签搜索项
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)get2DCasesListWithOffset:(NSString *)offset
                       withLimit:(NSString *)limit
                  withSearchTerm:(NSString *)searchTerm
                       withFacet:(NSString *)facet
                     withSuccess:(void (^)(NSArray <ESDesignCaseList *> *array))success
                      andFailure:(void(^)(NSError *error))failure;

/**
 获取2D案例详情

 @param assetId 案例id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)get2DCaseDetailWithAssetId:(NSString *)assetId
                       withSuccess:(void(^)(ES2DCaseDetail *caseDetail))success
                        andFailure:(void(^)(NSError *error))failure;
@end
