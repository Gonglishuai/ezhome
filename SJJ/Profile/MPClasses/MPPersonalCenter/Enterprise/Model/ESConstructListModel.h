
#import "ESBaseModel.h"
#import "ESConstructModel.h"

/**
 "count":29,
 "offset":0,
 "limit":10,
 "data":Array[10]
 */

/// 施工项目列表
@interface ESConstructListModel : ESBaseModel

@property (nonatomic, copy) NSString *count;
@property (nonatomic, copy) NSString *offset;
@property (nonatomic, copy) NSString *limit;
@property (nonatomic, retain) NSArray <ESConstructModel *> *data;

+ (void)requestConstructListWithOffset:(NSInteger)offset
                                 limlt:(NSInteger)limit
                               success:(void (^) (ESConstructListModel *model))success
                               failure:(void (^) (NSError *error))failure;

@end
