
#import "ESBaseModel.h"
#import "ESFittingRoomBannerModel.h"
#import "ESFittingSampleModel.h"

@interface ESFittingHomeModel : ESBaseModel

@property (nonatomic, retain) NSArray <ESFittingRoomBannerModel *> *banner;
@property (nonatomic, retain) NSArray <ESFittingSampleModel *> *sampleList;

+ (void)requestForCaseFittingRoomHomeSuccess:(void (^) (ESFittingHomeModel *model))success
                                     failure:(void (^) (NSError *error))failure;

@end
