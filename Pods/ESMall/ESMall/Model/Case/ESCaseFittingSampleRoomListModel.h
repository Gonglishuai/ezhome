
#import "ESBaseModel.h"
#import "ESFittingSampleRoomModel.h"

/**
 count (integer, optional),
 limit (integer, optional),
 offset (integer, optional),
 data (Array[SampleRoomDto], optional)
 */
@interface ESCaseFittingSampleRoomListModel : ESBaseModel

@property (nonatomic, copy) NSString *count;
@property (nonatomic, copy) NSString *limit;
@property (nonatomic, copy) NSString *offset;
@property (nonatomic, retain) NSArray <ESFittingSampleRoomModel *> *data;

+ (void)requestForFittingRoomListWithOffset:(NSInteger)offset
                                      limlt:(NSInteger)limit
                                  apaceType:(NSString *)spaceType
                                    success:(void (^) (ESCaseFittingSampleRoomListModel *model))success
                                    failure:(void (^) (NSError *error))failure;

@end
