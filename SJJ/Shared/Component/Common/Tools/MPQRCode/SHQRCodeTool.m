
#import "SHQRCodeTool.h"
#import "SHAlertView.h"
#import <AVFoundation/AVFoundation.h>
//#import "MPCenterTool.h"

@implementation SHQRCodeTool

+ (instancetype)sharedInstance
{
    static SHQRCodeTool *s_qrTool = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        s_qrTool = [[super allocWithZone:NULL]init];
    });
    
    return s_qrTool;
}


///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [SHQRCodeTool sharedInstance];
}


///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [SHQRCodeTool sharedInstance];
}

+ (void)checkQRWithViewController:(UIViewController *)vc
                             dict:(NSDictionary *)dict {
    
    if ([dict allKeys].count == 6 && dict[@"hs_uid"]) {
        
//        [SHAppGlobal chatWithVC:vc
//                       ReceiverID:dict[@"member_id"]
//              ReceiverHomeStyleID:dict[@"hs_uid"]
//                     receiverName:dict[@"name"]
//                    withMediaType:[SHMarketplaceSettings sharedInstance].mediaIdProject
//                          assetID:nil
//                         isQRScan:YES];
//        
    } else {
        [SHAlertView showAlertWithMessage:@"无法识别此二维码" sureKey:^{
            [vc.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
}

+ (BOOL)checkCameraEnable {
    if (![self IsCaptureAvalible]) {
        [SHAlertView showAlertWithTitle:NSLocalizedString(@"将二维码放入框内", nil)
                                message:NSLocalizedString(@"请在iOS'设置'-'隐私'-'相机'中打开", nil)
                         cancelKeyTitle:NSLocalizedString(@"取消", nil)
                          rightKeyTitle:NSLocalizedString(@"去设置", nil)
                               rightKey:^{
//                                   [SHAppGlobal openSettingPrivacy];
                               } cancelKey:nil];
        return NO;
    }
    return YES;
}

+ (void)checkQRBtn:(UIButton *)btn {

    btn.hidden = YES;
    
    SHQRCodeTool *tool = [SHQRCodeTool sharedInstance];
    if ([tool.delegate respondsToSelector:@selector(setQRButtonShown)]) {
        btn.hidden = ![tool.delegate setQRButtonShown];
    }
    //TODO: #REFACTORING
//    if ([[MPCenterTool getIsLoho] isEqualToString:@"2"]) {
//        btn.hidden = NO;
//    }
}

+ (BOOL)IsCaptureAvalible{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!captureDevice) return NO;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    if (!input) return NO;
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if (!captureMetadataOutput) return NO;
    return YES;
}

@end
