//
//  ESEditAddressController.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESEditAddressController.h"
#import "ESEditAddressView.h"
#import "ESEditAddressViewModel.h"
#import "MBProgressHUD.h"
#import "ESAddressPickerView.h"

#import "ESAddrerssAPI.h"

@interface ESEditAddressController ()<ESEditAddressViewDelegate, ESAddressPickerViewDelegate>
@property (nonatomic, strong) ESEditAddressView *mainView;
@property (nonatomic, strong) ESAddress *editAddress;
@property (nonatomic, strong) ESAddressPickerView *pickerView;
@property (nonatomic, strong) NSMutableDictionary *currentAddrInfo;

@end

@implementation ESEditAddressController
{
    NSString *_title;
}
- (instancetype)initWithAddress:(ESAddress *)address {
    self = [super init];
    if (self) {
        if (address) {
            self.editAddress = address;
            _title = @"编辑收货地址";
        }else {
            _title = @"添加收货地址";
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleLabel.text = _title;
    self.rightButton.hidden = YES;
    self.currentAddrInfo = [ESEditAddressViewModel getInfoFromAddress:self.editAddress];
    
    self.mainView = [[[ESMallAssets hostBundle] loadNibNamed:@"ESEditAddressView" owner:nil options:nil] firstObject];
    self.mainView.frame = CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT);
    self.mainView.delegate = self;
    [self.view addSubview:self.mainView];
    [self.mainView updateEditView];
    
    self.pickerView = [ESAddressPickerView addressPickerViewWithDelegate:self];
}

#pragma mark - Override
- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ESEditAddressViewDelegate
- (NSString *)getAddressName {
    return [ESEditAddressViewModel getAddressName:self.currentAddrInfo];
}

- (NSString *)getAddressPhone {
    return [ESEditAddressViewModel getAddressPhone:self.currentAddrInfo];
}

- (NSString *)getLocation {
    return [ESEditAddressViewModel getLocation:self.currentAddrInfo];
}

- (NSString *)getAddressDetail {
    return [ESEditAddressViewModel getAddressDetail:self.currentAddrInfo];
}

/**
 点击保存
 
 地址信息的字典
 */
- (void)saveAddress {
    self.mainView.userInteractionEnabled = NO;
    
    NSString *error = [ESEditAddressViewModel checkInputWithDict:self.currentAddrInfo];
    if (error ) {
        [self showSuccessHUD:error];
        self.mainView.userInteractionEnabled = YES;
        return;
    }

    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.mainView animated:YES];
    [ESEditAddressViewModel saveAddress:self.currentAddrInfo withAddress:self.editAddress withSuccess:^(NSString *successMsg){
        
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        [weakSelf showSuccessHUD:successMsg];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
        
    } andFailure:^(NSString *errorMsg){
        [MBProgressHUD hideHUDForView:weakSelf.mainView animated:YES];
        NSString *str = errorMsg ? errorMsg : @"保存失败, 请稍后重试!";
        [weakSelf showSuccessHUD:str];
        weakSelf.mainView.userInteractionEnabled = YES;
    }];
}

- (void)tapSelectAddress {
    [self.mainView endEditing:YES];
    NSString *provinceCode = nil;
    NSString *cityCode = nil;
    NSString *districtCode = nil;
    
    if ([self.currentAddrInfo objectForKey:@"provinceCode"]) {
        provinceCode = [self.currentAddrInfo objectForKey:@"provinceCode"];
    }
    if ([self.currentAddrInfo objectForKey:@"cityCode"]) {
        cityCode = [self.currentAddrInfo objectForKey:@"cityCode"];
    }
    if ([self.currentAddrInfo objectForKey:@"districtCode"]) {
        districtCode = [self.currentAddrInfo objectForKey:@"districtCode"];
    }
    
    [self.pickerView showAddrPickerWithProvinceCode:provinceCode withCityCode:cityCode andDistrictCode:districtCode];
}

- (void)textFieldEndEditing:(NSMutableDictionary *)info {
    self.currentAddrInfo = [ESEditAddressViewModel updateAddressInfoWithDict:info withCurrentInfo:self.currentAddrInfo];
}

- (void)textFieldBeginEditing {
    [self.pickerView hiddenAddrPicker];
}

#pragma mark - ESAddressPickerViewDelegate
- (void)confirmAddressWithDict:(NSDictionary *)dict {
    self.currentAddrInfo = [ESEditAddressViewModel updateAddressInfoWithDict:dict withCurrentInfo:self.currentAddrInfo];
    [self.mainView updateEditView];
}

#pragma mark - Custom Method
- (void)showSuccessHUD:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
//    hud.labelText = message;
    hud.label.text = message;
    hud.margin = 30.f;
//    hud.yOffset = 0;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
//    [hud hide:YES afterDelay:1.5];
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
