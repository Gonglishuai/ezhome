
#import "ESBaseModel.h"

/**
 "projectNum": "176915533",
 "ownerName": "牛洋洋",
 "phoneNum": "18141908115",
 "address": "北京北京市东城区",
 "housingEstate": "居然大厦"
 */

/// 施工项目
@interface ESConstructModel : ESBaseModel

@property (nonatomic, copy) NSString *projectNum;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *phoneNum;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *housingEstate;

@end
