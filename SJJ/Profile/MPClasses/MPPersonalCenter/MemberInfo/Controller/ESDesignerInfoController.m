//
//  ESMemberInfoController.m
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESDesignerInfoController.h"
#import "ESMemberInfoView.h"
#import "ESDesignerInfoData.h"
#import "ESMemberInfoViewModel.h"
#import <Masonry.h>
#import <MBProgressHUD.h>
#import <Photos/Photos.h>
#import <TZImageManager.h>
#import <TZImagePickerController.h>
#import "MPAddressSelectedView.h"
#import "MPRegionManager.h"
#import "ESDesignPricePicker.h"

@interface ESDesignerInfoController ()<ESMemberInfoViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MPAddressSelectedDelegate, ESDesignPricePickerDelegate>
@property (nonatomic, strong) ESMemberInfoView *mainView;
@property (nonatomic, strong) NSMutableArray <ESMemberInfoViewModel *> *items;
@property (nonatomic, strong) ESMemberInfo *memberInfo;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) MPAddressSelectedView *addressSelectedView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) ESDesignPricePicker *pricePicker;
@end

@implementation ESDesignerInfoController

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
    [ESDesignerInfoData getMemberInfoWithSuccess:^(ESMemberInfo *memberInfo, NSArray <ESFilterItem *> *filterList) {
        weakSelf.pricePicker = [[ESDesignPricePicker alloc] initWithData:filterList withDelegate:weakSelf];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.memberInfo = memberInfo;
        [weakSelf freshViewModel];
        [weakSelf.mainView refreshMainView];
    } andFailure:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

- (void)freshViewModel {
    [ESDesignerInfoData getItemContentWithViewModel:self.items withMemberInfo:self.memberInfo];
}

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        _imagePickerVc.delegate = self;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
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
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenPickerView)]];
    }
    return _maskView;
}

- (void)uploadMemberHeader:(UIImage *)image {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESDesignerInfoData updateMemberAvatar:image withSuccess:^(NSString *url){
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
    [ESDesignerInfoData updateMemberInfo:self.memberInfo withSuccess:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf showMessageHUD:@"保存成功!"];
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
    return [ESDesignerInfoData getMemberAvatar:self.memberInfo];
}

- (void)uploadButtonClick {
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    [alerVC addAction:takePhoto];
    
    UIAlertAction *pickPhoto = [UIAlertAction actionWithTitle:@"去相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pushTZImagePickerController];
    }];
    [alerVC addAction:pickPhoto];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alerVC addAction:cancel];
    
    [self presentViewController:alerVC animated:YES completion:nil];
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
        if ([viewModel.key isEqualToString:@"design_price"]) {
            [self selectDesignPrice];
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
    
    [ESDesignerInfoData manageTextField:textField editing:NO withKey:key withItems:self.items];
    
    [ESDesignerInfoData updateInputOption:self.memberInfo withItems:self.items];
}

- (void)textFieldEditBegin:(UITextField *)textField withKey:(NSString *)key {
    self.rightButton.enabled = NO;
    [ESDesignerInfoData manageTextField:textField editing:YES withKey:key withItems:self.items];
}

#pragma mark - TZImagePickerController
- (void)pushTZImagePickerController {
    NSInteger column = self.view.frame.size.width > 400 ? 4 : 3;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:column delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.allowCrop = YES;
    imagePickerVc.needCircleCrop = NO;
    imagePickerVc.circleCropRadius = 150;
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0) {
            [self uploadMemberHeader:[photos firstObject]];
        }
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    return YES;
}

- (BOOL)isAssetCanSelect:(id)asset {
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
        tzImagePickerVc.sortAscendingByModificationDate = YES;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                SHLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                            [self uploadMemberHeader:cropImage];
                        }];
                        imagePicker.needCircleCrop = NO;
                        imagePicker.circleCropRadius = 150;
                        [self presentViewController:imagePicker animated:YES completion:nil];
                    }];
                }];
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark MPAddressSelectedDelegate
- (void)selectedAddressinitWithProvince:(NSString *)province withCity:(NSString *)city withTown:(NSString *)town isCertain:(BOOL)isCertain {
    
    [self hiddenPickerView];
    if (isCertain) {
        [ESDesignerInfoData updateRegionInfo:self.memberInfo withItems:self.items withProvinceCode:province withCityCode:city andDistrictCode:town];
        
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

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
        
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self takePhoto];
                });
            }
        }];
        
        // 拍照之前还需要检查相册权限
    } else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
        
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [self requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        SHLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)requestAuthorizationWithCompletion:(void (^)(void))completion {
    void (^callCompletionBlock)(void) = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            callCompletionBlock();
        }];
    });
}

- (void)selectAddress {
    self.rightButton.enabled = NO;
    [self showAddrPicker];
    NSString *province = self.memberInfo.basic.province ? : @"";
    NSString *city = self.memberInfo.basic.city ? : @"";
    NSString *district = self.memberInfo.basic.district ? : @"";
    [self.addressSelectedView setPickerViewprovinceCode:province cityCode:city townCode:district];
    [self.addressSelectedView showInView:self.view];
}

- (void)showAddrPicker {
    self.addressSelectedView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.addressSelectedView.frame.size.height);
    
    [self.view addSubview:self.maskView];
    [self.view bringSubviewToFront:self.maskView];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.4;
    [UIView animateWithDuration:0.3 animations:^{
        self.addressSelectedView.frame = CGRectMake(0, SCREEN_HEIGHT - self.addressSelectedView.frame.size.height, SCREEN_WIDTH, self.addressSelectedView.frame.size.height);
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
    
    [self presentViewController:alerVC animated:YES completion:nil];
}

- (void)updateSex:(NSString *)title {
    [ESDesignerInfoData updateSexInfo:self.memberInfo withItems:self.items withTitle:title];
    [self.mainView refreshMainView];
    self.rightButton.enabled = YES;
}

- (void)selectDesignPrice {
    [self.pricePicker showDesignPricePickerInView:self.view];
}

- (void)hiddenPickerView {
    self.maskView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        if(self.addressSelectedView != nil){
            self.addressSelectedView.frame = CGRectMake(0, SCREEN_HEIGHT - NAVBAR_HEIGHT +self.addressSelectedView.frame.size.height, SCREEN_WIDTH, self.addressSelectedView.frame.size.height);
        }
    } completion:^(BOOL finished) {
        @try {
            [self hideMaskView];
            if (self.addressSelectedView != nil) {
                [self.addressSelectedView removeFromSuperview];
            }
        } @catch (NSException *exception) {
            
        } @finally {
            self.addressSelectedView = nil;
        }
    }];
}

- (void)hideMaskView {
    @try {
        [self.maskView removeFromSuperview];
    } @catch (NSException *exception) {
        @throw exception;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - ESDesignPricePickerDelegate
- (void)selectedPrice:(ESFilterItem *)item {
    [ESDesignerInfoData updateDesignPrice:item withInfo:self.memberInfo withItems:self.items];
    [self.mainView refreshMainView];
    self.rightButton.enabled = YES;
}
@end
