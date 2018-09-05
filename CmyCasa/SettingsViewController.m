//
//  SettingsViewController.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc.. All rights reserved.
//

#import "SettingsViewController.h"
#import "ConfigManager.h"
#import "ModelsHandler.h"
#import "UIViewController+Helpers.h"
#import "PopOverViewController.h"
#import "UIView+Alignment.h"
#import "UIView+ReloadUI.h"
#import "DataManager.h"
#import "PackageManager.h"


#define LANG_DROPDOWN (100)
#define COUNTRY_DROPDOWN (105)

@interface SettingsViewController ()<UIPopoverControllerDelegate>
@property (strong,nonatomic)UIPopoverController *popOver;
@property (strong,nonatomic)UIVisualEffectView *shadowView;
- (void)actionEmailComposer;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[DataManger sharedInstance] isLangArray] && [[DataManger sharedInstance] getLangComponentIndex] > -1) {
        NSString * selectedLang = [[DataManger sharedInstance] getSelecectedLang];
        [[DataManger sharedInstance] setCurrentLangValue:selectedLang];
    }else{
        [[DataManger sharedInstance] setCurrentLangValue:@"English"];
    }
    
    if ([[DataManger sharedInstance] isCountryArray] && [[DataManger sharedInstance] getCountryComponentIndex] > -1) {
        NSString * selectedCountry = [[DataManger sharedInstance] getSelecectedCountry];
        [[DataManger sharedInstance] setCurrentCountryValue:selectedCountry];
    }else{
        [[DataManger sharedInstance] setCurrentCountryValue:@"United Kingdom"];
    }
    
    [self generateSettingArray];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _versionLbl.text = [[ConfigManager sharedInstance] getApplicationVersion];
    
    if (!CGAffineTransformIsIdentity(self.parentViewController.view.transform)) {
        CGPoint p = self.parentViewController.view.center;
        self.view.center = CGPointMake(p.y, p.x);
    } else {
        self.view.center = self.parentViewController.view.center;
    }

    [self.tableView reloadData];
    
    [self.view reloadUI];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Class Function

-(void)generateSettingArray{
    self.settingsList = [NSMutableArray arrayWithCapacity:0];
    
    if (![ConfigManager isChineseOnlyActive])
        [self.settingsList addObject:NSLocalizedString(@"setting_title_change_local", @"")];
//
//    if ([ConfigManager isLocationBasedTenantActive]){
//        [self.settingsList addObject:NSLocalizedString(@"setting_title_change_country", @"")];
//    }
//    
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
}

- (IBAction)closeSettings:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        [self.settingContainerView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
        [self.viewBg setAlpha:0.0];
        [self.settingContainerView setAlpha:1.0];
    }];
}


#pragma mark - Class Function
- (void)langSelectedkey:(NSString*)key value:(NSString*)value
{
    [self.languagesPopover dismissPopoverAnimated:YES];
    
    NSString * langName = key;
    
    if (langName) {
        [[DataManger sharedInstance] saveLangToDeviceStorage:langName];
    }
    
    NSString *currentLang = [[DataManger sharedInstance] getCurrentLangValue];
    if (![currentLang isEqualToString:key]) {
        [self showAlert];
    }
    
    [[DataManger sharedInstance] setCurrentLangValue:key];
}

- (void)countrySelectedkey:(NSString*)key value:(NSString*)value
{
    [self.countryPopover dismissPopoverAnimated:YES];
    
    NSString * countryName = key;
    
    if (countryName) {
        [[DataManger sharedInstance] saveCountryToDeviceStorage:countryName];
    }
    
     NSString *currentCountry = [[DataManger sharedInstance] getCurrentCountryValue];
    if (![currentCountry isEqualToString:key]) {
        NSString* countrySymbole = [[DataManger sharedInstance] getCountrySymboleForCountyName:key];
        [[ConfigManager sharedInstance] setCountySymbol:countrySymbole];
        [[ConfigManager sharedInstance] loadConfigData];
    }

    [[DataManger sharedInstance] setCurrentCountryValue:key];
    
    [self closeSettings:nil];
}

-(void)startBgAnimation{
    [UIView animateWithDuration:0.5 animations:^{
        [self.viewBg setAlpha:0.5];
    }];
}

#pragma mark tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if (self.settingsList && indexPath.row < [self.settingsList count]) {
        NSString *option = [self.settingsList objectAtIndex:indexPath.row];
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_change_local", @"")]) {
            self.isLangDataLoaded = YES;
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            PopOverViewController * langViewController = [sb instantiateViewControllerWithIdentifier:@"PopOverViewController"];
            
            self.languagesPopover = [[UIPopoverController alloc] initWithContentViewController:langViewController];
            [self.languagesPopover presentPopoverFromRect:cell.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            
            [langViewController setDataArray:[[DataManger sharedInstance] getLangArray]];
            langViewController.popOverType = kPopOverLang;
            langViewController.delegate = self;
            [langViewController setCurrentSelectedKey:[[DataManger sharedInstance] getCurrentLangValue]];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_change_country", @"")]) {
            //picker show language
            self.isLangDataLoaded = NO;
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            PopOverViewController * countryViewController = [sb instantiateViewControllerWithIdentifier:@"PopOverViewController"];
            
            self.countryPopover = [[UIPopoverController alloc] initWithContentViewController:countryViewController];
            [self.countryPopover presentPopoverFromRect:cell.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

            [countryViewController setDataArray:[[DataManger sharedInstance] getCountryArray]];
            countryViewController.popOverType = kPopOverCountry;
            countryViewController.delegate = self;
            [countryViewController setCurrentSelectedKey:[[DataManger sharedInstance] getCurrentCountryValue]];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_privacy", @"")]) {
            if (![self isConnectionAvailable]) {
                return;
            }
            
            [super openFeedback:nil];
            
            GenericWebViewBaseViewController * iWeb = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] privacyLink]];
            
            [self.parentViewController presentViewController:iWeb animated:YES completion:nil];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_about", @"")]) {
            [super openAboutPage:nil];
            
            [[UIMenuManager sharedInstance] openAboutPagePressed:self];
//            [self removeFromParentViewController];
//            [self.view removeFromSuperview];
        }
        
        if ([option isEqualToString:NSLocalizedString(@"setting_title_terms", @"")]) {
            if (![self isConnectionAvailable]) {
                return;
            }
            
            [super openTermsConditions:nil];
            
            GenericWebViewBaseViewController * iWeb = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] termsLink]];
            
            [self.parentViewController presentViewController:iWeb animated:YES completion:nil];
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
            [self closeSettings:nil];
            GalleryStreamManager * sman=[[AppCore sharedInstance] getGalleryManager];
            GalleryBanneItem *bannerItem = sman.getBannerArray;
            if (sman.getBannerArray && ![bannerItem.link isEqualToString:@""]) {
                NSRange range = [bannerItem.link rangeOfString:@"https"];
                NSString *url = [bannerItem.link substringFromIndex:range.location];
                GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:url];
                web.displayPortrait = YES;
                self.popOver = [[UIPopoverController alloc] initWithContentViewController:web];
                self.popOver.popoverContentSize = CGSizeMake(449, 550);
                [self.popOver presentPopoverFromRect:CGRectMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2, 0 , 0) inView:self.view permittedArrowDirections:0 animated:YES];
                self.popOver.delegate = self;
                [self.vc.view addSubview:self.shadowView];
            }
        }
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.shadowView removeFromSuperview];
}

-(UIVisualEffectView *)shadowView {
    if (_shadowView == nil) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _shadowView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _shadowView.frame = self.vc.view.bounds;
    }
    return _shadowView;
}
@end
