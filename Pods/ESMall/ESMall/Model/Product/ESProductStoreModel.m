
#import "ESProductStoreModel.h"

@implementation ESProductStoreModel

#pragma mark - Super Method
- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self updateModel];
    
    return self;
}

- (void)updateModel
{
    self.callStatus = YES;
    
    if (!self.mobile
        || ![self.mobile isKindOfClass:[NSString class]]
        || self.mobile.length <= 0)
    {
        self.callStatus = NO;
        self.mobile = @"商家暂无电话";
    }
}

#pragma mark - Method
+ (NSArray *)updateDataSource:(NSArray <ESProductStoreModel *> *)array
            withSelectedIndex:(NSInteger)selectedIndex
{
    if (!array
        || ![array isKindOfClass:[NSArray class]]
        || array.count <= 0
        || ![[array firstObject] isKindOfClass:[ESProductStoreModel class]])
    {
        return array;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger i = 0; i < array.count; i++)
    {
        ESProductStoreModel *model = array[i];
        if (i == selectedIndex)
        {
            model.selectedStatus = YES;
            [arrM insertObject:model atIndex:0];

        }
        else
        {
            model.selectedStatus = NO;
            [arrM addObject:model];
        }
    }
    
    if (selectedIndex < 0)
    {
        ESProductStoreModel *model = [arrM firstObject];
        model.selectedStatus = YES;
    }
    
    return [arrM copy];
}

+ (NSArray *)updateDataSource:(NSArray <ESProductStoreModel *> *)array
                    withTitle:(NSString *)title
{
    if (!array
        || ![array isKindOfClass:[NSArray class]]
        || array.count <= 0
        || ![[array firstObject] isKindOfClass:[ESProductStoreModel class]]
        || !title
        || ![title isKindOfClass:[NSString class]])
    {
        return array;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger i = 0; i < array.count; i++)
    {
        ESProductStoreModel *model = array[i];
        if ([title isEqualToString:model.storeName])
        {
            model.selectedStatus = YES;
            [arrM insertObject:model atIndex:0];
            
        }
        else
        {
            model.selectedStatus = NO;
            [arrM addObject:model];
        }
    }
    
    return [arrM copy];
}

@end
