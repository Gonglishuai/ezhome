//
//  CoCaseDetailController.m
//  Consumer
//
//  Created by Jiao on 16/7/19.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoCaseDetailController.h"
#import "MPCaseBaseModel.h"
#import "CoCaseDetailView.h"
#import "CoCaseImageCell.h"
#import "MBProgressHUD.h"
#import "CoMyFocusModel.h"

#import "MPCaseModel.h"
#import "MBProgressHUD+NJ.h"
#import "CoSlidingViewMange.h"
#import "UIImageView+WebCache.h"

#import "SDImageCache.h"
#import "SDWebImageManager.h"

#import "WXApiRequesHandler.h"
#import "WXApiManager.h"
#import "ESPhotoBrowser.h"
#import "ESNIMManager.h"
#import "ESShareView.h"
#import <ESNetworking/SHAlertView.h>
#import <MGJRouter.h>
#import "ESCommentAPI.h"

@interface CoCaseDetailController ()<CoCaseDetailViewDelegate,UIGestureRecognizerDelegate,WXApiManagerDelegate, ESLoginManagerDelegate>
{
    NSString *kLinkTitle;
    NSString *kLinkDescription;
    NSString *kLinkTagName;
    NSString *kLinkCaseId;
    NSString *kimageUrl;
    NSMutableArray *imageShowArr;
}

@property (assign,nonatomic) NSInteger saveThumbCount;
@property (nonatomic, strong) CoCaseImageCell *selectedCell;

@end

//static NSString *kLinkURL = @"http://uat-www.gdfcx.net/share/2dcase.html?caseid=";

@implementation CoCaseDetailController
{
    NSString *_caseID;
    ES2DCaseDetail *_caseDetail;
    CoCaseDetailView *_caseDetailView;
    int _favoriteCount;
    BOOL _isLike;
    
    UIView *backView;
    UIView *notificationView;
}

- (instancetype)initWithCaseID:(NSString *)caseID {
    self = [super init];
    if (self) {
        NSAssert(caseID, @"caseID missing");
        _caseID = caseID;
    }
    return self;
}
- (void)dealloc{
    [[ESLoginManager sharedManager] removeLoginDelegate:self];
    [WXApiManager sharedManager].delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightButton.hidden = YES;
    [[ESLoginManager sharedManager] addLoginDelegate:self];
    [self createCaseView];
    [self initRequestData];
    [WXApiManager sharedManager].delegate = self;
    
}

#pragma mark - ESLoginManagerDelegate
- (void)onLogin {
    [self initRequestData];
}

- (void)onLogout {
    [self initRequestData];
}

// 判断是否登录,点赞的状态
-(void)judgeLoginStutas
{
    BOOL status = [ESLoginManager sharedManager].isLogin;
    if (status == NO )
    {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    }else{
        //判断是否显示点赞状态
        [self selectThumbStatus];
    }
    
}

// 点赞状态判断方法
-(void)selectThumbStatus
{
    _isLike = _caseDetail.isLike;
    _favoriteCount = [_caseDetail.favoriteCount intValue];
    [_caseDetailView refreshMiddleView];
    
}

- (void)createCaseView {
    _caseDetailView = [[CoCaseDetailView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT)];
    _caseDetailView.backgroundColor = [UIColor whiteColor];
    _caseDetailView.delegate = self;
    [self.view addSubview:_caseDetailView];
}

- (void)initRequestData {
    
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:_caseDetailView animated:YES];
    [MPCaseBaseModel get2DCaseDetailWithAssetId:_caseID withSuccess:^(ES2DCaseDetail *caseDetail) {
        
        NSString* numberCount = caseDetail.favoriteCount;
        _favoriteCount = [numberCount intValue];
        SHLog(@"-------%@",numberCount);
        //微信参数进行配置
        kLinkTitle = caseDetail.title;
        kLinkDescription = caseDetail.caseDescription;
        if ([kLinkDescription isEqualToString:@""]||!kLinkDescription ) {
            kLinkDescription = @"暂无介绍";
        }
        kLinkCaseId = caseDetail.assetId;
        _isLike = caseDetail.isLike;
        NSInteger urlCount = caseDetail.images.count;
        if (urlCount != 0) {
            NSString * fileURL = [caseDetail.images objectAtIndex:0];
            kimageUrl = fileURL;
        }
        
        //图片滚动数据源
        imageShowArr = [NSMutableArray array];
        if (caseDetail.caseCover) {
            [imageShowArr addObject:caseDetail.caseCover];
        }
        if (caseDetail.images) {
            [imageShowArr addObjectsFromArray:caseDetail.images];
        }
        
        _caseDetail = caseDetail;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.titleLabel.text = _caseDetail.title;
            
            [MBProgressHUD hideHUDForView:_caseDetailView animated:YES];
            [_caseDetailView showBottomView];
            [_caseDetailView refreshMiddleView];
        });
        
    } andFailure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:_caseDetailView animated:YES];
            [SHAlertView showAlertForNetError];
        });
    }];
}

#pragma mark - Override
- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CoCaseDetailViewDelegate
- (NSInteger)getCaseImages {
    if (_caseDetail.images.count > 1) {
        return _caseDetail.images.count ;
    }
    return 0;
}

#pragma mark - CoCaseBottomBarViewDelegate
- (ES2DCaseDetail *)getDesignerInfo {
    return _caseDetail;
}
- (BOOL)getLoginStatus {
    return [ESLoginManager sharedManager].isLogin;
}
- (void)tapHeadIcon {
    ESCaseDesignerInfo *model = _caseDetail.designerInfo;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:model.designerId forKey:@"designId"];
    [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
}

- (void)chatBtnClick {
    
    if ([ESLoginManager sharedManager].isLogin) {
        [ESNIMManager startP2PSessionFromVc:self withJMemberId:_caseDetail.designerInfo.designerId andSource:ESIMSourceCaseDetail];
        
    } else {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    }
}

- (void)showAleartWithTitle:(NSString *)title{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1];
}

/// 关注设计师
- (void)attentionRequestWithFollowsType:(NSString *)followsType Success:(void(^)(void))success {
    
    [MBProgressHUD showHUDAddedTo:_caseDetailView animated:YES];
    
    WS(weakSelf);
    NSString *attentionDesignerMemberId = [NSString stringWithFormat:@"%@",_caseDetail.designerInfo.designerId];//_model.designer.acs_member_id
    
    if ([followsType isEqualToString:@"true"]) {
        [ESCommentAPI addFollowWithFollowId:attentionDesignerMemberId type:@"0" withSuccess:^(NSDictionary *dict) {
            [MBProgressHUD hideHUDForView:_caseDetailView animated:YES];
            _caseDetail.designerInfo.isFollow = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:_caseDetailView animated:YES];
                [weakSelf showAleartWithTitle:@"关注成功"];
                
            });
        } andFailure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:_caseDetailView animated:YES];
                [SHAlertView showAlertForNetError];
            });
        }];
    } else {
        [ESCommentAPI deleteFollowWithFollowId:attentionDesignerMemberId type:@"0" withSuccess:^(NSDictionary *dict) {
            _caseDetail.designerInfo.isFollow = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:_caseDetailView animated:YES];
                
            });
        } andFailure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:_caseDetailView animated:YES];
                [SHAlertView showAlertForNetError];
            });
        }];
    }
}

- (void)focusBtnClickWithFocus:(BOOL)focus withSuccess:(void(^)(void))success {
    SHLog(@"点击了关注");
    
    if ([ESLoginManager sharedManager].isLogin) {
        if (focus) {
            [self attentionRequestWithFollowsType:@"true" Success:^{
                if (success) {
                    return success();
                }
            }];
            
        } else {
            NSString *titleStr = [NSString stringWithFormat:@"您确定取消对%@的关注吗？",_caseDetail.designerInfo.userName];
            [SHAlertView showAlertWithMessage:titleStr sureKey:^{
                [self attentionRequestWithFollowsType:@"false" Success:^{
                    if (success) {
                        return success();
                    }
                }];
            } cancelKey:^{            }];
        }
    }else {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        
    }
    
}

#pragma mark - CoCaseDetailFooterViewDelegate
///案例是否点过赞
- (BOOL)getCaseZan {
    return _isLike;
}

///获取点赞数
- (NSInteger)getCaseZanNumber{
    return _favoriteCount;
}

///点击“分享”
- (void)caseShare {
    
    //判断是否登录
    //    BOOL status = [ESLoginManager sharedManager].isLogin;
    //    if (status == NO )
    //    {
    //        [SHAppGlobal AppGlobal_ProccessLoginWithType:ESLoginTypeHomePage controller:self];
    //    }else{
    
    NSString *apiStr = [NSString stringWithFormat:@"%@/case/newDetail/2d/", [JRNetEnvConfig sharedInstance].netEnvModel.mServer];
    NSString *str = [NSString stringWithFormat:@"%@%@",apiStr,kLinkCaseId];
    
    [ESShareView showShareViewWithShareTitle:kLinkTitle shareContent:kLinkDescription shareImg:kimageUrl shareUrl:str shareStyle:ShareStyleTextAndImage Result:^(PlatformType type, BOOL isSuccess) {
    }];
    
    
    //    }
}



-(void)SingleTap:(UITapGestureRecognizer*)recognizer
{
    [backView removeFromSuperview];
    [notificationView removeFromSuperview];
}

///点击“点赞”
- (void)caseZanWithSuccess:(void(^)(BOOL selected))success andFailure:(void(^)(void))failure {
    [self caseDetailForThumbUpClickThingsWithSuccess:success andFailure:failure];
}

- (void)caseDetailForThumbUpClickThingsWithSuccess:(void(^)(BOOL selected))success andFailure:(void(^)(void))failure
{
    //判断是否登录
    BOOL status = [ESLoginManager sharedManager].isLogin;
    if (status == NO )
    {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        if (failure) {
            failure();
        }
    }else{
        //网络调用
        [self caseDetailForThumbUpClickThingsToRequestDataWithSuccess:success andFailure:failure];
        
    }
    
}

- (void)caseDetailForThumbUpClickThingsToRequestDataWithSuccess:(void(^)(BOOL selected))success andFailure:(void(^)(void))failure
{
    //点赞接口
    [ESCommentAPI addLikeWithResourceId:_caseID type:@"1" withSuccess:^(NSDictionary *dict) {
        _isLike = YES;
        NSString *num = [NSString stringWithFormat:@"%@", dict[@"likes"]?dict[@"likes"]:@"0"];
        _favoriteCount = [num intValue];
        [_caseDetailView refreshMiddleView];
        [MBProgressHUD showSuccess:@"点赞成功" toView:nil];
        if (success) {
            success(YES);
        }
    } andFailure:^(NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

#pragma mark - CoCaseImageCellDelegate
-(NSString *) getCaseLibraryDetailModelForSection:(NSInteger)section withIndex:(NSUInteger) index {
    NSString *image;
    @try {
        if (section == 0) {
            image = _caseDetail.caseCover;
        }else {
            image = [_caseDetail.images objectAtIndex:index - 1];
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    } @finally {
        return image;
    }
}

- (UIView *)getControllerView {
    return self.view;
}

- (NSArray *)getCaseArr{
    return imageShowArr;
}

- (void)caseImageCellDidSelectedPhoto:(CoCaseImageCell *)cell
                            imageView:(UIImageView *)imageView
                           photoIndex:(NSInteger)photoIndex
{
    
    if(imageShowArr.count == 0
       || photoIndex >= imageShowArr.count)
    {
        return;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger i = 0; i < imageShowArr.count; i++)
    {
        NSString *imageUrl = imageShowArr[i];
        if (imageUrl
            && [imageUrl isKindOfClass:[NSString class]]
            && imageUrl.length > 0)
        {
            ESPhoto *photo = [[ESPhoto alloc] init];
            photo.url = [NSURL URLWithString:imageUrl];
            photo.srcImageView = imageView;
            [arrM addObject:photo];
        }
    }
    
    ESPhotoBrowser *browser = [[ESPhotoBrowser alloc] init];
    browser.currentPhotoIndex = photoIndex;
    browser.photos = [arrM copy];
    [browser show];
}


#pragma mark - CoCaseIntroductionCellDelegate
- (ES2DCaseDetail *)getIntroductionDetail {
    return _caseDetail;
}

@end
