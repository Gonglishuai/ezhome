
#import "CoLinkPageTool.h"
#import "SHFileUtility.h"
#import "CoLinkPageViewController.h"
#import "CoChangeRoleViewController.h"

#define LINK_ROLE_CHOOSE_PATH @"LINK_ROLE_CHOOSE"

@interface CoLinkPageTool ()

@end

@implementation CoLinkPageTool

/*---------角色选择--------*/

+ (BOOL)showRoleChoose
{
    NSString *path = [self receiveRoleChooseStatusPath];
    if (![SHFileUtility isFileExist:path])
    {
        CoChangeRoleViewController *roleChoose = [[CoChangeRoleViewController alloc] init];
        WS(weakSelf);
        roleChoose.clickEnter = ^(){
            [weakSelf didChooseButton];
        };
        
        [UIApplication sharedApplication].keyWindow.rootViewController = roleChoose;
        return YES;
    }
    return NO;
}

+ (void)didChooseButton
{
    [self updateRoleChooseStatus];
    AppDelegate *delegate = (id)[UIApplication sharedApplication].delegate;
    [delegate initTabbar];
}

+ (void)updateRoleChooseStatus
{
    NSString *path = [self receiveRoleChooseStatusPath];
    BOOL status = [SHFileUtility createDirectory:path];
    if (status)
        SHLog(@"选择角色页标示符创建成功");
    else
        SHLog(@"选择角色页标示符创建失败");
}

+ (NSString *)receiveRoleChooseStatusPath
{
    NSString *fileDirectory = [SHFileUtility getDocumentDirectory];
    NSString *filePath = [fileDirectory stringByAppendingPathComponent:LINK_ROLE_CHOOSE_PATH];
    return filePath;
}
@end
