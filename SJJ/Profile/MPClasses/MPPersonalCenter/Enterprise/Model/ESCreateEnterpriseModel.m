
#import "ESCreateEnterpriseModel.h"
#import "ESEnterpriseAPI.h"
#import "JRKeychain.h"

@implementation ESCreateEnterpriseModel

+ (NSArray *)getCreateEnterpriseItemsWithMemberInfo:(NSDictionary *)memberInfo
{
    NSString *name = @"";
    NSString *phone = @"";
    if (memberInfo
        && [memberInfo isKindOfClass:[NSDictionary class]])
    {
        if ([memberInfo[@"name"] isKindOfClass:[NSString class]])
        {
            name = memberInfo[@"name"];
        }
        
        if ([memberInfo[@"mobile_number"] isKindOfClass:[NSString class]])
        {
            phone = memberInfo[@"mobile_number"];
        }
    }
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ESCreateEnterprise"
                                                          ofType:@"plist"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    for (NSInteger i = 0; i < array.count; i++)
    {
        NSArray *arr = array[i];
        if ([arr isKindOfClass:[NSArray class]])
        {
            NSMutableArray *arrM = [NSMutableArray array];
            for (NSDictionary *dict in arr)
            {
                if ([dict isKindOfClass:[NSDictionary class]])
                {
                    NSMutableDictionary *dicM = [dict mutableCopy];
                    if ([dicM[@"key"] isKindOfClass:[NSString class]])
                    {
                        if ([dicM[@"key"] isEqualToString:@"ownerName"])
                        {
                            [dicM setObject:name forKey:@"message"];
                        }
                        else if ([dicM[@"key"] isEqualToString:@"phoneNum"])
                        {
                            [dicM setObject:phone forKey:@"message"];
                        }
                    }
                    [arrM addObject:dicM];
                }
            }
            [array replaceObjectAtIndex:i withObject:[arrM copy]];
        }
    }
    return [array copy];
}

+ (NSString *)checkDataCompleted:(NSArray *)array
{
    if (!array
        || ![array isKindOfClass:[NSArray class]])
    {
        return @"请输入姓名";
    }
    
    NSArray *checkList = @[@"ownerName",
                           @"phoneNum",
                           @"address",
                           @"housingEstate",
                           @"roomArea",
                           @"projectAmount",
                           @"ownerNum",
                           @"decorationCompany"];

    NSInteger i = 0;
    for (NSString *key in checkList)
    {
        NSDictionary *item = [self getCheckValueWithKey:key data:array];
        if (item
            && [item isKindOfClass:[NSDictionary class]]
            && [item[@"message"] isKindOfClass:[NSString class]]
            && [item[@"key"] isKindOfClass:[NSString class]])
        {
            NSString *message = item[@"message"];
            if ([key isEqualToString:@"ownerNum"])
            {
                if (message.length > 0)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[A-Za-z0-9-]+$"];
                    BOOL isMatchDetail = [predicate evaluateWithObject:message];
                    if (!isMatchDetail)
                    {
                        return @"客户编号应为英文、数字";
                    }
                }

                i++;
                
            }
            else if (message.length <= 0)
            {
                return item[@"placeholder"];
            }
            else if ([key isEqualToString:@"housingEstate"])
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[A-Za-z0-9\u4e00-\u9fa5-]+$"];
                BOOL isMatchDetail = [predicate evaluateWithObject:message];
                if (message.length < 2 || message.length > 32 || !isMatchDetail)
                {
                    return @"小区名称应为2-32个中文、英文、数字字符";
                }
                else
                {
                    i++;
                }
            }
            else if ([key isEqualToString:@"phoneNum"])
            {
                NSString *pattern = @"1[3|4|5|7|8|][0-9]{9}";
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
                BOOL isMatchName = [pred evaluateWithObject:message];
                if (message.length != 11 || !isMatchName)
                {
                    return @"请输入正确的手机号码";
                }
                else
                {
                    i++;
                }
            }
            else
            {
                NSString *regex = @"^[0-9]+(\\.[0-9]{1,2})?$";
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
                BOOL isMatchName = [pred evaluateWithObject:message];
                if (([key isEqualToString:@"ownerName"]
                     || [key isEqualToString:@"address"]
                     || [key isEqualToString:@"decorationCompany"])
                    || (isMatchName
                        && [message floatValue] > 0))
                {
                    i++;
                }
                else
                {
                    NSString *placeholder = item[@"placeholder"];
                    if (placeholder.length > 3)
                    {
                        return [@"请输入正确的" stringByAppendingString:[placeholder substringFromIndex:3]];
                    }
                }
            }
        }
        else
        {
            return @"请检查输入项";
        }
    }
    
    if (i == checkList.count)
    {
        return nil;
    }
    
    return @"请检查输入项";
}

+ (NSMutableDictionary *)getCheckValueWithKey:(NSString *)key data:(NSArray *)data
{
   if (!key
       || ![key isKindOfClass:[NSString class]]
       || !data
       || ![data isKindOfClass:[NSArray class]])
   {
       return nil;
   }
    
    for (NSArray *arr in data)
    {
        if ([arr isKindOfClass:[NSArray class]])
        {
            for (NSMutableDictionary *dic in arr)
            {
                if ([dic isKindOfClass:[NSDictionary class]]
                    && [dic[@"key"] isKindOfClass:[NSString class]]
                    && [key isEqualToString:dic[@"key"]])
                {
                    return dic;
                }
            }
        }
    }
    
    return nil;
}

+ (void)getDecorationsSuccess:(void (^) (NSArray <ESEnterpriseDecorationModel *> *array))success
                      failure:(void (^) (NSError *error))failure
{
    [ESEnterpriseAPI getDecorationsSuccess:^(NSArray *array)
    {
        if (array
            && [array isKindOfClass:[NSArray class]])
        {
            NSMutableArray *arrM = [NSMutableArray array];
            for (NSDictionary *dic in array)
            {
                if (dic
                    && [dic isKindOfClass:[NSDictionary class]])
                {
                    ESEnterpriseDecorationModel *model = [ESEnterpriseDecorationModel createModelWithDic:dic];
                    [arrM addObject:model];
                }
            }
            
            if (success)
            {
                success([arrM copy]);
            }
        }
        else
        {
            if (failure)
            {
                failure(ERROR(@"-1", 999, @"获取装饰公司,response格式不争取"));
            }
        }
        
    } failure:failure];
}

+ (void)createEnterpriseWithData:(NSArray *)data
                      memberInfo:(NSDictionary *)memberInfo
                         success:(void (^) (NSDictionary *dict))success
                         failure:(void (^) (NSError *error))failure
{
    NSDictionary *body = [self getBodyWithData:data
                                    memberInfo:memberInfo];
    [ESEnterpriseAPI createEnterpriseWithBody:body success:^(NSDictionary *dict) {
        
        if (dict
            && [dict isKindOfClass:[NSDictionary class]]
            && success) {
            success(dict);
        } else {
            if (failure) {
                failure(ERROR(@"-1", 999, @"创建施工订单, response格式不争取"));
            }
        }
        
    } failure:failure];
    
}

/**
 {
 "ownerName": "居然之家",
 "ownerNum": "BJ0023",
 "ownerId": "20738944",
 "ownerUid": "6338c296-400a-4d5c-82c1-a92acb97dd77",
 "channel": "10101",
 "region": "100100",
 "phoneNum": "18645222236",
 "projectType": "1001",
 "designerId": 152,
 "designerName": "熊大",
 "decorationCompany": "leWu",
 "provinceCode": "110100",
 "provinceName": "北京市",
 "cityCode": "110100",
 "cityName": "北京市",
 "districtCode": "110101",
 "districtName": "东城区",
 "housingEstate": "紫御华府",
 "roomArea": 112.3,
 "projectAmount": 50
 }
 */
+ (NSDictionary *)getBodyWithData:(NSArray *)array
                       memberInfo:(NSDictionary *)memberInfo
{
    if (!array
        || ![array isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSString *projectType = @"1001";// 施工订单projectType
    return @{
             @"ownerName"           : [self getNormalDataWithKey:@"ownerName"
                                                           datas:array],
             @"ownerNum"            : [self getNormalDataWithKey:@"ownerNum"
                                                           datas:array],
             @"ownerJid"             : [self getMemberInfoWithKey:@"ownerId"
                                                      memberInfo:memberInfo],
             
             @"channel"             : [JRBaseAPI getDefaultHeader][@"X-Channel"],
             @"region"              : [JRBaseAPI getDefaultHeader][@"X-Region"],
             @"phoneNum"            : [self getNormalDataWithKey:@"phoneNum"
                                                           datas:array],
             @"projectType"         : projectType,
             @"designerName"        : [self getOwnerInfo:@"designerName"],
             @"decorationCompany"   : [self getNormalDataWithKey:@"decorationCompany"
                                                           datas:array],
             @"provinceCode"        : [self getAddressDataWithKey:@"provinceCode"
                                                            datas:array],
             @"provinceName"        : [self getAddressDataWithKey:@"provinceName"
                                                            datas:array],
             @"cityCode"            : [self getAddressDataWithKey:@"cityCode"
                                                            datas:array],
             @"cityName"            : [self getAddressDataWithKey:@"cityName"
                                                            datas:array],
             @"districtCode"        : [self getAddressDataWithKey:@"districtCode"
                                                            datas:array],
             @"districtName"        : [self getAddressDataWithKey:@"districtName"
                                                            datas:array],
             @"housingEstate"       : [self getNormalDataWithKey:@"housingEstate"
                                                           datas:array],
             @"roomArea"            : [self getNormalDataWithKey:@"roomArea"
                                                           datas:array],
             @"projectAmount"       : [self getNormalDataWithKey:@"projectAmount"
                                                          datas:array]
             };
}

+ (NSString *)getAddressDataWithKey:(NSString *)key
                              datas:(NSArray *)datas
{
    if (!key
        || ![key isKindOfClass:[NSString class]])
    {
        return @"";
    }
    
    NSDictionary *item = [self getCheckValueWithKey:@"address"
                                               data:datas];
    if (item
        && [item isKindOfClass:[NSDictionary class]]
        && item[@"address"]
        && [item[@"address"] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *address = item[@"address"];
        NSString *value = address[key];
        if (value)
        {
            return value;
        }
    }

    return @"";
}

+ (NSString *)getOwnerInfo:(NSString *)key
{
    if (!key
        || ![key isKindOfClass:[NSString class]])
    {
        return @"";
    }
    
    if ([key isEqualToString:@"designerId"])
    {
        NSString *acsMemberId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
        return acsMemberId ? acsMemberId : @"";
    }
    else if ([key isEqualToString:@"designerName"])
    {
        NSString *designerName = [JRKeychain loadSingleUserInfo:UserInfoCodeName];
        return designerName ? designerName : @"";
    }
    else
    {
        return @"";
    }
}

+ (NSString *)getMemberInfoWithKey:(NSString *)key
                        memberInfo:(NSDictionary *)memberInfo
{
    if (!key
        || ![key isKindOfClass:[NSString class]]
        || !memberInfo
        || ![memberInfo isKindOfClass:[NSDictionary class]])
    {
        return @"";
    }
    
    NSString *memberInfoKey = @"";
    if ([key isEqualToString:@"ownerId"])
    {
        memberInfoKey = @"member_id";
    }
//    else if ([key isEqualToString:@"ownerUid"])
//    {
//        memberInfoKey = @"hs_uid";
//    }
    
    NSString *value = memberInfo[memberInfoKey];
    if (value)
    {
        return value;
    }
    
    return @"";
}

+ (NSString *)getNormalDataWithKey:(NSString *)key
                             datas:(NSArray *)datas
{
    NSDictionary *item = [self getCheckValueWithKey:key
                                               data:datas];
    if (item
        && [item isKindOfClass:[NSDictionary class]]
        && [item[@"key"] isKindOfClass:[NSString class]])
    {
        NSString *message = nil;
        if ([@"decorationCompany" isEqualToString:item[@"key"]])
        {
            message = item[@"decorationCompany"];
        }
        else
        {
            message = item[@"message"];
        }
        
        if (message)
        {
            return message;
        }
    }
    
    return @"";
}

@end
