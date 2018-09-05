
#import "ESBaseModel.h"
#import "ESSampleRoomTagFilterModel.h"

@interface ESSampleRoomTagModel : ESBaseModel

@property (nonatomic, copy) NSString *tagId;
@property (nonatomic, copy) NSString *mark;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, retain) NSArray <ESSampleRoomTagFilterModel *> *tagList;

+ (void)requestForSampleRoomFilterTagsSuccess:(void (^) (NSArray <ESSampleRoomTagModel *> *array))success
                                      failure:(void (^) (NSError *error))failure;

+ (void)updateTags:(NSArray *)tags;

+ (void)resetTags:(NSArray *)tags;

+ (void)updateTags:(NSArray *)tags
         indexPath:(NSIndexPath *)indexPath;

+ (NSString *)getSelectedTagsStrWithTags:(NSArray *)tags;

@end
