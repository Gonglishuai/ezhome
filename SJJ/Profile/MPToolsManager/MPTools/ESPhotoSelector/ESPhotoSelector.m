//
//  ESPhotoSelector.m
//  Consumer
//
//  Created by zhang dekai on 2018/2/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESPhotoSelector.h"
#import <Photos/Photos.h>
#import <TZImageManager.h>
#import <TZImagePickerController.h>

@interface ESPhotoSelector()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) UIViewController        *currentViewController;

@end

@implementation ESPhotoSelector

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxSelectNumber = 1;
    }
    return self;
}

- (void)selectPhoto:(UIViewController *)currentViewController {
    
    self.currentViewController = currentViewController;
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [currentViewController presentViewController:alerVC animated:YES completion:nil];
        
    });
}

/**
 拍照，启动相机校验
 */
- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)) {
        // 无相机权限 做一个友好的提示
        [self alterForCamera:YES];

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
        [self alterForCamera:NO];
        
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [self requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}


- (UIImagePickerController *)imagePickerVc {
    
    if (_imagePickerVc == nil) {
        
        _imagePickerVc = [[UIImagePickerController alloc] init];
        
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = _currentViewController.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = _currentViewController.navigationController.navigationBar.tintColor;
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

// 调用相机
- (void)pushImagePickerController {
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        
        self.imagePickerVc.sourceType = sourceType;
        
        [_currentViewController presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        SHLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
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
        WS(weakSelf);

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
                            
                            if (weakSelf.returnedPhotos) {
                                NSArray *photos = @[cropImage];
                                weakSelf.returnedPhotos(photos);
                            }
                        }];
                        
                        imagePicker.needCircleCrop = NO;
                        imagePicker.circleCropRadius = 150;
                        [weakSelf.currentViewController presentViewController:imagePicker animated:YES completion:nil];
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

/**
 调取相册
 */
- (void)pushTZImagePickerController {
    NSInteger column = SCREEN_WIDTH > 400 ? 4 : 3;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:_maxSelectNumber columnNumber:column delegate:nil pushPhotoPickerVc:YES];
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
        
        if (self.returnedPhotos) {
            self.returnedPhotos(photos);
        }
    }];
    
    [_currentViewController presentViewController:imagePickerVc animated:YES completion:nil];
}


- (void)alterForCamera:(BOOL)camera {
    
    NSString *title = @"无法使用相机";
    NSString *message = @"请在iPhone的""设置-隐私-相机""中允许访问相机";
    
    if (!camera) {
        title = @"无法访问相册";
        message = @"请在iPhone的""设置-隐私-相册""中允许访问相册";
    }
    
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alerVC addAction:takePhoto];
    
    UIAlertAction *goSet = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        
    }];
    [alerVC addAction:goSet];
    
    [_currentViewController presentViewController:alerVC animated:YES completion:nil];
}

@end
