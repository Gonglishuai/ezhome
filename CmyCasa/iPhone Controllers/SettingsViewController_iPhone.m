//
//  SettingsViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import "SettingsViewController_iPhone.h"
#import "UIViewController+Helpers.h"
#import "SettingCell.h"
#import "PackageManager.h"
#import "DataManager.h"

#define THE_LANG_OPTION_POZ 0

@interface SettingsViewController_iPhone ()

@end

@implementation SettingsViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self generateSettingsArray];

    self.versionLbl.text = [[ConfigManager sharedInstance] getApplicationVersion];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:YES];
    
    [self.tableView reloadData];
}


- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(void)dealloc{
    NSLog(@"SettingsViewController_iPhone dealloc");
}

#pragma mark - Class Function
-(void)generateSettingsArray
{
    self.settingsList = [NSMutableArray arrayWithCapacity:0];
    
    if (![ConfigManager isChineseOnlyActive])
        [self.settingsList addObject:NSLocalizedString(@"setting_title_change_local", @"")];
   
//    if ([ConfigManager isLocationBasedTenantActive]) {
//        [self.settingsList addObject:NSLocalizedString(@"setting_title_change_country", @"")];
//    }
    
//    [self.settingsList addObject:NSLocalizedString(@"setting_title_privacy", @"")];
    
    [self.settingsList addObject:NSLocalizedString(@"setting_title_clear_cache", @"")];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_feedback", @"")];
    if (![[ConfigManager getTenantIdName] isEqualToString:@"ezhome"]){
        [self.settingsList addObject:NSLocalizedString(@"Follow us", @"")];
    }
    [self.settingsList addObject:NSLocalizedString(@"setting_title_about", @"")];

    
    // Check if offline package exists
    if ([[PackageManager sharedInstance] isOffLinePackageExist] && [[PackageManager sharedInstance] isOffLinePackageExist])
        [self.settingsList addObject:NSLocalizedString(@"setting_title_clear_offline_package", @"")];
    
    if ([ConfigManager isPushNotifiactionActive]) {
        [self.settingsList addObject:NSLocalizedString(@"setting_title_allow_pn", @"")];
    }
    
    if ([ConfigManager isFaceBookActive]) {
        [self.settingsList addObject:NSLocalizedString(@"setting_title_allow_like_fb", @"")];
    }
    
    if ([ConfigManager isNewsLetterActive]) {
        [self.settingsList addObject:NSLocalizedString(@"setting_title_allow_newsletter", @"")];
    }
    
//    [self.settingsList addObject:NSLocalizedString(@"setting_title_usage_data", @"")];
//    
//    [self.settingsList addObject:[[ConfigManager sharedInstance] getApplicationVersion]];
}

#pragma mark tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.settingsList && indexPath.row < [self.settingsList count]) {
        NSString *option = [self.settingsList objectAtIndex:indexPath.row];
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_change_local", @"")]) {
            self.isLangDataLoaded = YES;
            [self showPicker];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_change_country", @"")]) {
            //picker show language
            self.isLangDataLoaded = NO;
            [self showPicker];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_privacy", @"")]) {
            if (![self isConnectionAvailable]) {
                return;
            }
            
            [super openFeedback:nil];
            GenericWebViewBaseViewController * iWeb = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] privacyLink]];
            [self presentViewController:iWeb animated:YES completion:nil];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_about", @"")]) {
            [super openAboutPage:nil];
            [[UIMenuManager sharedInstance] openAboutPageIphonePressed:self];
        }

        if ([option isEqualToString:NSLocalizedString(@"setting_title_terms", @"")]) {
            if (![self isConnectionAvailable]) {
                return;
            }
            [super openTermsConditions:nil];
            GenericWebViewBaseViewController * iWeb = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] termsLink]];
            [self presentViewController:iWeb animated:YES completion:nil];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_clear_cache", @"")]) {
            
            [super clearCache:nil];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_clear_offline_package", @"")]){
                if ([ConfigManager isOfflineModeActive]) {
                    [super clearOfflinePackage:nil];
                }
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_feedback", @"")]) {
            [self actionEmailComposer];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"Follow us",@"")]){
            GalleryStreamManager * sman=[[AppCore sharedInstance] getGalleryManager];
            GalleryBanneItem *bannerItem = sman.getBannerArray;
            if (sman.getBannerArray && ![bannerItem.link isEqualToString:@""]) {
                NSRange range = [bannerItem.link rangeOfString:@"https"];
                NSString *url = [bannerItem.link substringFromIndex:range.location];
                GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:url];
                web.displayPortrait = YES;
                [self.navigationController pushViewController:web animated:YES];
            }
        }
    }
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)changeLanguage:(id)sender{
    self.tableView.userInteractionEnabled = YES;
    
    if (self.isLangDataLoaded) {
        NSString * langSymbole = [[DataManger sharedInstance] getSelecectedLang];
        
        if (langSymbole) {
            [[DataManger sharedInstance] saveLangToDeviceStorage:langSymbole];
        }
    }
    
    //update selection
    [self hidePicker];
    
    if (self.isLangDataLoaded) {
        //the lang pos in the array is 0
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:THE_LANG_OPTION_POZ inSection:0];
        
        SettingCell *cell = (SettingCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if ([[DataManger sharedInstance] isLangArray] && [[DataManger sharedInstance] getLangComponentIndex]) {
            NSString * selectedLang = [[DataManger sharedInstance] getSelecectedLang];
            if ([cell.settingName.text rangeOfString:selectedLang].location == NSNotFound) {
                [self showAlert];
            }
            [[DataManger sharedInstance] setCurrentLangValue:selectedLang];
        }else{
            //no one moved the picker so self.selectedComponentIndex == nil
            [[DataManger sharedInstance] setLangComponentIndex:0];
            NSString * selectedLang = [[DataManger sharedInstance] getSelecectedLang];
            if ([cell.settingName.text rangeOfString:selectedLang].location == NSNotFound) {
                [self showAlert];
            }
            [[DataManger sharedInstance] setCurrentLangValue:selectedLang];
        }
    }

    //update selection
    [self.tableView reloadData];
}

-(void)showPicker{
    if (!_isPickerShowen)
    {
        self.tableView.userInteractionEnabled = NO;
        [self.filterPicker reloadAllComponents];
        
        if (self.isLangDataLoaded) {
            [self.filterPicker selectRow:[[DataManger sharedInstance] getLangComponentIndex] inComponent:0 animated:NO];
        }else{
            [self.filterPicker selectRow:[[DataManger sharedInstance] getCountryComponentIndex] inComponent:0 animated:NO];
        }
        
        CGRect screenFrame = [UIScreen currentScreenBoundsDependOnOrientation];
        self.filterPickerView.frame = CGRectMake(0,
                                                 screenFrame.size.height - self.filterPickerView.frame.size.height,
                                                 self.filterPickerView.frame.size.width,
                                                 self.filterPickerView.frame.size.height);
        
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.filterPickerView.frame = CGRectMake(0,
                                                     screenFrame.size.height - self.filterPickerView.frame.size.height,
                                                     self.filterPickerView.frame.size.width,
                                                     self.filterPickerView.frame.size.height);
        } completion:^(BOOL finished) {
            _isPickerShowen = YES;
        }];
    }
    else
    {
        [self.filterPicker reloadAllComponents];

        if (self.isLangDataLoaded) {
            [self.filterPicker selectRow:[[DataManger sharedInstance] getLangComponentIndex] inComponent:0 animated:NO];
        }else{
            [self.filterPicker selectRow:[[DataManger sharedInstance] getCountryComponentIndex] inComponent:0 animated:NO];
        }

    }
}

- (IBAction)cancelPicker:(id)sender {
    
    [[DataManger sharedInstance] setLangComponentIndex:0];
    [[DataManger sharedInstance] setCountryComponentIndex:0];

    self.tableView.userInteractionEnabled = YES;
    [self hidePicker];
}

-(void)hidePicker{
    if (_isPickerShowen) {
        CGRect screenFrame = [UIScreen currentScreenBoundsDependOnOrientation];
        
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.filterPickerView.frame = CGRectMake(0,
                                                     screenFrame.size.height + self.filterPickerView.frame.size.height,
                                                     self.filterPickerView.frame.size.width,
                                                     self.filterPickerView.frame.size.height);
        } completion:^(BOOL finished) {
            _isPickerShowen = NO;
        }];
    }
}


@end


