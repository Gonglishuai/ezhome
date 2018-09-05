/**
 * @file    MPmoreViewController.m
 * @brief   the view of MPmoreViewController
 * @author  fu
 * @version 1.0
 * @date    2015-12-30
 */
#import "MPmoreViewController.h"
#import "SDWebImageManager.h"
#import "SHAboutViewController.h"
#import "SHLoginTool.h"
#import "MBProgressHUD.h"
#import "SHRNViewController.h"
#import "JRKeychain.h"

#import "ESSettingHomeController.h"

@interface MPmoreViewController ()<UITableViewDataSource,UITableViewDelegate, UIViewControllerTransitioningDelegate, UIActionSheetDelegate>
@end

@implementation MPmoreViewController
{
    UITableView *_tableView;
    NSString *_cacheStr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.transitioningDelegate = nil;
    self.navigationController.transitioningDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.transitioningDelegate = nil;
}

- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SHLog(@"MPmoreViewController lounch");
    
    //self.tabBarController.tabBar.hidden = YES;
    self.titleLabel.text = @"更多";
    self.rightButton.hidden = YES;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT)];
    _tableView.backgroundColor = ColorFromRGA(0xf7f7f7, 1);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
}

#pragma mark --UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([JRNetEnvConfig sharedInstance].isReleaseModel) {
            return 3;
        } else {
            return 3;
        }
        
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 78;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = ColorFromRGA(0xf7f7f7, 1);
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"moreCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    UIView *speView = [[UIView alloc] initWithFrame:CGRectMake(0, 54, SCREEN_WIDTH, 1)];
    speView.backgroundColor = [UIColor colorWithRed:(247.0/255.0) green:(247.0/255.0) blue:(247.0/255.0) alpha:1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:speView];
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = @"账号设置";
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        _cacheStr = [NSString stringWithFormat:@"%.1fM",[self getCacheSize]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 21)];
        label.text = _cacheStr;
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentRight;
        cell.accessoryView = label;
        cell.textLabel.text = @"清除缓存";
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        cell.textLabel.text = @"关于设计家";
    }
//    else if (indexPath.section == 0 && indexPath.row == 3)
//    {
//        cell.textLabel.text = @"定位开关";
//
//        UILabel *detailLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-165,0, 130, 55)];
//        detailLabel.textColor = [UIColor stec_subTitleTextColor];
//        detailLabel.font = [UIFont stec_titleFount];
//        detailLabel.textAlignment = NSTextAlignmentRight;
//        [cell.contentView addSubview:detailLabel];
//
//        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
//        NSString *status = [userDefaults objectForKey:@"app_location_key"];
//        if (status
//            && [status isKindOfClass:[NSString class]]
//            && [status isEqualToString:@"NO"])
//        {
//            detailLabel.text = @"关闭(默认北京)";
//        }
//        else
//        {
//            detailLabel.text = @"打开";
//        }
//    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, SCREEN_WIDTH-23*2, 50)];
        label.text = @"退出登录";
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = ColorFromRGA(0x2696c4, 1);
        label.clipsToBounds = YES;
        label.layer.cornerRadius = 2.0f;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:17];
        [cell.contentView addSubview:label];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    return cell;
}

/// Called after the user changes the selection.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        SHLog(@"账号设置-Reactnative");
        if (!self.phoneNumber || ![self.phoneNumber isKindOfClass:[NSString class]])
        {
            self.phoneNumber=@"";
        }
        

        ESSettingHomeController *accountSettingVC = [[ESSettingHomeController alloc] init];
        [self.navigationController pushViewController:accountSettingVC animated:YES];
        
    } else if (indexPath.section == 0 && indexPath.row == 1)  {
        __weak MPmoreViewController *weakSelf = self;
        
        if ([_cacheStr isEqualToString:@"0.0M"]) {
            
            [SHAlertView showAlertWithMessage:@"暂无缓存"
                      autoDisappearAfterDelay:1];
            return;
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定清空本地缓存数据(包括图片和语音缓存)?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                            style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"清空缓存数据" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tableView animated:YES];
            
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
            
            [[SDImageCache sharedImageCache] clearMemory];
            
            [[SDImageCache sharedImageCache] deleteOldFilesWithCompletionBlock:nil];
            
            [weakSelf fileOperation];
            
            [weakSelf performSelector:@selector(clearOver:) withObject:hud afterDelay:1];
        }];

        [alertController addAction:cancelAction];
        [alertController addAction:action];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        
        [self.navigationController pushViewController:[[SHAboutViewController alloc] init] animated:YES];
        
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        
//        [self changeAddress];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        
        [[ESLoginManager sharedManager] logout];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomePageReloadNotification object:nil];
    }
}

- (void)clearOver:(MBProgressHUD *)hud {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:CLEAR_HUD_OK]];
    hud.customView = imageView;
    hud.mode = MBProgressHUDModeCustomView;
    hud.label.text = @"成功";
    [hud hideAnimated:YES afterDelay:1];
    [_tableView reloadData];
}

- (void)fileOperation {
    
}

- (CGFloat)getCacheSize {
    NSUInteger byteSize = [SDImageCache sharedImageCache].getSize;
    // M
    CGFloat imageSize = byteSize / 1000.0 / 1000.0;
    
    NSString *docDir = [NSString stringWithFormat:@"%@%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],@"/mpstore"];
    
    CGFloat imCache = [self folderSizeAtPath:docDir];
    
    return imageSize + imCache;
}

- (long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (CGFloat)folderSizeAtPath:(NSString*) folderPath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize / (1000.0 * 1000.0);
}

//- (void)changeAddress {
//    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"定位" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    // Create the actions.
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
//    
//    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"关闭定位功能", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
//                              
//    {
//        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
//        
//        [userDefaults setObject:@"NO" forKey:@"app_location_key"];
//        
//        [userDefaults synchronize];
//        
//        abort();
//        
//    }];
//    
//    UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"打开定位功能", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
//                              
//    {
//        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
//        
//        [userDefaults setObject:@"YES" forKey:@"app_location_key"];
//        
//        [userDefaults synchronize];
//        
//        abort();
//    }];
//    // Add the actions.
//    [alertController addAction:cancelAction];
//    [alertController addAction:action1];
//    [alertController addAction:action2];
//    
//    [self presentViewController:alertController animated:YES completion:nil];
//}

@end
