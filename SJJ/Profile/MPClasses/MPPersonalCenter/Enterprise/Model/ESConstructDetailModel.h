
#import "ESBaseModel.h"
/**
 "projectNum": "176915533",
 "ownerName": "牛洋洋",
 "phoneNum": "18141908115",
 "address": "北京北京市东城区",
 "housingEstate": "居然大厦",
 "sourceOrderId": "101611865297125376",
 "projectAmount": 123,
 "amounted": 0
 */

/// 设计师施工项目详情
@interface ESConstructDetailModel : ESBaseModel

@property (nonatomic, copy) NSString *projectNum;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *phoneNum;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *housingEstate;
@property (nonatomic, copy) NSString *sourceOrderId;
@property (nonatomic, copy) NSString *projectAmount;
@property (nonatomic, copy) NSString *amounted;
@property (nonatomic, copy) NSString *roomArea;
@property (nonatomic, copy) NSString *ownerNum;

@property (nonatomic, retain) NSArray *dataSourceDesigner;

+ (void)requestProjectDetailWithId:(NSString *)projectId
                           success:(void (^) (ESConstructDetailModel *model))success
                           failure:(void (^) (NSError *error))failure;

@end
