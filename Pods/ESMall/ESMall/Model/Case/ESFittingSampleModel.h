
#import "ESBaseModel.h"
#import "ESFittingCaseModel.h"

/**
 "spaceType":"主卧",
 "caseList":[
    {
    "caseId":"1699618",
    "caseImgUrl":"http://img-beta.gdfcx.net/img/59a68d80e4b0ac585a3cc563.img"
    }
]
 */

@interface ESFittingSampleModel : ESBaseModel

@property (nonatomic, copy) NSString *spaceimageName;
@property (nonatomic, copy) NSString *spaceTitle;
@property (nonatomic, copy) NSString *spaceSubTitle;
@property (nonatomic, copy) NSString *spaceTitleIconName;

@property (nonatomic, copy) NSString *spaceType;

@property (nonatomic, retain) NSArray <ESFittingCaseModel *> *caseList;

@end
