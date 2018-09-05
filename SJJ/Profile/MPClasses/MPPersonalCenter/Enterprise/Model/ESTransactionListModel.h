
#import "ESBaseModel.h"
#import "ESTransactionDetailModel.h"

/// 交易明细列表
@interface ESTransactionListModel : ESBaseModel

@property (nonatomic, copy) NSString *count;
@property (nonatomic, copy) NSString *offset;
@property (nonatomic, copy) NSString *limit;
@property (nonatomic, retain) NSArray <ESTransactionDetailModel *> *data;

+ (void)requestTransactionistWithOffset:(NSInteger)offset
                                  limlt:(NSInteger)limit
                               orderNum:(NSString *)orderNum
                                success:(void (^) (ESTransactionListModel *model))success
                                failure:(void (^) (NSError *error))failure;

@end
