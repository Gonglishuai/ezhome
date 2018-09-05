
#import "ESCreateEnterpriseViewController.h"
#import "ESCreateEnterpriseView.h"
#import "ESCreateEnterpriseModel.h"
#import "MPAddressSelectedView.h"
#import "MPRegionManager.h"
#import "MPPickerView.h"
#import "MBProgressHUD.h"
#import "ESEnterpriseAlertView.h"
#import <ESNetworking/SHAlertView.h>

@interface ESCreateEnterpriseViewController ()<ESCreateEnterpriseViewDelegate, MPAddressSelectedDelegate>

@end

@implementation ESCreateEnterpriseViewController
{
    NSDictionary *_memberInfoDict;
    ESCreateEnterpriseView *_enterpriseView;
    NSArray *_arrayDS;
    MPAddressSelectedView *_pickView;
    UIView *_pickBackgroundView;
    MPPickerView *_picker;
    NSArray *_decorations;
    UIView *_hudView;
}

- (instancetype)initWithMemberinfo:(NSDictionary *)memberDict
{
    self = [super init];
    if (self)
    {
        if (memberDict
            && [memberDict isKindOfClass:[NSDictionary class]])
        {
            _memberInfoDict = memberDict;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
    
    [self requestData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)initData
{
    _arrayDS = [ESCreateEnterpriseModel getCreateEnterpriseItemsWithMemberInfo:_memberInfoDict];
}

- (void)initUI
{
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"填写项目信息";
    
    CGRect rect = CGRectMake(
                             0,
                             NAVBAR_HEIGHT,
                             SCREEN_WIDTH,
                             SCREEN_HEIGHT - NAVBAR_HEIGHT
                             );
    _enterpriseView = [[ESCreateEnterpriseView alloc] initWithFrame:rect];
    _enterpriseView.viewDelegate = self;
    [self.view addSubview:_enterpriseView];
    
    
    _pickBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_pickBackgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(hideAllPicker)]];
    _pickBackgroundView.alpha = 0.0f;
    _pickBackgroundView.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:_pickBackgroundView atIndex:0];
    
    _hudView = [[UIView alloc] initWithFrame:CGRectMake(
                                                       0,
                                                       NAVBAR_HEIGHT,
                                                       SCREEN_WIDTH,
                                                       SCREEN_HEIGHT - NAVBAR_HEIGHT * 2
                                                        )];
    _hudView.hidden = YES;
    [self.view addSubview:_hudView];
}

- (void)requestData
{
    _hudView.hidden = NO;
    [MBProgressHUD showHUDAddedTo:_hudView animated:YES];
    __weak UIView *weakHudView = _hudView;
    [ESCreateEnterpriseModel getDecorationsSuccess:^(NSArray<ESEnterpriseDecorationModel *> *array) {
        [MBProgressHUD hideHUDForView:weakHudView animated:YES];
        weakHudView.hidden = YES;
        _decorations = array;
    } failure:^(NSError *error) {
        SHLog(@"创建施工订单请求装饰公司失败:%@", error.localizedDescription);
        weakHudView.hidden = YES;
        [MBProgressHUD hideHUDForView:weakHudView animated:YES];
    }];
}

#pragma mark - ESCreateEnterpriseViewDelegate
- (NSInteger)getEnterpriseTableSection
{
    return _arrayDS.count;
}

- (NSInteger)getEnterpriseTableRowsWithSection:(NSInteger)section
{
    if (_arrayDS.count > section)
    {
        NSArray *arr = _arrayDS[section];
        return arr.count;
    }
    
    return 0;
}

- (CGFloat)getEnterpriseTableRowHeight:(NSIndexPath *)indexPath
{
    if (indexPath.section < _arrayDS.count
        && indexPath.row < [(NSArray *)_arrayDS[indexPath.section] count])
    {
        NSDictionary *dic = _arrayDS[indexPath.section][indexPath.row];
        CGFloat rowHeight = [dic[@"height"] floatValue];
        return rowHeight;
    }
    
    return 0.0f;
}

- (NSString *)getItemTypeWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _arrayDS.count
        && indexPath.row < [(NSArray *)_arrayDS[indexPath.section] count])
    {
        NSDictionary *dic = _arrayDS[indexPath.section][indexPath.row];
        NSString *type = dic[@"type"];
        return type;
    }
    
    return nil;
}

- (void)completeButtonDidTapped
{
    [self.view endEditing:YES];
    
    NSString *checkResult = [ESCreateEnterpriseModel checkDataCompleted:_arrayDS];
    if (checkResult)
    {
        [SHAlertView showAlertWithMessage:checkResult sureKey:nil];
    }
    else
    {
        [self createEnterpriseOrder];
    }
}

#pragma mark - ESCreateButtonCellDelegate
- (NSDictionary *)getButtonCellDisplayMessageWith:(NSIndexPath *)indexPath
{
    if (indexPath.section < _arrayDS.count
        && indexPath.row < [(NSArray *)_arrayDS[indexPath.section] count])
    {
        NSDictionary *dic = _arrayDS[indexPath.section][indexPath.row];
        return dic;
    }
    
    return nil;
}

- (void)messageButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    if (indexPath.section < _arrayDS.count
        && indexPath.row < [(NSArray *)_arrayDS[indexPath.section] count])
    {
        NSDictionary *dic = _arrayDS[indexPath.section][indexPath.row];
        if ([dic[@"key"] isKindOfClass:[NSString class]])
        {
            if ([dic[@"key"] isEqualToString:@"decorationCompany"])
            {
                [self showDecorations];
            }
            else if ([dic[@"key"] isEqualToString:@"address"])
            {
                [self showMyPicker];
            }
        }
    }
}

#pragma mark - ESCreateTextFieldCellDelegate
- (NSDictionary *)getTextFieldCellDisplayInformationWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _arrayDS.count
        && indexPath.row < [(NSArray *)_arrayDS[indexPath.section] count])
    {
        NSDictionary *dic = _arrayDS[indexPath.section][indexPath.row];
        return dic;
    }
    
    return nil;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
                        indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _arrayDS.count
        && indexPath.row < [(NSArray *)_arrayDS[indexPath.section] count])
    {
        NSMutableDictionary *dic = _arrayDS[indexPath.section][indexPath.row];
        [dic setObject:textField.text forKey:@"message"];
    }
    
    return YES;
}

- (BOOL)                textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
                        indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _arrayDS.count
        && indexPath.row < [(NSArray *)_arrayDS[indexPath.section] count])
    {
        NSDictionary *dic = _arrayDS[indexPath.section][indexPath.row];
        if ([dic[@"key"] isKindOfClass:[NSString class]])
        {
            if ([dic[@"key"] isEqualToString:@"phoneNum"])
            {
                if (textField.text.length == 11)
                {
                    if ([string isEqualToString:@""]
                        && [string integerValue] == 0)
                    {
                        return YES;
                    }
                    return NO;
                }
            }
            else
            {
                // 此处添加其他输入框的校验
    
            }
        }
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
                    indexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Methods  Network
- (void)createEnterpriseOrder
{
    _hudView.hidden = NO;
    [MBProgressHUD showHUDAddedTo:_hudView animated:YES];
    __weak UIView *weakHudView = _hudView;
    __weak ESCreateEnterpriseViewController *weakSelf = self;
    [ESCreateEnterpriseModel createEnterpriseWithData:_arrayDS
                                           memberInfo:_memberInfoDict
                                              success:^(NSDictionary *dict)
    {
        SHLog(@"%@", dict);

        [MBProgressHUD hideHUDForView:weakHudView animated:YES];
        weakHudView.hidden = YES;
        
        [ESEnterpriseAlertView showAlertWithType:ESEnterpriseAlertTypeSuccess
                                        callback:^(ESEnterpriseAlertType type)
        {
            [weakSelf tapOnLeftButton:nil];
        }];
        
    } failure:^(NSError *error) {
        
        SHLog(@"%@", error.localizedDescription);

        [MBProgressHUD hideHUDForView:weakHudView animated:YES];
        weakHudView.hidden = YES;

        [ESEnterpriseAlertView showAlertWithType:ESEnterpriseAlertTypeFailure
                                        callback:nil];
    }];
}

#pragma mark - Super Method
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - Picker
- (void)showMyPicker
{
    if (_pickView==nil)
    {
        _pickView = [[MPAddressSelectedView alloc] initPickview:@"请选择地址"];
        _pickView.frame = CGRectMake(
                                     0,
                                     SCREEN_HEIGHT+_pickView.frame.size.height,
                                     SCREEN_WIDTH,
                                     _pickView.frame.size.height
                                     );
    }
    
    _pickView.delegate = self;
    [_pickView showInView:self.view];
    
    _pickBackgroundView.alpha = 0.0f;
    [self.view bringSubviewToFront:_pickBackgroundView];
    [self.view bringSubviewToFront:_pickView];
    [UIView animateWithDuration:0.3 animations:^{
        _pickView.frame = CGRectMake(
                                     0,
                                     SCREEN_HEIGHT-_pickView.frame.size.height,
                                     SCREEN_WIDTH,
                                     _pickView.frame.size.height
                                     );
        _pickBackgroundView.alpha = 0.5f;
    }];
}

- (void)hideMyPicker
{
    [UIView animateWithDuration:0.3 animations:^{
        
        _pickView.frame = CGRectMake(
                                     0,
                                     SCREEN_HEIGHT+_pickView.frame.size.height,
                                     SCREEN_WIDTH,
                                     _pickView.frame.size.height
                                     );
        _pickBackgroundView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [_pickView removeFromSuperview];
        _pickView = nil;
        
    }];
}

- (void)hideAllPicker
{
    if (_picker)
    {
        [self hidePicker];
    }
    else
    {
        [self hideMyPicker];
    }
}

#pragma mark - MPPickerView
- (void)showDecorations
{
    WS(weakSelf);
    [_picker removeFromSuperview];
    
    _pickBackgroundView.alpha = 0.0f;
    [self.view bringSubviewToFront:_pickBackgroundView];
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (ESEnterpriseDecorationModel *model in _decorations)
    {
        if ([model isKindOfClass:[ESEnterpriseDecorationModel class]]
            && [model.showName isKindOfClass:[NSString class]])
        {
            [arrM addObject:model.showName];
        }
    }
    _picker = [[MPPickerView alloc] initWithFrame:CGRectMake(
                                                             0,
                                                             CGRectGetHeight(self.view.frame),
                                                             CGRectGetWidth(self.view.frame),
                                                             220)
                                            title:@"装饰公司"
                                  arrayDataSource:[arrM copy]
                                           finish:^(NSDictionary *dict)
    {
        if (dict)
        {
            [weakSelf getPickerInfoInPickerInfo:dict];
        }
        [weakSelf hidePicker];
    }];
    [self.view addSubview:_picker];
    [self showPicker];
}

- (void)getPickerInfoInPickerInfo:(NSDictionary *)dict
{
    NSString *decoration = dict[@"comp1"];
    if (decoration
        && [decoration isKindOfClass:[NSString class]]
        && decoration.length > 0)
    {
        NSString *code = [ESEnterpriseDecorationModel getCodeWithKey:decoration
                                                          dataSource:_decorations];
        SHLog(@"%@: %@", decoration, code);
        
        NSMutableDictionary *dict = [ESCreateEnterpriseModel
                                     getCheckValueWithKey:@"decorationCompany"
                                     data:_arrayDS];
        if (dict)
        {
            [dict setObject:decoration forKey:@"message"];
            [dict setObject:code forKey:@"decorationCompany"];
        }
        
        [_enterpriseView tableViewReload];
    }
}

- (void)showPicker
{
    [UIView animateWithDuration:0.3 animations:^{
        _picker.frame = CGRectMake(
                                   0,
                                   CGRectGetHeight(self.view.frame) - 220,
                                   CGRectGetWidth(self.view.frame),
                                   220
                                   );
        _pickBackgroundView.alpha = 0.5f;
    }];
}

- (void)hidePicker
{
    __weak ESCreateEnterpriseViewController *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        _picker.frame = CGRectMake(
                                     0,
                                     weakSelf.view.frame.size.height,
                                     0,
                                     0
                                     );
        _pickBackgroundView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [_picker removeFromSuperview];
        _picker = nil;
    }];
}

#pragma mark MPAddressSelectedDelegate
- (void)selectedAddressinitWithProvince:(NSString *)province withCity:(NSString *)city withTown:(NSString *)town isCertain:(BOOL)isCertain {
    
    [self hideMyPicker];
    if (isCertain)
    {
        NSDictionary *addressDict = [[MPRegionManager sharedInstance] getRegionWithProvinceCode:province withCityCode:city andDistrictCode:town];
        
        NSString *resultString = [NSString stringWithFormat:@"%@ %@ %@",addressDict[@"province"],addressDict[@"city"],addressDict[@"district"]];
        
        NSMutableDictionary *dict = [ESCreateEnterpriseModel getCheckValueWithKey:@"address" data:_arrayDS];
        if (dict)
        {
            [dict setObject:resultString forKey:@"message"];
            NSMutableDictionary *addressDictM = [NSMutableDictionary dictionary];
            if (province
                && [province isKindOfClass:[NSString class]]
                && city
                && [city isKindOfClass:[NSString class]]
                && town
                && [town isKindOfClass:[NSString class]]
                && addressDict[@"province"]
                && [addressDict[@"province"] isKindOfClass:[NSString class]]
                && addressDict[@"city"]
                && [addressDict[@"city"] isKindOfClass:[NSString class]]
                && addressDict[@"district"]
                && [addressDict[@"district"] isKindOfClass:[NSString class]])
            {
                [addressDictM setObject:province
                                 forKey:@"provinceCode"];
                [addressDictM setObject:city
                                 forKey:@"cityCode"];
                [addressDictM setObject:town
                                 forKey:@"districtCode"];
                [addressDictM setObject:addressDict[@"province"]
                                 forKey:@"provinceName"];
                [addressDictM setObject:addressDict[@"city"]
                                 forKey:@"cityName"];
                [addressDictM setObject:addressDict[@"district"]
                                 forKey:@"districtName"];
            }
            [dict setObject:addressDictM forKey:@"address"];
        }
        
        [_enterpriseView tableViewReload];
    }
}

@end
