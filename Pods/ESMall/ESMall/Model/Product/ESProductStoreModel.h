
#import "ESBaseModel.h"

/**
 门店地址的模型
 */

@interface ESProductStoreModel : ESBaseModel

@property (nonatomic, copy) NSString *storeAddress;

@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;

// 我的新增
@property (nonatomic, assign) BOOL selectedStatus;
@property (nonatomic, assign) BOOL callStatus;

+ (NSArray *)updateDataSource:(NSArray <ESProductStoreModel *> *)array
            withSelectedIndex:(NSInteger)selectedIndex;

+ (NSArray *)updateDataSource:(NSArray <ESProductStoreModel *> *)array
                    withTitle:(NSString *)title;

@end
