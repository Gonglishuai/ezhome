
#import "ESBaseModel.h"
#import "ESSampleRoomModel.h"

/**
 count (integer, optional),
 limit (integer, optional),
 offset (integer, optional),
 data (Array[SampleRoomDto], optional)
 */
@interface ESSampleRoomListModel : ESBaseModel

@property (nonatomic, copy) NSString *count;
@property (nonatomic, copy) NSString *limit;
@property (nonatomic, copy) NSString *offset;
@property (nonatomic, retain) NSArray <ESSampleRoomModel *> *data;

+ (void)requestForSampleRoomListWithOffset:(NSInteger)offset
                                     limlt:(NSInteger)limit
                                    tagStr:(NSString *)tagStr
                                searchTerm:(NSString *)searchTerm
                                   success:(void (^) (ESSampleRoomListModel *model))success
                                   failure:(void (^) (NSError *error))failure;

@end
