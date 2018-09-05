//
//  SettingsBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import "SettingsBaseViewController.h"
#import "ModelsHandler.h"
#import "SDImageCache.h"
#import "WallpapersManager.h"
#import "SettingCell.h"
#import "NotificationNames.h"
#import "PackageManager.h"
#import "DebugViewController.h"
#import "DataManager.h"
//#import "UMMobClick/MobClick.h"
#import "UIDevice+Name.h"

@interface SettingsBaseViewController ()

@end

@implementation SettingsBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.signoutButton setTitle:NSLocalizedString(@"user_profile_signout_lbl", @"") forState:UIControlStateNormal];
    
    [[DataManger sharedInstance] populateLanguagesFromBundle];
    [[DataManger sharedInstance] populateCountry];
    
    if (![ConfigManager isOfflineModeActive]) {
        [self.clearOfflinePackage setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.signoutButton.hidden = ![[UserManager sharedInstance] isLoggedIn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)openFeedback:(id)sender {
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_READ_POLICY_CLICK];
    }
#endif
}

- (void)openAboutPage:(id)sender {
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_READ_ABOUT_CLICK];
    }
#endif
}

- (void)openTermsConditions:(id)sender {
#ifdef USE_FLURRY
    
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_READ_TERMS_CLICK];
    }
#endif
}

- (IBAction)clearCache:(id)sender {
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_SETTING_CLEAR_CACHE];
    }
#endif
    [[AppCore sharedInstance] clearApplicationCache];
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                   message:NSLocalizedString(@"clear_cache_success", @"")
                         
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
    [alert show];
    
}


- (void)clearOfflinePackage:(id)sender{
    [[PackageManager sharedInstance] removeOfflinePackage:^{
        UIAlertView *removeSuccessFulAlert = [[UIAlertView alloc]initWithTitle:@"Package Information"
                                                                       message:@"You successfuly removed your offline package"
                                                                      delegate:self
                                                             cancelButtonTitle:@"Close"
                                                             otherButtonTitles:nil];
        [removeSuccessFulAlert show];
    }];
}

-(BOOL)needToggleCellForTitle:(NSString*)title{
    
    if ([title isEqualToString:NSLocalizedString(@"setting_title_allow_like_fb", @"")]) {
        return YES;
    }
    
    if ([title isEqualToString:NSLocalizedString(@"setting_title_allow_newsletter", @"")]) {
        return YES;
    }
    
    if ([title isEqualToString:NSLocalizedString(@"setting_title_usage_data", @"")]) {
        return YES;
    }
    
    if ([title isEqualToString:NSLocalizedString(@"setting_title_allow_pn", @"")]) {
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.settingsList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellBasic";
    static NSString *CellIdentifier2 = @"CellToggle";
    
    SettingCell * cell = nil;
    
    NSString * settingTitle = [self.settingsList objectAtIndex:indexPath.row];
    
    if ([self needToggleCellForTitle:settingTitle]) {
        cell = (SettingCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        
        if ([settingTitle isEqualToString:NSLocalizedString(@"setting_title_usage_data", @"")])
        {
            [cell setCellType:kDataCollect];
            [cell.settingToggle setOn:ANALYTICS_ENABLED];
            [cell.settingToggle setAccessibilityLabel:@"setting_title_usage_data_toggle"];
            [cell.settingName setAccessibilityLabel:@"setting_title_usage_data"];
        }
        
        if([settingTitle isEqualToString:NSLocalizedString(@"setting_title_allow_like_fb", @"")])
        {
            [cell.settingToggle setEnabled:[[UserManager sharedInstance] isLoggedIn]];
            [cell.settingToggle setOn:FACEBOOK_LIKE_ENABLED];
            [cell setCellType:kFBLikes];
            [cell.settingToggle setAccessibilityLabel:@"setting_title_allow_like_fb_toggle"];
            [cell.settingName setAccessibilityLabel:@"setting_title_allow_like_fb"];
        }
        
        if([settingTitle isEqualToString:NSLocalizedString(@"setting_title_allow_newsletter", @"")])
        {
            
            [cell.settingToggle setEnabled:[[UserManager sharedInstance] isLoggedIn]];
            [cell.settingToggle setOn:NEWSLETTER_ENABLED];
            [cell setCellType:kEmailsSend];
            [cell.settingToggle setAccessibilityLabel:@"setting_title_allow_newsletter_toggle"];
            [cell.settingName setAccessibilityLabel:@"setting_title_allow_newsletter"];
        }
        
        if([settingTitle isEqualToString:NSLocalizedString(@"setting_title_allow_pn", @"")])
        {
            [cell.settingToggle setEnabled:[[UserManager sharedInstance] isLoggedIn]];
            [cell.settingToggle setOn:PUSHNOTIFICATIONS_ENABLED];
            [cell setCellType:kPushCell];
            [cell.settingToggle setAccessibilityLabel:@"setting_title_allow_pn_toggle"];
            [cell.settingName setAccessibilityLabel:@"setting_title_allow_newsletter"];
        }
        
    } else {
        cell = (SettingCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    if (self.settingsList && indexPath.row < [self.settingsList count]) {
        NSString * settingName = [self.settingsList objectAtIndex:indexPath.row];
        if ([settingName isEqualToString:NSLocalizedString(@"setting_title_change_local", @"")]) {
            
            if ([[DataManger sharedInstance] isLangArray] > 0 && [[DataManger sharedInstance] getLangComponentIndex] > -1) {
                NSString * selectedLang = [[DataManger sharedInstance] getSelecectedLang];
                cell.settingName.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"setting_title_change_local", @""), selectedLang];
            }else{
                cell.settingName.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"setting_title_change_local", @""), [[DataManger sharedInstance] loadLanfFromDeviceStorage]];
            }
        }else{
            cell.settingName.text = [self.settingsList objectAtIndex:indexPath.row];
        }
        
        if ([settingName isEqualToString:NSLocalizedString(@"setting_title_change_country", @"")]) {
            
            if ([[DataManger sharedInstance] isLangArray] > 0 && [[DataManger sharedInstance] getCountryComponentIndex] > -1) {
                NSString * selectedCountry = [[DataManger sharedInstance] getSelecectedCountry];
                cell.settingName.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"setting_title_change_country", @""), selectedCountry];
            }else{
                cell.settingName.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"setting_title_change_country", @""), [[DataManger sharedInstance] loadCountryFromDeviceStorage]];
            }
        }else{
            cell.settingName.text = [self.settingsList objectAtIndex:indexPath.row];
        }
    }
    
    return  cell;
}

- (IBAction)signoutAction:(id)sender {
    if ([[UserManager sharedInstance] isLoggedIn]) {
        
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"signout_confirm_alert", @"")
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"alert_msg_button_yes", @"")
                          otherButtonTitles:NSLocalizedString(@"Nevermind", @""), nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView message] isEqualToString:NSLocalizedString(@"signout_confirm_alert", @"")]) {
        
        switch (buttonIndex) {
            case 0:
            {
#ifdef USE_UMENG
//                [MobClick profileSignOff];
#endif
//                [HSFlurry logAnalyticEvent:EVENT_NAME_SIGN_OUT];
                AppDelegate *delegate = (id)[UIApplication sharedApplication].delegate;
                [delegate clearSJJUserInfo];
                [[AppCore sharedInstance] logoutUser];
                [self.tableView reloadData];
                self.signoutButton.hidden = YES;
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
                 [NSNotification notificationWithName:kNotificationUserDidLogout object:nil userInfo:nil]];
                
            }   break;
            case 1:
                
                break;
            default:
                break;
        }
    }
}

- (void)closeSettings:(id)sender{
    //implemets in son's
}

#pragma mark - Class Function

-(void)showAlert{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                     message:NSLocalizedString(@"lang_action_take_affect", @"")
                                                    delegate:nil
                                           cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
    [alert show];
}

#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return  1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (_isLangDataLoaded) {
        if ([[DataManger sharedInstance] isLangArray]) {
            return  [[DataManger sharedInstance] getLangArrayCount];
        }else{
            return  0;
        }
    }else{
        if ([[DataManger sharedInstance] isCountryArray]) {
            return  [[DataManger sharedInstance] getCountryArrayCount];
        }else{
            return  0;
        }
        
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSLog(@"Selected Value");
    if (_isLangDataLoaded) {
        [[DataManger sharedInstance] setLangComponentIndex: row];
    }else{
        [[DataManger sharedInstance] setCountryComponentIndex: row];
        NSString * country = [[DataManger sharedInstance] getCountryAtIndex:row];
        [[DataManger sharedInstance] saveCountryToDeviceStorage:country];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (_isLangDataLoaded) {
        if ([[DataManger sharedInstance] isLangArray]) {
            return  [[DataManger sharedInstance] getLangAtIndex:row];
        }
    }else{
        if ([[DataManger sharedInstance] isCountryArray]) {
            return  [[DataManger sharedInstance] getCountryAtIndex:row];
        }
    }
    
    return @"";
}

-(IBAction)debug:(id)sender{
    if ([ConfigManager isDesginManagerLogActive]) {
        DebugViewController * dvc = [[DebugViewController alloc] initWithNibName:@"DebugViewController" bundle:nil];
        [self presentViewController:dvc animated:YES completion:nil];
    }
}

- (void)actionEmailComposer {
  
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        [mailViewController setSubject:NSLocalizedString(@"feedback_email_subject",@"Share with Homestyler Team")];
        
        // Attach an image to the email.
        
        NSMutableDictionary * dict=[[ConfigManager sharedInstance] getMainConfigDict];
        if(dict!=NULL){
            NSString* body;
    
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            NSString *userId = [[[UserManager sharedInstance] currentUser] userID];
            
            NSString *global = @"GL";
            if ([[[NSBundle mainBundle] bundleIdentifier] containsString:@"com.juran.homestyler"]) {
                global = @"CN";
            }
            
            NSString * dd = [UIDevice currentDevice].deviceName;
            NSString *osversion=[UIDevice currentDevice].systemVersion;
            
            NSString * wifi = [[ReachabilityManager sharedInstance] currentNetworkState];
            
            NSString *notice = @"http://www.homestyler.com/mobile";
            body=[NSString stringWithFormat:NSLocalizedString(@"Contact_Us", @""),[ConfigManager getAppName], version, global, dd, osversion, wifi,userId, notice];
      
            [mailViewController setMessageBody:body isHTML:NO];
            
            [mailViewController setToRecipients:[NSArray arrayWithObject:[[dict objectForKey:@"feedback"] objectForKey:@"toaddress"]]];
            
        }
        
        // Present the view controller
        [self presentViewController:mailViewController animated:YES completion:nil];
    }else{
        
        HSMDebugLog(@"Device is unable to send email in its current state.");
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"email_missing_default_msg",
                                                                                   @"Sorry no email account defined on this device")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        [alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult :(MFMailComposeResult)result error:  (NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(result != MFMailComposeResultCancelled)
    {
        
    }
}
@end
