
#import "ESBaseModel.h"

@interface ESSampleRoomTagFilterModel : ESBaseModel

@property (nonatomic, copy) NSString *tagId;
@property (nonatomic, copy) NSString *tagName;

@property (nonatomic, assign) BOOL selectedStatus;
@property (nonatomic, assign) BOOL currentSelectedStatus;

@end
