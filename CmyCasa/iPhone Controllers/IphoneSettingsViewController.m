//
//  iphoneSettingsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import "IphoneSettingsViewController.h"
#import "UIViewController+Helpers.h"


@interface IphoneSettingsViewController ()

@end

@implementation IphoneSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.signoutButton.hidden = ![[UserManager sharedInstance] isLoggedIn];
    self.settingsList = [NSMutableArray arrayWithCapacity:0];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_privacy", @"")];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_about", @"")];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_terms", @"")];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_clear_cache", @"")];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_change_local", @"")];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_allow_pn", @"")];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_allow_like_fb", @"")];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_allow_newsletter", @"")];
    [self.settingsList addObject:NSLocalizedString(@"setting_title_usage_data", @"")];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *env = [[ConfigManager sharedInstance] configEnvironment];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *label = [NSString stringWithFormat:@"v%@.%@%@",version, build,env];
    
    [self.settingsList addObject:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[[UIMenuManager sharedInstance] iphonePanelController]setIsLandscakeOK:PANEL_ROTATION_FLAG_NO];
    
    [[[UIMenuManager sharedInstance] iphonePanelController]setIsMenuOpenAllowed:YES];
    
    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[[UIMenuManager sharedInstance] iphonePanelController]unsetIsLandscapeOK:PANEL_ROTATION_FLAG_NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (BOOL)shouldAutorotate{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIInterfaceOrientationIsPortrait(orientation) || (orientation == UIDeviceOrientationUnknown);
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50; //returns floating point which will be used for a cell row height at specified row index
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
        {
            if (![self isConnectionAvailable]) {
                return;
            }
            [super openFeedback:nil];
            GenericWebViewBaseViewController * iWeb=[[UIGalleryManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] privacyLink]];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:iWeb animated:YES completion:nil];
            });
        }
            break;
            
        case 1:
        {
            [self openAboutPage:nil];
            
            [[UIMenuManager sharedInstance] openAboutPageIphonePressed:self];
        }
            break;
            
        case 2:
        {
            if (![self isConnectionAvailable]) {
                return;
            }
            
            [self openTermsConditions:nil];
            
            GenericWebViewBaseViewController * iWeb = [[UIGalleryManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] termsLink]];
        
            [self presentViewController:iWeb animated:YES completion:nil];
        }
            break;
            
        case 3:
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                           message:NSLocalizedString(@"clear_cache_success", @"")
                                 
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
            [alert show];
        }
            break;
            
        case 4:
        {
            //picker show language
            [self showPicker];
        }
            break;
            
        default:
            break;
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (IBAction)openMenu:(id)sender {
    self.tableView.userInteractionEnabled=NO;
    [[UIMenuManager sharedInstance] openMenuIphone:self withCompletion:^(BOOL isClosed) {
        
        self.tableView.userInteractionEnabled=isClosed;
    }];
}

-(void)changeLanguage:(id)sender{
    self.tableView.userInteractionEnabled = YES;
    NSString * langSymbole =  [_languagesSymboleArray objectAtIndex:self.selectedComponentIndex];
    
    if (langSymbole) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:langSymbole forKey:@"lang_symbole"];
        [defaults synchronize];
    }
    
    //update selection
    [self.tableView reloadData];

    [self hidePicker];
    
    [self showAlert];
}

-(void)showPicker{
    if (!_isPickerShowen)
    {
        self.tableView.userInteractionEnabled = NO;
        [self.filterPicker reloadAllComponents];
        [self.filterPicker selectRow:self.selectedComponentIndex inComponent:0 animated:NO];
        
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
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
        [self.filterPicker selectRow:self.selectedComponentIndex inComponent:0 animated:NO];
    }
}

- (void)cancelPicker:(id)sender {
    
    self.selectedComponentIndex = 0;
    self.tableView.userInteractionEnabled = YES;
    [self hidePicker];
}

-(void)hidePicker{
    if (_isPickerShowen) {
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        
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


