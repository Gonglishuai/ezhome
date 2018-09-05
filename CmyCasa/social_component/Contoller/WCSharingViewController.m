//
//  WCSharingViewController.m
//  Homestyler
//
//  Created by lvwei on 13/04/2017.
//
//

#import "WCSharingViewController.h"
#import "HSSharingLogic.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "WXApiManager.h"
#import "QRCodeSharingViewController.h"

//Xib
#define kWCSharingViewControllerXibNameiPhone       @"WCSharingViewController_iPhone"
#define kWCSharingViewControllerXibNameiPad         @"WCSharingViewController_iPad"

@interface WCSharingViewController () <WXApiManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *background;

@property (nonatomic, strong) HSSharingLogic *logic;
@property (nonatomic, strong) UIImage *imgShareImage;
@property (nonatomic, strong) NSString *designShareLink;
@property (nonatomic, strong) NSString *shareMessage;
@property (nonatomic, strong) NSString *shareDescription;

@end

@implementation WCSharingViewController

-(id)initWithShareData:(HSShareObject*)shareObj{
    
    NSString *xibName = IS_IPAD ? kWCSharingViewControllerXibNameiPad : kWCSharingViewControllerXibNameiPhone;
    
    self = [self initWithNibName:xibName bundle:[NSBundle mainBundle]];
    
    if (self) {
        self.logic = [[HSSharingLogic alloc] initWithText:shareObj];
        self.imgShareImage = shareObj.picture;
        self.designShareLink = shareObj.designShareLink;
        self.shareMessage = [NSString stringWithFormat:@"%@ | %@", shareObj.message, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
        self.shareDescription = NSLocalizedString(@"share_description", @"");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.background addGestureRecognizer:singleRecognizer];
    
    [WXApiManager sharedManager].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)singleTap:(UITapGestureRecognizer*)recognizer
{
    [self exitSharingView];
}

-(IBAction)cancelSharing:(id)sender
{
    [self exitSharingView];
}

-(IBAction)shareToFriend:(id)sender
{
    if (![WXApi isWXAppInstalled]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"erh_wechat_not_installed_error_msg", @"")
                                                        delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                                        otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;//不使用文本信息
    sendReq.scene = 0; //0 = 好友列表 1 = 朋友圈 2 = 收藏
    
    //创建分享内容对象
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    urlMessage.title = self.shareMessage;
    urlMessage.description = self.shareDescription;
    [urlMessage setThumbImage:[self.imgShareImage scaleImageTo800]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
    
    //创建多媒体对象
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = self.designShareLink;//分享链接
    
    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];
}

-(IBAction)shareTheMoment:(id)sender
{
    if (![WXApi isWXAppInstalled]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"erh_wechat_not_installed_error_msg", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                               otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;//不使用文本信息
    sendReq.scene = 1; //0 = 好友列表 1 = 朋友圈 2 = 收藏
    
    //创建分享内容对象
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    urlMessage.title = self.shareMessage;
    urlMessage.description = self.shareDescription;
    [urlMessage setThumbImage:[self.imgShareImage scaleImageTo800]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
    
    //创建多媒体对象
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = self.designShareLink;//分享链接
    
    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    sendReq.message = urlMessage;
    
    //发送分享信息
    [WXApi sendReq:sendReq];
}

-(IBAction)shareByQRCode:(id)sender
{
    UIViewController * parent = self.parentViewController;
    
    [self exitSharingView];
    
    if (parent) {
        QRCodeSharingViewController *qrVC = [[QRCodeSharingViewController alloc] initWithString:self.designShareLink];
        
        [qrVC.view setFrame:parent.view.bounds];
        [parent.view addSubview:qrVC.view];
        [parent addChildViewController:qrVC];
    }
}

-(bool)exitSharingView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                           forView:self.view
                             cache:YES];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    [UIView commitAnimations];
    
    return YES;
}

-(void)enterSharingView:(UIViewController *)parent
{
    [self.view setFrame:parent.view.bounds];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                           forView:self.view
                             cache:YES];
    
    [parent.view addSubview:self.view];
    [parent addChildViewController:self];
    
    [UIView commitAnimations];
}

#pragma mark - WXApiManagerDelegate
- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {
    NSString *strMsg = @"分享失败";
    switch (response.errCode) {
        case WXSuccess:
            strMsg = @"分享成功";
            break;
        case WXErrCodeCommon:
            strMsg = @"分享失败";
            break;
        case WXErrCodeUserCancel:
            strMsg = @"分享取消";
            break;
        case WXErrCodeSentFail:
            strMsg = @"分享失败";
            break;
        case WXErrCodeAuthDeny:
            strMsg = @"微信授权失败";
            break;
        case WXErrCodeUnsupport:
            strMsg = @"微信不支持";
            break;
            
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                   message:strMsg
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"")
                                         otherButtonTitles:nil, nil];
    alert.delegate = self;
    [alert show];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( 0 == buttonIndex ){ //cancel button
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [self exitSharingView];
    }
}

@end
