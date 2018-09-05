
#import "ESBaseModel.h"

/**
 {
 "caseId":"1699618",
 "caseImgUrl":"http://img-beta.gdfcx.net/img/59a68d80e4b0ac585a3cc563.img"
 },
 */

@interface ESFittingCaseModel : ESBaseModel

@property (nonatomic, copy) NSString *brandId;
@property (nonatomic, copy) NSString *caseId;
@property (nonatomic, copy) NSString *caseImgUrl;

@end
