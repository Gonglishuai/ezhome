
#import "ESPayTimesModel.h"
#import "ESOrderAPI.h"
#import "ESAlipayServices.h"
//#import <ESFoundation/ESAlipayServices.h>
#import "ESMarketingAPI.h"
#import "ESWxServices.h"
#import "ESFinanceServices.h"

@implementation ESPayTimesModel

+ (NSArray *)getPayTimesCellIds
{
    return @[
             @"ESPayAmountCell",
             @"ESPaySwitchCell",
             @"ESPayTextInputCell",
             @"ESPayTipCell",
             @"ESPayWayTitleCell",
             @"ESPayWayCell",
             @"ESPayWayFinanceCell",
             @"ESPayEnterpriseAgreementCell",
             @"ESPayFinanceCollectionViewTableViewCell",
             ];
}

+ (NSMutableArray *)createEnterprisePayCells:(BOOL)firstStatus
                                 partPayment:(BOOL)partPayment
                                  hasFinance:(BOOL)hasFinance
                                      amount:(NSString *)amount
                                     message:(NSString *)message
{
    amount = [@"¥" stringByAppendingString:[ESPayTimesModel checkString:amount]];
    message = [ESPayTimesModel checkString:message];
    NSMutableArray *array = [NSMutableArray array];
    NSArray *array1 = @[
                       @{
                           @"cellId":@"ESPayAmountCell",
                           @"amount":amount,
                           @"title":firstStatus?@"支付金额":@"剩余金额",
                        },
                       @{
                           @"cellId":@"ESPaySwitchCell",
                           @"switchOn":@(NO),
                           @"switchEnabel":@(!hasFinance),
                        },
                       @{
                           @"cellId":@"ESPayTipCell",
                           @"message":message,
//                           @"message":@"温馨提示：1000万元设计家装修基金已送完，该笔支付将无法再获得30%返现。",
                        },
                       @{
                           @"cellId":@"ESPayWayTitleCell",
                           @"title":@"选择支付方式",
                           }];
    [array addObjectsFromArray:array1];

    if (hasFinance) {
        [array addObjectsFromArray:@[@{
                                         @"cellId":@"ESPayWayFinanceCell",
                                         @"icon":@"pay_way_finance",
                                         @"title":@"居然分期付",
                                         @"subtitle":@"居然分期付",
                                         @"selectedIcon":@"pay_select",
                                         @"selected":@(YES),
                                         },
                                     @{
                                         @"cellId":@"ESPayFinanceCollectionViewTableViewCell",
                                         }
                                     ]
         ];
    }
    NSArray *array2 = @[@{
                           @"cellId":@"ESPayWayCell",
                           @"icon":@"pay_way_ali",
                           @"title":@"支付宝",
                           @"selectedIcon":(hasFinance?@"pay_unSelect":@"pay_select"),
                           @"selected":@(!hasFinance),
                        },
                       @{
                           @"cellId":@"ESPayWayCell",
                           @"icon":@"pay_way_wx",
                           @"title":@"微信",
                           @"selectedIcon":@"pay_unSelect",
                           @"selected":@(NO),
                           },
                       @{
                           @"cellId":@"ESPayWayCell",
                           @"icon":@"pay_yinlian",
                           @"title":@"银联支付",
                           @"selectedIcon":@"pay_unSelect",
                           @"selected":@(NO),
                           },
                       @{
                           @"cellId":@"ESPayEnterpriseAgreementCell",
                           @"selected":@(NO),
                        },
                       ];
    [array addObjectsFromArray:array2];
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSDictionary *dict in array)
    {
        [arrM addObject:[dict mutableCopy]];
    }
    
    return arrM;
}

+ (NSMutableArray *)createMaterialPayCells:(BOOL)firstStatus
                               partPayment:(BOOL)partPayment
                                hasFinance:(BOOL)hasFinance
                                    amount:(NSString *)amount
{
    amount = [@"¥" stringByAppendingString:[ESPayTimesModel checkString:amount]];
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray *array1 = @[
                       @{
                           @"cellId":@"ESPayAmountCell",
                           @"amount":amount,
                           @"title":firstStatus?@"支付金额":@"剩余金额",
                        },
                       @{
                           @"cellId":@"ESPaySwitchCell",
                           @"switchOn":@(NO),
                           @"switchEnabel":@(!hasFinance),
                        },
                       @{
                           @"cellId":@"ESPayTipCell",
                           @"message":@"",
                        },
                       @{
                           @"cellId":@"ESPayWayTitleCell",
                           @"title":@"选择支付方式",
                           }];
    [array addObjectsFromArray:array1];
    if (hasFinance) {
        [array addObjectsFromArray:@[@{
                                       @"cellId":@"ESPayWayFinanceCell",
                                       @"icon":@"pay_way_finance",
                                       @"title":@"居然分期付",
                                       @"subtitle":@"居然分期付",
                                       @"selectedIcon":@"pay_select",
                                       @"selected":@(YES),
                                       },
                                     @{
                                       @"cellId":@"ESPayFinanceCollectionViewTableViewCell",
                                       }
                                     ]
         ];
    }
    NSArray *array2 = @[
                       @{
                           @"cellId":@"ESPayWayCell",
                           @"icon":@"pay_way_ali",
                           @"title":@"支付宝",
                           @"selectedIcon":(hasFinance?@"pay_unSelect":@"pay_select"),
                           @"selected":@(!hasFinance),
                           },
                       @{
                           @"cellId":@"ESPayWayCell",
                           @"icon":@"pay_way_wx",
                           @"title":@"微信",
                           @"selectedIcon":@"pay_unSelect",
                           @"selected":@(NO),
                        },
                       @{
                           @"cellId":@"ESPayWayCell",
                           @"icon":@"pay_yinlian",
                           @"title":@"银联支付",
                           @"selectedIcon":@"pay_unSelect",
                           @"selected":@(NO),
                           },
                       ];
    [array addObjectsFromArray:array2];
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSDictionary *dict in array)
    {
        [arrM addObject:[dict mutableCopy]];
    }
    return arrM;
}

+ (void)updateDataSourceWithSwitchStatus:(BOOL)switchOn
                                      ds:(NSMutableArray *)dataSource
{
    if (!dataSource
        || ![dataSource isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    if (switchOn)
    {
        if (dataSource.count > 3)
        {
            [dataSource insertObject:[self getPayInputCell] atIndex:2];
        }
    }
    else
    {
        if (dataSource.count > 3)
        {
            [dataSource removeObjectAtIndex:2];
        }
    }
}

#pragma mark - Methods
+ (NSDictionary *)getPayInputCell
{
    NSDictionary *dict = @{
                           @"cellId":@"ESPayTextInputCell",
                           @"payAmount":@"",
                           };
    return [dict mutableCopy];
}

+ (NSString *)checkString:(NSString *)string
{
    if (!string
        || ![string isKindOfClass:[NSString class]])
    {
        string = @"";
    }
    
    return string;
}

+ (void)updatePayWayWithDataSource:(NSMutableArray *)dataSource
                         indexPath:(NSIndexPath *)indexPath
                             title:(NSString *)title;
{
    if (!dataSource
        || ![dataSource isKindOfClass:[NSArray class]]
        || !title
        || ![title isKindOfClass:[NSString class]])
    {
        return;
    }
    BOOL hasESPayTextInputCell = NO;
    for (NSInteger i = 0; i < dataSource.count; i++)
    {
        NSMutableDictionary *dict = dataSource[i];

        if ([dict isKindOfClass:[NSMutableDictionary class]]
            && dict[@"title"]
            && [dict[@"title"] isKindOfClass:[NSString class]]
            && dict[@"cellId"]
            && [dict[@"cellId"] isKindOfClass:[NSString class]])
        {
            if ([title isEqualToString:dict[@"title"]])
            {
                [dict setObject:@"pay_select" forKey:@"selectedIcon"];
                [dict setObject:@(YES) forKey:@"selected"];
            }
            else
            {
                if ([@"ESPayWayCell" isEqualToString:dict[@"cellId"]] || [@"ESPayWayFinanceCell" isEqualToString:dict[@"cellId"]])
                {
                    [dict setObject:@"pay_unSelect" forKey:@"selectedIcon"];
                    [dict setObject:@(NO) forKey:@"selected"];
                }
                
            }
            
        }
        if ([title isEqualToString:@"居然分期付"] && [@"ESPaySwitchCell" isEqualToString:dict[@"cellId"]]) {

//            [self updateDataSourceWithSwitchStatus:NO
//                                                ds:dataSource];
            [dict setObject:@(NO) forKey:@"switchOn"];
            [dict setObject:@(NO) forKey:@"switchEnabel"];
        } else {
            if ([@"ESPaySwitchCell" isEqualToString:dict[@"cellId"]]) {
                [dict setObject:@(YES) forKey:@"switchEnabel"];
            }
        }
        
        if ([title isEqualToString:@"居然分期付"] && [@"ESPayTextInputCell" isEqualToString:dict[@"cellId"]] ) {
            hasESPayTextInputCell = YES;
        }
    }
    if (hasESPayTextInputCell) {
        [self updateDataSourceWithSwitchStatus:NO
                                            ds:dataSource];
    }
}

+ (BOOL)getEnterpriseAgreementStatusWithDataSource:(NSArray *)dataSource

{
    if (!dataSource
        || ![dataSource isKindOfClass:[NSArray class]])
    {
        return NO;
    }
    
    for (NSDictionary *dic in dataSource)
    {
        if ([dic isKindOfClass:[NSDictionary class]]
            && dic[@"cellId"]
            && [dic[@"cellId"] isKindOfClass:[NSString class]]
            && [dic[@"cellId"] isEqualToString:@"ESPayEnterpriseAgreementCell"])
        {
            return [dic[@"selected"] boolValue];
        }
    }
    
    return NO;
}

+ (ESPayWay)getPayWayWithDataSource:(NSArray *)dataSource
{
    if (!dataSource
        || ![dataSource isKindOfClass:[NSArray class]])
    {
        return ESPayWayUnKnow;
    }
    
    for (NSDictionary *dic in dataSource)
    {
        if ([dic isKindOfClass:[NSDictionary class]]
            && dic[@"cellId"]
            && [dic[@"cellId"] isKindOfClass:[NSString class]]
            && ([dic[@"cellId"] isEqualToString:@"ESPayWayCell"] || [dic[@"cellId"] isEqualToString:@"ESPayWayFinanceCell"]))
        {
            if ([dic[@"selected"] boolValue]
                && dic[@"title"]
                && [dic[@"title"] isKindOfClass:[NSString class]])
            {
                if ([dic[@"title"] isEqualToString:@"支付宝"])
                {
                    return ESPayWayAlipy;
                }
                else if ([dic[@"title"] isEqualToString:@"微信"])
                {
                    return ESPayWayWeChat;
                }
                else if ([dic[@"title"] isEqualToString:@"银联支付"])
                {
                    return ESpayWayUPA;
                }
                else if ([dic[@"title"] isEqualToString:@"居然分期付"])
                {
                    return ESpayWayFinance;
                }
                else
                {
                    return ESPayWayUnKnow;
                }
            }
        }
    }
    
    return ESPayWayUnKnow;
}

+ (NSString *)getPayWayString:(ESPayWay)payWay
{
    NSString *payWayString = @"未知支付方式";
    switch (payWay) {
        case ESpayWayUPA:
            payWayString = @"银联支付";
            break;
        case ESPayWayAlipy:
            payWayString = @"支付宝";
        break;
        case ESPayWayWeChat:
            payWayString = @"微信";
            break;
        case ESpayWayFinance:
            payWayString = @"居然分期付";
            break;
        case ESPayWayUnKnow:
            payWayString = @"未知支付方式";
            break;
    }
    return payWayString;
}


+ (void)payForWithOrderId:(NSString *)orderId
                   rateId:(NSString *)rateId
                       payWay:(ESPayWay)payWay
                    payAmount:(NSString *)payAmount
   createOrderSuccessCallback:(void (^)(NSDictionary *dict))callback
                      success:(void (^)(BOOL success, NSString *tipMessage))success
                      failure:(void(^)(NSString *errorMessage))failure
{
    
    NSString *payWayStr = @"";
    if (payWay == ESPayWayAlipy) {
        payWayStr = @"1";
    } else if (payWay == ESPayWayWeChat) {
        payWayStr = @"3";
        if (![ESWxServices isWXAppInstalled]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(nil);
                }
                if (success) {
                    success(NO, @"您的手机未安装微信!");
                }
            });
            return;
        }
    } else if (payWay == ESpayWayUPA) {
        payWayStr = @"14";
    }  else if (payWay == ESpayWayFinance) {
        payWayStr = @"17";

    }
    [ESOrderAPI payForWithOrderId:orderId
                           rateId:rateId
                           payWay:payWayStr
                        payAmount:payAmount
                          Success:^(NSDictionary *dict)
     {
         // 调用后端支付接口成功后, callback去进行一些动作, 例如隐藏hud
         if (callback) {
             callback(dict);
         }
         if(payWay == ESpayWayUPA) {
             return ;
         }
         [self payWithInfo:dict
                    payWay:payWay
                  callBack:success];
         
     } failure:^(NSError *error) {
         
         if (failure) {
             failure([self getErrorMessage:error]);
         }
     }];
}

+ (void)payWithInfo:(NSDictionary *)payInfo
             payWay:(ESPayWay)payWay
           callBack:(void (^) (BOOL success, NSString *message))callback
{
    //支付
    if (payWay == ESPayWayAlipy)
    {
        NSString *payStr = payInfo[@"data"] ? payInfo[@"data"] : @"";
        [ESAlipayServices aliPayBackWithModel:payStr andBlock:^(NSString *code) {
            NSString *messageTitle = nil;
            BOOL success = NO;
            if ([code isEqualToString:@"9000"])
            {
                messageTitle = @"支付成功!";
                success = YES;
            }
            else if ([code isEqualToString:@"5000"])
            {
                messageTitle = @"重复请求!";
                success = NO;
            }
            else if ([code isEqualToString:@"6001"])
            {
                messageTitle = @"该订单支付取消!";
                success = NO;
            }
            else
            {
                messageTitle = @"支付失败!";
                success = NO;
            }
            
            if (callback)
            {
                callback(success, messageTitle);
            }
        }];
    }
    else if (payWay == ESPayWayWeChat)
    {
        NSDictionary *payDic = payInfo[@"data"] ? payInfo[@"data"] : [NSDictionary dictionary];
        
        [[ESWxServices sharedInstance] wxPayWithPayInfo:payDic block:^(BaseResp *resp) {
            //支付返回结果，实际支付结果需要去微信服务器端查询
            NSString *payResoult = @"";
            BOOL success = NO;
            if (resp) {
                switch (resp.errCode)
                {
                    case WXSuccess:
                    {
                        payResoult = @"支付成功!";
                        success = YES;
                        break;
                    }
                    case WXErrCodeCommon:
                    {
                        payResoult = @"支付失败!";
                        success = NO;
                        break;
                    }
                    case WXErrCodeUserCancel:
                    {
                        payResoult = @"该订单支付取消!";
                        success = NO;
                        break;
                    }
                    default:
                    {
                        payResoult = [NSString stringWithFormat:@"支付失败!retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                        success = NO;
                        break;
                    }
                }
            }
            
            if (callback)
            {
                callback(success, payResoult);
            }
        }];
    } else if (payWay == ESpayWayFinance) {
        [[ESFinanceServices sharedInstance] financePayWithPayInfo:payInfo block:^(NSDictionary *resultDic) {
            SHLog(@"%@", resultDic);
            NSString *suc = [NSString stringWithFormat:@"%@", resultDic[@"errCode"]?resultDic[@"errCode"]:@""];
            if ([suc isEqualToString:@"000000"]) {
                if (callback) {
                    callback(YES, @"支付成功!");
                }
            } else {
                NSString *errmsg = [NSString stringWithFormat:@"%@", resultDic[@"errMsg"]?resultDic[@"errMsg"]:@""];
                if (callback) {
                    callback(NO, errmsg);
                }
            }
        }];
    }
}

+ (void)requestForEnterpriseTipMessage:(void (^) (NSString *message))success
                               failure:(void (^) (NSError *error))failure
{
    [ESMarketingAPI requestForEnterpriseTipMessage:^(NSDictionary *dic) {
        
        if (dic
            && [dic isKindOfClass:[NSDictionary class]]
            && dic[@"data"]
            && [dic[@"data"] isKindOfClass:[NSString class]]
            && success)
        {
            SHLog(@"%@", dic);
            success(dic[@"data"]);
        }
        else
        {
            if (failure)
            {
                failure(ERROR(@"1", 111, @"获取施工返现活动提示文字失败, response格式不正确"));
            }
        }

    } failure:failure];
}

@end
