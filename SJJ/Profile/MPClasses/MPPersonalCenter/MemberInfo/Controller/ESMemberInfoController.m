//
//  ESMemberInfoController.m
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMemberInfoController.h"
#import "ESMemberInfoView.h"
#import "ESMemberInfoData.h"
#import "ESMemberInfoViewModel.h"
#import <Masonry.h>
#import <MBProgressHUD.h>
#import "MPAddressSelectedView.h"
#import "MPRegionManager.h"
#import "ESPhotoSelector.h"

@interface ESMemberInfoController ()<ESMemberInfoViewDelegate, MPAddressSelectedDelegate>
@property (nonatomic, strong) ESMemberInfoView *mainView;
@property (nonatomic, strong) NSMutableArray <ESMemberInfoViewModel *> *items;
@property (nonatomic, strong) ESMemberInfo *memberInfo;
@property (nonatomic, strong) MPAddressSelectedView *addressSelectedView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) ESPhotoSelector *photoSelector;


@end

@implementation ESMemberInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNav];
    
    self.items = [ESMemberInfoViewModel getDefaultConfig];
    self.mainView = [[ESMemberInfoView alloc] initWithDelegate:self];
    
    [self.view addSubview:self.mainView];
    
    __block UIView *b_view = self.view;
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(b_view.mas_leading);
        make.top.equalTo(b_view.mas_top).with.offset(NAVBAR_HEIGHT);
        make.trailing.equalTo(b_view.mas_trailing);
        make.bottom.equalTo(b_view.mas_bottom);
    }];
    
    [self requestData];
}

- (void)setUpNav {
    self.titleLabel.text = @"基本信息";
    [self.rightButton setTitle:@"保存" forState:UIControlStateNormal];
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    self.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.rightButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0f]];
    [self.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.rightButton sizeToFit];
    self.rightButton.enabled = NO;
}

- (void)requestData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESMemberInfoData getMemberInfoWithSuccess:^(ESMemberInfo *memberInfo) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.memberInfo = memberInfo;
        [weakSelf freshViewModel];
        [weakSelf.mainView refreshMainView];
    } andFailure:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

- (void)freshViewModel {
    [ESMemberInfoData getItemContentWithViewModel:self.items withMemberInfo:self.memberInfo];
}

- (MPAddressSelectedView *)addressSelectedView{
    if(_addressSelectedView == nil){
        self.addressSelectedView = [[MPAddressSelectedView alloc] initPickview:@"请选择地址"];
        self.addressSelectedView.delegate = self;
    }
    return _addressSelectedView;
}

- (UIView *)maskView{
    if(_maskView == nil){
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 1;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMaskView)]];
    }
    return _maskView;
}

- (void)uploadMemberHeader:(UIImage *)image {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESMemberInfoData updateMemberAvatar:image withSuccess:^(NSString *url){
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (weakSelf.memberInfo) {
            weakSelf.memberInfo.basic.avatar = url;
        }
        [weakSelf.mainView refreshMainView];
    } andFailure:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf showMessageHUD:@"上传失败, 请稍后重试!"];
    }];
}

#pragma mark - Override
- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapOnRightButton:(id)sender {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESMemberInfoData updateMemberInfo:self.memberInfo withSuccess:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf showMessageHUD:@"保存成功!"];
        [self.navigationController popViewControllerAnimated:YES];
    } andFailure:^(NSString *msg) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (msg) {
            [weakSelf showMessageHUD:msg];
        }
    }];
}

#pragma mark - ESMemberInfoViewDelegate

- (NSInteger)getItemNum {
    return self.items.count;
}

- (NSString *)getHeaderUrl {
    return [ESMemberInfoData getMemberAvatar:self.memberInfo];
}

- (void)uploadButtonClick {
    
    if (_photoSelector == nil) {
        _photoSelector = [[ESPhotoSelector alloc]init];
    }
    [_photoSelector selectPhoto:self];
    WS(weakSelf)
    _photoSelector.returnedPhotos = ^(NSArray<UIImage *> *photos) {
        
        [weakSelf uploadMemberHeader:[photos firstObject]];
    };
}

- (void)selectItem:(NSInteger)index {
    @try {
        ESMemberInfoViewModel *viewModel = [self.items objectAtIndex:index];
        if ([viewModel.key isEqualToString:@"region"]) {
            [self selectAddress];
            return;
        }
        if ([viewModel.key isEqualToString:@"sex"]) {
            [self selectSex];
            return;
        }
    } @catch (NSException *exception) {
        SHLog(@"选择条目异常：%@", exception.description);
    }
}

#pragma mark - ESMemberInfoCellDelegate
- (ESMemberInfoViewModel *)getInfoModel:(NSInteger)index {
    ESMemberInfoViewModel *viewModel;
    @try {
        viewModel = [self.items objectAtIndex:index];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        viewModel = [ESMemberInfoViewModel objFromDict:nil];
    } @finally {
        return viewModel;
    }
}

- (void)textFieldEditComplete:(UITextField *)textField withKey:(NSString *)key {
    self.rightButton.enabled = YES;
    for (ESMemberInfoViewModel *viewModel in self.items) {
        if ([viewModel.key isEqualToString:key]) {
            viewModel.content = textField.text;
        }
    }
    
    [ESMemberInfoData updateMemberNickName:self.memberInfo withItems:self.items];
}

- (void)textFieldEditBegin:(UITextField *)textField withKey:(NSString *)key {
    self.rightButton.enabled = NO;
}

#pragma mark MPAddressSelectedDelegate
- (void)selectedAddressinitWithProvince:(NSString *)province withCity:(NSString *)city withTown:(NSString *)town isCertain:(BOOL)isCertain {
    
    [self hideMaskView];
    if (isCertain) {
        [ESMemberInfoData updateRegionInfo:self.memberInfo withItems:self.items withProvinceCode:province withCityCode:city andDistrictCode:town];
        
        [self.mainView refreshMainView];
    }
    self.rightButton.enabled = YES;
}

#pragma mark - Private
- (void)showMessageHUD:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
}

- (void)selectAddress {
    self.rightButton.enabled = NO;
    [self showMyPicker];
    NSString *province = self.memberInfo.basic.province ? : @"";
    NSString *city = self.memberInfo.basic.city ? : @"";
    NSString *district = self.memberInfo.basic.district ? : @"";
    [self.addressSelectedView setPickerViewprovinceCode:province cityCode:city townCode:district];
    [self.addressSelectedView showInView:self.view];
}

- (void)showMyPicker {
    self.addressSelectedView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.addressSelectedView.frame.size.height);
    
    [self.view addSubview:self.maskView];
    [self.view bringSubviewToFront:self.maskView];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.4;
    [UIView animateWithDuration:0.3 animations:^{
        self.addressSelectedView.frame = CGRectMake(0, SCREEN_HEIGHT - self.addressSelectedView.frame.size.height, SCREEN_WIDTH, self.addressSelectedView.frame.size.height);
    }];
}

- (void)hideMaskView{
    self.maskView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        if(self.addressSelectedView != nil){
            self.addressSelectedView.frame = CGRectMake(0, SCREEN_HEIGHT - NAVBAR_HEIGHT +self.addressSelectedView.frame.size.height, SCREEN_WIDTH, self.addressSelectedView.frame.size.height);
        }
    } completion:^(BOOL finished) {
        @try {
            [self.maskView removeFromSuperview];
            [self.addressSelectedView removeFromSuperview];
        } @catch (NSException *exception) {
            
        } @finally {
            self.addressSelectedView = nil;
        }
    }];
}

- (void)selectSex {
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateSex:action.title];
    }];
    [alerVC addAction:takePhoto];
    
    UIAlertAction *pickPhoto = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateSex:action.title];
    }];
    [alerVC addAction:pickPhoto];
    
    UIAlertAction *secret = [UIAlertAction actionWithTitle:@"保密" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateSex:action.title];
    }];
    [alerVC addAction:secret];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alerVC addAction:cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alerVC animated:YES completion:nil];
    });
}

- (void)updateSex:(NSString *)title {
    [ESMemberInfoData updateSexInfo:self.memberInfo withItems:self.items withTitle:title];
    [self.mainView refreshMainView];
    self.rightButton.enabled = YES;
}

@end
