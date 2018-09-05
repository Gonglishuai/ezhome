
#import "ESConstructDetailModel.h"
#import "ESEnterpriseAPI.h"

@implementation ESConstructDetailModel

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self updateDesignerDataSource];
    
    return self;
}

- (void)updateDesignerDataSource
{

        NSArray *section1 = @[
                              @{
                                  @"key"        :@"客户姓名",
                                  @"value"      :[ESConstructDetailModel getDataSourceValue:self.ownerName],
                                  @"showLine"   :@(YES),
                                  @"showArrow"  :@(NO),
                                  @"alertRed"   :@(NO)
                                },
                              @{
                                  @"key"        :@"联系电话",
                                  @"value"      :[ESConstructDetailModel getDataSourceValue:self.phoneNum],
                                  @"showLine"   :@(YES),
                                  @"showArrow"  :@(NO),
                                  @"alertRed"   :@(NO)
                                  },
                              @{
                                  @"key"        :@"客户编号",
                                  @"value"      :[ESConstructDetailModel getDataSourceValue:self.ownerNum],
                                  @"showLine"   :@(YES),
                                  @"showArrow"  :@(NO),
                                  @"alertRed"   :@(NO)
                                  },
                              @{
                                  @"key"        :@"房屋地址",
                                  @"value"      :[ESConstructDetailModel getDataSourceValue:self.address],
                                  @"showLine"   :@(YES),
                                  @"showArrow"  :@(NO),
                                  @"alertRed"   :@(NO)
                                  },
                              @{
                                  @"key"        :@"小区名称",
                                  @"value"      :[ESConstructDetailModel getDataSourceValue:self.housingEstate],
                                  @"showLine"   :@(YES),
                                  @"showArrow"  :@(NO),
                                  @"alertRed"   :@(NO)
                                  },
                              @{
                                  @"key"        :@"套内面积",
                                  @"value"      :[[ESConstructDetailModel getDataSourceValue:self.roomArea] stringByAppendingString:@"㎡"],
                                  @"showLine"   :@(NO),
                                  @"showArrow"  :@(NO),
                                  @"alertRed"   :@(NO)
                                  },
                              ];
        NSArray *section2 = @[
                              @{
                                  @"key"        :@"项目金额",
                                  @"value"      :[NSString stringWithFormat:@"¥%@", [ESConstructDetailModel getDataSourceValue:self.projectAmount]],
                                  @"showLine"   :@(YES),
                                  @"showArrow"  :@(NO),
                                  @"alertRed"   :@(NO)
                                  },
                              @{
                                  @"key"        :@"已付金额",
                                  @"value"      :[NSString stringWithFormat:@"¥%@", [ESConstructDetailModel getDataSourceValue:self.amounted]],
                                  @"showLine"   :@(NO),
                                  @"showArrow"  :@(YES),
                                  @"alertRed"   :@(NO)
                                  }
                              ];
        self.dataSourceDesigner = @[section1, section2];
}

+ (NSString *)getDataSourceValue:(NSString *)param
{
    if (param
        && [param isKindOfClass:[NSString class]])
    {
        return param;
    }
    
    return @"暂无数据";
}

#pragma mark - Public Method
+ (void)requestProjectDetailWithId:(NSString *)projectId
                           success:(void (^) (ESConstructDetailModel *model))success
                           failure:(void (^) (NSError *error))failure
{
    [ESEnterpriseAPI getConstructDetailWithPid:projectId
                                       success:^(NSDictionary *dict)
    {
    
        if (dict
            && [dict isKindOfClass:[NSDictionary class]])
        {
            SHLog(@"获取施工订单详情:%@",dict);

            ESConstructDetailModel *model = [ESConstructDetailModel createModelWithDic:dict];
            if (success)
            {
                success(model);
            }
        }
        else
        {
            if (failure)
            {
                failure(ERROR(@"-1", 999, @"获取施工订单详情, response格式不争取"));
            }
        }
        
    } failure:failure];
}

@end
