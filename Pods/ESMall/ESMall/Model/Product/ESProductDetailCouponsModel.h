
#import "ESBaseModel.h"

@interface ESProductDetailCouponsModel : ESBaseModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSArray <NSString *> *list;

// 我的新增
@property (nonatomic, retain) NSArray <NSDictionary *> *listArr;
@property (nonatomic, assign) CGFloat height;

@end
