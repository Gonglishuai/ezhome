
#import "ESPayTimesViewController.h"
#import "ESPayTimesView.h"
#import "ESPayTimesModel.h"
#import "ESMyOrderViewController.h"
#import "ESPaySucessViewController.h"
#import "MBProgressHUD.h"
#import "ESPayAlertView.h"
#import <ESFoundation/UMengServices.h>
#import <ESNetworking/SHAlertView.h>
#import "ESUPAServices.h"
#import "JRKeychain.h"
#import "ESOrderAPI.h"
#import "MBProgressHUD+NJ.h"
#import "ESFinanceServices.h"
#import "MGJRouter.h"

@interface ESPayTimesViewController ()<ESPayTimesViewDelegate>
@property (strong, nonatomic)NSIndexPath *financeSelectIndexPath;
@property (copy, nonatomic)NSString *payWayTitle;
@property (strong, nonatomic)NSMutableArray *arrayDS;
@end

@implementation ESPayTimesViewController
{
    NSString *_payOrderId;
    NSString *_actOrderId;
    NSString *_brandId;
    NSString *_amount;
    NSString *_payAmount;
    BOOL _partPayment;
    ESPayType _payType;
    ESPayTimesType _payTimesType;
    
    NSDictionary *_loanDic;
    ESPayTimesView *_payView;
    
    BOOL _hasDian;
}

- (instancetype)initWithOrderId:(__kindof NSString *)orderId
                     payOrderId:(__kindof NSString *)payOrderId
                        brandId:(__kindof NSString *)brandId
                         amount:(__kindof NSString *)amount
                    partPayment:(BOOL)partPayment
                        loanDic:(NSDictionary *)loanDic
                        payType:(ESPayType)payType
                   payTimesType:(ESPayTimesType)payTimesType
{
    self = [super init];
    if (self)
    {
        _partPayment = partPayment;
        _payType = payType;
        _payTimesType = payTimesType;
        if (payTimesType == ESPayTimesTypeFirst) {
            _loanDic = [NSDictionary dictionaryWithDictionary:loanDic];
        } else {
            _loanDic = [NSDictionary dictionary];
        }
        
        _payWayTitle = @"居然分期付";
        if (payOrderId
            && [payOrderId isKindOfClass:[NSString class]]
            && payOrderId.length > 0)
        {
            _payOrderId = payOrderId;
        }
        if (orderId
            && [orderId isKindOfClass:[NSString class]]
            && orderId.length > 0)
        {
            _actOrderId = orderId;
        }
        
        if (amount
            && [amount isKindOfClass:[NSString class]]
            && amount.length > 0)
        {
            _amount = amount;
        }
        else
        {
            _amount = @"";
        }
        
        if (brandId
            && [brandId isKindOfClass:[NSString class]]
            && brandId.length > 0)
        {
            _brandId = brandId;
        }
        else
        {
            _brandId = @"0";
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _arrayDS = [NSMutableArray array];
    _financeSelectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self initData];
    
    [self initUI];
    
    [self requestData];
}

- (void)initData
{
    
    if (_payType == ESPayTypeMaterial || _payType == ESPayTypePkgProjectList || _payType == ESPayTypePkgProjectDetail)
    {
        BOOL firstPay = _payTimesType == ESPayTimesTypeFirst;
        NSArray *datasArray = [NSArray array];
        if (_loanDic && _loanDic[@"installments"]
            && ![_loanDic[@"installments"] isKindOfClass:[NSNull class]]) {
            
            datasArray = _loanDic[@"installments"];
        }
        WS(weakSelf)
        [MGJRouter openURL:@"hiddenFinance" withUserInfo:nil completion:^(id result) {
            NSString *res = [NSString stringWithFormat:@"%@", result];
            BOOL hiddenFinance = [res isEqualToString:@"1"];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.arrayDS = [ESPayTimesModel createMaterialPayCells:firstPay
                                                               partPayment:_partPayment
                                                                hasFinance:(datasArray.count>0 && (!hiddenFinance))
                                                                    amount:_amount];
                [_payView tableViewReload];
            });
            
        }];
        
    }
    
    _payAmount = _amount;
}

- (void)initUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.titleLabel.text = @"支付订单";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.rightButton setImage:nil
                      forState:UIControlStateNormal];
    [self.rightButton setTitle:@"支付说明"
                      forState:UIControlStateNormal];
    
    CGRect patViewFrame = CGRectMake(0,
                                     NAVBAR_HEIGHT,
                                     SCREEN_WIDTH,
                                     SCREEN_HEIGHT - NAVBAR_HEIGHT
                                     );
    _payView = [[ESPayTimesView alloc] initWithFrame:patViewFrame];
    _payView.viewDelegate = self;
    [self.view addSubview:_payView];
    
    WS(weakSelf);
    NSString *payCount = @"0.00";
    //    if (_loanDic && _loanDic[@"installments"]
    //        && ![_loanDic[@"installments"] isKindOfClass:[NSNull class]]) {
    //
    //        NSArray *datasArray = [NSArray array];
    //        @try {
    //            datasArray = _loanDic[@"installments"];
    //        } @catch (NSException *exception) {
    //            SHLog(@"%@", exception.description);
    //        } @finally {
    //            if (datasArray.count>_financeSelectIndexPath.row) {
    //                NSDictionary *dict = datasArray[_financeSelectIndexPath.row];
    //                payCount = [NSString stringWithFormat:@"%@", dict[@"cost"]];
    //            }
    //        }
    //    } else {
    payCount = _amount;
    //    }
    
    [_payView updateButtonWithAmount:payCount
                              enable:[self getPayButtonEnableStatus]];
}

- (void)requestData
{
    if (_payType != ESPayTypeEnterprise)
    {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:_payView animated:YES];
    __weak UIView *weakView = _payView;
    WS(weakSelf);
    [ESPayTimesModel requestForEnterpriseTipMessage:^(NSString *message)
     {
         [MBProgressHUD hideHUDForView:weakView animated:YES];
         [weakSelf requestForTopOverSuccess:message];
         
     } failure:^(NSError *error) {
         
         SHLog(@"%@", error);
         [MBProgressHUD hideHUDForView:weakView animated:YES];
         [weakSelf requestForTopOverSuccess:@""];
     }];
}

- (void)goPayWithOrderId:(NSString *)orderId
                 brandId:(NSString *)brandId {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI goPayWithOrderId:orderId brandId:brandId Success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        NSDictionary *resultDic = [NSDictionary dictionaryWithDictionary:([dict objectForKey:@"data"] ? [dict objectForKey:@"data"]:[NSDictionary dictionary])];
        NSString *orId = [NSString stringWithFormat:@"%@",([resultDic objectForKey:@"payOrderId"] ? [resultDic objectForKey:@"payOrderId"] : @"")];
        
        _loanDic = [NSDictionary dictionaryWithDictionary:([resultDic objectForKey:@"loan"] ? [resultDic objectForKey:@"loan"]:[NSDictionary dictionary])];
        
        [weakSelf initData];
        
        WS(weakSelf);
        NSString *payCount = @"0.00";
        //        if (_loanDic && _loanDic[@"installments"]
        //            && ![_loanDic[@"installments"] isKindOfClass:[NSNull class]]) {
        //
        //            NSArray *datasArray = [NSArray array];
        //            @try {
        //                datasArray = _loanDic[@"installments"];
        //            } @catch (NSException *exception) {
        //                SHLog(@"%@", exception.description);
        //            } @finally {
        //                if (datasArray.count>_financeSelectIndexPath.row) {
        //                    NSDictionary *dict = datasArray[_financeSelectIndexPath.row];
        //                    payCount = [NSString stringWithFormat:@"%@", dict[@"cost"]];
        //                }
        //            }
        //        } else {
        payCount = _amount;
        //        }
        
        [_payView updateButtonWithAmount:payCount
                                  enable:[self getPayButtonEnableStatus]];
        
        [weakSelf requestData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
    }];
}

- (NSString *)getErrorMessage:(NSError *)error {
    NSString *msg = @"网络错误, 请稍后重试!";
    @try {
        NSData *data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *err = nil;
        NSDictionary * errorDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        if (err == nil && errorDict && [errorDict objectForKey:@"msg"]) {
            msg = [errorDict objectForKey:@"msg"];
        }
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    } @finally {
        return msg;
    }
}

- (void)requestForTopOverSuccess:(NSString *)message
{
    NSArray *datasArray = [NSArray array];
    
    if (_loanDic && _loanDic[@"installments"]
        && ![_loanDic[@"installments"] isKindOfClass:[NSNull class]]) {
        
        datasArray = _loanDic[@"installments"];
    }
    WS(weakSelf)
    [MGJRouter openURL:@"hiddenFinance" completion:^(id result) {
        NSString *res = [NSString stringWithFormat:@"%@", result];
        BOOL hiddenFinance = [res isEqualToString:@"1"];
        weakSelf.arrayDS = [ESPayTimesModel createEnterprisePayCells:_payTimesType == ESPayTimesTypeFirst
                                                         partPayment:_partPayment
                                                          hasFinance:(datasArray.count>0 && (!hiddenFinance))
                                                              amount:_amount
                                                             message:message];
        [_payView tableViewReload];
    }];
    
    
}

#pragma mark - ESPayTimesViewDelegate
- (NSInteger)getPayViewRowsWithSection:(NSInteger)section
{
    return _arrayDS.count;
}

- (NSArray *)getRegCellNames
{
    return [ESPayTimesModel getPayTimesCellIds];
}

- (NSString *)getCellIdWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _arrayDS.count)
    {
        NSDictionary *dic = _arrayDS[indexPath.row];
        if (dic
            && [dic isKindOfClass:[NSDictionary class]])
        {
            return dic[@"cellId"];
        }
    }
    return nil;
}

- (void)payButtonDidTapped
{
    SHLog(@"支付按钮被点击");
    ESPayWay payWay = [ESPayTimesModel getPayWayWithDataSource:_arrayDS];
    if (payWay == ESpayWayFinance && [[JRKeychain loadSingleUserInfo:UserInfoCodePhone] isEqualToString:@""]) {
        [MGJRouter openURL:@"/Person/AccountSetting"];
        return;
    }
    if (payWay == ESpayWayFinance) {
        [self financePayWay];
        return;
    }
    [self factPay];
}

- (void)financePayWay {
    NSString *statusName = @"";
    NSString *validLimitName = @"";
    if (_loanDic) {
        NSString *status = _loanDic[@"status"];
        if ((![status isKindOfClass:[NSString class]]) || status == nil || [status isEqualToString:@""]) {
            statusName = @"开通";
        } else if ([status isEqualToString:@"SQZT_TG"] || [status isEqualToString:@"YSJHZT_00"]) {
            statusName = @"激活";
        }
        
        if (![_loanDic[@"validLimit"] isKindOfClass:[NSNull class]]) {
            validLimitName = [NSString stringWithFormat:@"%@", _loanDic[@"validLimit"]];
        }
    }
    
    if ([statusName isEqualToString:@""] || validLimitName.length>0) {
        [self factPay];
        return;
    }
    NSString *title = [NSString stringWithFormat:@"您还暂未%@居然分期付，确定要%@吗？", statusName, statusName];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    WS(weakSelf)
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [weakSelf jumpFinance];
                                                   }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:action];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)factPay {
    ESPayWay payWay = [ESPayTimesModel getPayWayWithDataSource:_arrayDS];
    NSString *payWayString = [ESPayTimesModel getPayWayString:payWay];
    NSDictionary *analysisDic = @{@"支付方式" : payWayString,
                                  @"支付金额" : _payAmount,
                                  @"支付订单号" : _payOrderId
                                  };
    [UMengServices eventWithEventId:Event_pay_order attributes:analysisDic];
    
    WS(weakSelf);
    NSString *rateId = @"";
    if (payWay == ESpayWayFinance && _loanDic && _loanDic[@"installments"]
        && ![_loanDic[@"installments"] isKindOfClass:[NSNull class]]) {
        
        NSArray *datasArray = [NSArray array];
        @try {
            datasArray = _loanDic[@"installments"];
        } @catch (NSException *exception) {
            SHLog(@"%@", exception.description);
        } @finally {
            if (datasArray.count>_financeSelectIndexPath.row) {
                NSDictionary *dict = datasArray[_financeSelectIndexPath.row];
                rateId = [NSString stringWithFormat:@"%@", dict[@"rateId"]];
            }
        }
    }
    [MBProgressHUD showHUDAddedTo:_payView animated:YES];
    __weak UIView *weakView = _payView;
    [ESPayTimesModel payForWithOrderId:_payOrderId
                                rateId:rateId
                                payWay:payWay
                             payAmount:_payAmount
            createOrderSuccessCallback:^(NSDictionary *dict)
     {
         [MBProgressHUD hideHUDForView:weakView animated:YES];
         
         if(payWay == ESpayWayUPA && dict){
             SHLog(@"dict:%@",dict);
             NSString *payMessage = dict[@"data"];
             [ESUPAServices upaPayWithPayInfo:payMessage viewController:weakSelf block:^(BOOL sucess, NSString *message) {
                 [weakSelf payForResult:sucess message:message];
             }];
         }
     } success:^(BOOL success, NSString *tipMessage){
         
         [weakSelf payForResult:success message:tipMessage];
         SHLog(@"成功:%@", tipMessage);
     } failure:^(NSString *errorMessage) {
         
         [MBProgressHUD hideHUDForView:weakView animated:YES];
         [weakSelf showHudWithMessage:errorMessage
                       hideAfterDelay:1.2];
         SHLog(@"失败:%@", errorMessage);
     }];
}
- (void)jumpFinance {
    NSMutableDictionary *pluginDict = [NSMutableDictionary dictionary];
    [pluginDict setObject:[NSString stringWithFormat:@"%@", _loanDic[@"prodId"]] forKey:@"prodId"];
    [pluginDict setObject:[NSString stringWithFormat:@"%@", _loanDic[@"status"]] forKey:@"status"];
    [pluginDict setObject:@"EDTZ" forKey:@"entrance"];
    NSString *appType = [JRNetEnvConfig sharedInstance].netEnvModel.appType;
    if ([appType isEqualToString:@"MALL"]) {
        [pluginDict setObject:@"mall" forKey:@"appType"];
    } else if ([appType isEqualToString:@"CONSUMER"]) {
        [pluginDict setObject:@"proprietor" forKey:@"appType"];
    } else {
        [pluginDict setObject:@"designer" forKey:@"appType"];
    }
    WS(weakSelf)
    [[ESFinanceServices sharedInstance] jumpToFinanceViewcontrollerWithInfo:pluginDict block:^(NSDictionary *resultDic) {
        SHLog(@"%@", resultDic);
        NSString *suc = [NSString stringWithFormat:@"%@", resultDic[@"errCode"]?resultDic[@"errCode"]:@""];
        if ([suc isEqualToString:@"000000"]) {
        } else {
            NSString *errmsg = [NSString stringWithFormat:@"%@", resultDic[@"errMsg"]?resultDic[@"errMsg"]:@""];
            [MBProgressHUD showError:errmsg];
        }
        [weakSelf goPayWithOrderId:_actOrderId brandId:_brandId];
    }];
}

- (void)paySuccess
{
    [UMengServices eventWithEventId:Event_pay_success];
    ESPaySucessViewController *paySucessViewCon = [[ESPaySucessViewController alloc] init];
    [paySucessViewCon setOrderId:_payOrderId money:_payAmount];
    if (_payType == ESPayTypeEnterprise) {
        paySucessViewCon.type = ESPaySucessTypeEnterprise;
    } else if (_payType == ESPayTypePkgProjectList) {
        paySucessViewCon.type = ESPaySucessTypePkgProjectList;
    } else if (_payType == ESPayTypePkgProjectDetail) {
        paySucessViewCon.type = ESPaySucessTypePkgProjectDetail;
    } else {
        paySucessViewCon.type = ESPaySucessTypeDefault;
    }
    [self.navigationController pushViewController:paySucessViewCon
                                         animated:YES];
}

- (void)payForResult:(BOOL)success message:(NSString *)message  {
    if (success) {
        [self paySuccess];
    } else {
        ESPayWay payWay = [ESPayTimesModel getPayWayWithDataSource:_arrayDS];
        if (payWay == ESpayWayFinance) {
            [self goPayWithOrderId:_actOrderId brandId:_brandId];
        }
        [self showHudWithMessage:message
                  hideAfterDelay:3.0];
    }
}

#pragma mark - ESPayAmountCellDelegate
- (NSDictionary *)getPayAmountDataWithIndexPath:(NSIndexPath *)indexPath
{
    // amount title
    return [self getDataWithIndexPath:indexPath];
}

#pragma mark - ESPaySwitchCellDelegate
- (NSDictionary *)getPaySwitchDataWithIndexPath:(NSIndexPath *)indexPath
{
    // switchOn
    return [self getDataWithIndexPath:indexPath];
}

- (void)switchValueDidChanged:(BOOL)switchOn
                    indexPath:(NSIndexPath *)indexPath
{
    if (switchOn
        && _payTimesType == ESPayTimesTypeFirst)
    {
        [self showHudWithMessage:@"为避免交易关闭，建议首笔支付大于1元" hideAfterDelay:1.8f];
    }
    
    NSMutableDictionary *dict = [self getDataWithIndexPath:indexPath];
    if (dict
        && [dict isKindOfClass:[NSDictionary class]])
    {
        [dict setObject:@(switchOn) forKey:@"switchOn"];
    }
    // 更新数据源
    [ESPayTimesModel updateDataSourceWithSwitchStatus:switchOn
                                                   ds:_arrayDS];
    
    if (!switchOn)
    {
        [_payView updateButtonWithAmount:_amount
                                  enable:[self getPayButtonEnableStatus]];
        _payAmount = _amount;
    }
    // 更新tableView
    [_payView tableviewShowTextInputWithIndexPath:indexPath
                                       showStatus:switchOn];
}

#pragma mark - ESPayTextInputCellDelegate
- (NSDictionary *)getPayTextInputDataWithIndexPath:(NSIndexPath *)indexPath
{
    // payAmount
    return [self getDataWithIndexPath:indexPath];
}

- (void)payAmountTextFieldDidEndEditing:(NSString *)text
                              indexPath:(NSIndexPath *)indexPath
{
    if (text.length <= 0
        || [text floatValue] <= 0.0f
        || [text floatValue] > [_amount floatValue])
    {
        text = _amount;
    }
    else
    {
        text = [NSString stringWithFormat:@"%.2lf", [text floatValue]];
    }
    
    NSMutableDictionary *dict = [self getDataWithIndexPath:indexPath];
    if (dict
        && [dict isKindOfClass:[NSDictionary class]])
    {
        [dict setObject:text forKey:@"payAmount"];
    }
    
    _payAmount = text;
    [_payView tableViewReload];
    [_payView updateButtonWithAmount:text
                              enable:[self getPayButtonEnableStatus]];
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    // 删除键
    if ([string isEqualToString:@""]
        && [string integerValue] == 0)
    {
        return YES;
    }
    
    // 判断是否有小数点
    if ([textField.text containsString:@"."])
    {
        _hasDian = YES;
    }
    else
    {
        _hasDian = NO;
    }
    
    if (string.length > 0)
    {
        //当前输入的字符
        unichar single = [string characterAtIndex:0];
        
        // 不能输入.0-9以外的字符
        if (!((single >= '0' && single <= '9') || single == '.'))
        {
            return NO;
        }
        
        // 只能有一个小数点
        if (_hasDian && single == '.')
        {
            return NO;
        }
        
        // 如果第一位是.则前面加上0.
        if ((textField.text.length == 0) && (single == '.'))
        {
            textField.text = @"0";
        }
        
        // 如果第一位是0则后面必须输入点，否则不能输入。
        if ([textField.text hasPrefix:@"0"])
        {
            if (textField.text.length > 1)
            {
                NSString *secondStr = [textField.text substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."])
                {
                    return NO;
                }
            }
            else
            {
                if (![string isEqualToString:@"."])
                {
                    return NO;
                }
            }
        }
        
        // 小数点后最多能输入两位
        if (_hasDian)
        {
            NSRange ran = [textField.text rangeOfString:@"."];
            if (range.location > ran.location)
            {
                if ([textField.text pathExtension].length > 1)
                {
                    return NO;
                }
            }
        }
    }
    return YES;
}

#pragma mark - ESPayTipCellDelegate
- (NSDictionary *)getPayTipMessageWithIndexPath:(NSIndexPath *)indexPath
{
    // message
    return [self getDataWithIndexPath:indexPath];
}

#pragma mark - ESPayWayTitleCellDelegate
- (NSDictionary *)getPayWayTitleWithIndexPath:(NSIndexPath *)indexPath
{
    // title
    return [self getDataWithIndexPath:indexPath];
}

#pragma mark - ESPayWayCellDelegate
- (NSDictionary *)getPayDataWithIndexPath:(NSIndexPath *)indexPath
{
    // icon title selected
    return [self getDataWithIndexPath:indexPath];
}

- (void)paySelectedDidTapped:(NSIndexPath *)indexPath
                       title:(NSString *)title
{
    SHLog(@"选择支付方式被点击");
    [ESPayTimesModel updatePayWayWithDataSource:_arrayDS
                                      indexPath:indexPath
                                          title:title];
    _payWayTitle = title;
    [_payView tableViewReload];
    if ([title isEqualToString:@"居然分期付"]) {
        [_payView updateButtonWithAmount:_amount
                                  enable:[self getPayButtonEnableStatus]];
        _payAmount = _amount;
    }
    
}

- (NSString *)getFinanceStatusName {
    NSString *payCount = @"可用额度 0.00";
    NSString *tempstatusName = _loanDic[@"limitAmountInfo"];
    if (_loanDic && tempstatusName
        && [tempstatusName isKindOfClass:[NSString class]]) {
        payCount = [NSString stringWithFormat:@"%@", tempstatusName?tempstatusName:@"可用额度 0.00"];
    }
    return payCount;
}
#pragma mark - ESPayWayFinanceCellDelegate
- (NSDictionary *)getFinanceData {
    if ([_payWayTitle isEqualToString:@"居然分期付"]) {
        return _loanDic;
    } else {
        return [NSDictionary dictionary];
    }
    
}
- (NSIndexPath *)getSelectIndexPath {
    return [NSIndexPath indexPathForRow:_financeSelectIndexPath.row inSection:_financeSelectIndexPath.section];
}
- (void)financeSelectedDidTapped:(NSIndexPath *)indexPath {
    _financeSelectIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    WS(weakSelf);
    NSString *payCount = @"0.00";
    //    if (_loanDic && _loanDic[@"installments"]
    //        && ![_loanDic[@"installments"] isKindOfClass:[NSNull class]]) {
    //
    //        NSArray *datasArray = [NSArray array];
    //        @try {
    //            datasArray = _loanDic[@"installments"];
    //        } @catch (NSException *exception) {
    //            SHLog(@"%@", exception.description);
    //        } @finally {
    //            if (datasArray.count>_financeSelectIndexPath.row) {
    //                NSDictionary *dict = datasArray[_financeSelectIndexPath.row];
    //                payCount = [NSString stringWithFormat:@"%@", dict[@"cost"]];
    //            }
    //        }
    //    } else {
    payCount = _amount;
    //    }
    
    [_payView updateButtonWithAmount:payCount
                              enable:[self getPayButtonEnableStatus]];
    _payAmount = payCount;
}

#pragma mark - ESPayEnterpriseAgreementCellDelegate
- (NSDictionary *)getPayEnterpriseDataWithIndexPath:(NSIndexPath *)indexPath
{
    // selected
    return [self getDataWithIndexPath:indexPath];
}

- (void)agreeButtonDidTapped:(BOOL)selected
                    indexPth:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [self getDataWithIndexPath:indexPath];
    if (dict
        && [dict isKindOfClass:[NSDictionary class]])
    {
        [dict setObject:@(selected) forKey:@"selected"];
    }
    
    [_payView updateButtonWithAmount:nil
                              enable:selected];
}

- (void)agreementButtonDidTapped
{
    [SHAlertView showAlertWithMessage:@"施工项目细则"
                              sureKey:nil];
}

#pragma mark - Methods
- (NSMutableDictionary *)getDataWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath
        && [_arrayDS isKindOfClass:[NSArray class]]
        && indexPath.row < _arrayDS.count)
    {
        return _arrayDS[indexPath.row];
    }
    
    return nil;
}

- (BOOL)getPayButtonEnableStatus
{
    if (_payType == ESPayTypeMaterial || _payType == ESPayTypePkgProjectList || _payType == ESPayTypePkgProjectDetail)
    {
        return YES;
    }
    else if (_payType == ESPayTypeEnterprise)
    {
        return [ESPayTimesModel getEnterpriseAgreementStatusWithDataSource:_arrayDS];
    }
    
    return NO;
}

- (void)showHudWithMessage:(NSString *)message
            hideAfterDelay:(NSTimeInterval)afterDelay
{
    if (!message
        || ![message isKindOfClass:[NSString class]])
    {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.bezelView.alpha = 0.5;
    [hud hideAnimated:YES afterDelay:afterDelay];
}

#pragma mark - Super Method
- (void)tapOnLeftButton:(id)sender
{
    if (_payType == ESPayTypeMaterial)
    {
        ESMyOrderViewController *myOrderViewCon = [[ESMyOrderViewController alloc] init];
        [self.navigationController pushViewController:myOrderViewCon animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tapOnRightButton:(id)sender
{
    [ESPayAlertView showPayAlertView];
}

@end
