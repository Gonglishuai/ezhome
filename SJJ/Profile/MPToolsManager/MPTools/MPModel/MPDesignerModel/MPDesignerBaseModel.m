
#import "MPDesignerBaseModel.h"
#import "ESMemberAPI.h"
#import <ESMemberSearchAPI.h>

@implementation MPDesignerBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (![dict isKindOfClass:[NSNull class]]) {
            [self getModelWithDict:dict];
        }
    }
    return self;
}

- (void)getModelWithDict:(NSDictionary *)dict {
    if ([dict allKeys].count == 0) return;

    self.count = dict[@"count"];
    self.limit = dict[@"limit"];
    self.offset = dict[@"offset"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in dict[@"designer_list"]) {
        MPDesignerInfoModel *model = [[MPDesignerInfoModel alloc] initWithDictionary:dic];
        [array addObject:model];
    }
    self.designer_list = (id)array;
}

+ (void)getDataWithParameters:(NSDictionary *)dictionary success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    
    [ESMemberSearchAPI getDesignersListWithParam:dictionary header:nil body:nil andSuccess:^(NSDictionary *dict) {
        MPDesignerBaseModel *model = [[MPDesignerBaseModel alloc] initWithDictionary:dict];
        if (success) {
            success(model.designer_list);
        }
    } andFailure:failure];
}


+ (void)getDesignerInfoWithParam:(NSDictionary *)param
                         success:(void (^)(MPDesignerInfoModel* model))success
                         failure:(void(^) (NSError *error))failure {

    
}

+ (void)getDesignerFilterTagsWithSuccess:(void(^)(NSArray *arr))success
                              andFailure:(void(^)(NSError *error))failure {
    [ESMemberAPI getDesignerTagsWithSuccess:^(NSDictionary *dict) {
        NSArray *list = [NSArray array];
        if (dict && dict[@"data"]) {
            list = [NSArray arrayWithArray:dict[@"data"]];
        }
        if (success) {
            success(list);
        }
    } andFailure:failure];
}
@end
