//
//  iphoneProfessionalDetailsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/5/13.
//
//

#import "ProfessionalDetailsViewController_iPhone.h"
#import "UILabel+Size.h"

@interface ProfessionalDetailsViewController_iPhone ()

@end

@implementation ProfessionalDetailsViewController_iPhone
@synthesize professional;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (professional && professional.isExtraInfoLoaded) {
        //fill fields
        
        if ([self.professional.phone1 length]>0) {
            [self.phone1 setTitle:self.professional.phone1 forState:UIControlStateNormal];
        }else{
            [self.phone1 setTitle:@"" forState:UIControlStateNormal];
        }
        
        if ([self.professional.phone2 length]>0) {
            
            [self.phone2 setTitle:self.professional.phone2 forState:UIControlStateNormal];
        }else{
            [self.phone2 setTitle:@"" forState:UIControlStateNormal];
        }
        
        NSString* name = [NSString stringWithFormat:@"%@ %@", self.professional.firstName, self.professional.lastName];
        
        self.progStudioName.text=name;
        
        CGSize size=[self.progStudioName getActualTextHeightForLabel:44];
        
        self.progStudioName.frame=CGRectMake(self.progStudioName.frame.origin.x,
                                             self.progStudioName.frame.origin.y,
                                             self.progStudioName.frame.size.width, size.height);
        
        
        NSArray* profs = professional.professions;
        NSString* professions = @"";
        for(NSString* profession in profs) {
            professions = [professions stringByAppendingString:profession];
            professions = [professions stringByAppendingString:@", "];
        }
        
        if ([professions length] > 2) {
            professions = [professions substringToIndex:[professions length]-2];
        }
        
        self.professionsTitle.text = professions;
        
        size = [self.professionsTitle getActualTextHeightForLabel:44];
        
        self.professionsTitle.frame = CGRectMake(self.professionsTitle.frame.origin.x,
                                                 self.progStudioName.frame.origin.y+self.progStudioName.frame.size.height+5,
                                                 self.professionsTitle.frame.size.width, size.height);
        
        
        self.profAddress.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"prof_details_address_title", @""),self.professional.address];
        size=[self.profAddress getActualTextHeightForLabel:44];
        
        self.profAddress.frame=CGRectMake(self.profAddress.frame.origin.x,
                                          self.profAddress.frame.origin.y,
                                          self.profAddress.frame.size.width, size.height);
        
        [[GalleryServerUtils sharedInstance] loadImageFromUrl:self.profileImage url:self.professional.userPhoto];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)navBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc{
    NSLog(@"dealloc - ProfessionalDetailsViewController_iPhone");
}

- (IBAction)openWebsite:(id)sender {
    
    if (!self.professional.web)
        return;
    
    NSString * _webSiteUrl = self.professional.web;
    
    if ([_webSiteUrl hasPrefix:@"http://"] == NO && [_webSiteUrl hasPrefix:@"https://"] == NO) {
        _webSiteUrl= [NSString stringWithFormat:@"http://%@", _webSiteUrl];
    }
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
        NSArray * objs=[NSArray arrayWithObjects:self.professional._id,_webSiteUrl, nil];
        NSArray * keys=[NSArray arrayWithObjects:@"prof_id",@"url", nil];
        
//        [HSFlurry logEvent:FLURRY_PROFESIONAL_SITE_VISIT withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
    
    NSString* urlWithReferer = [[ConfigManager sharedInstance] updateURLStringWithReferer:_webSiteUrl];
    
    GenericWebViewBaseViewController * web = [[UIManager sharedInstance]createGenericWebBrowser:urlWithReferer];
    [self presentViewController:web animated:YES completion:nil];
}

- (IBAction)openEmail:(id)sender {
    
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"email_missing_default_msg",
                                                                                 @"Sorry no email account defined on this device")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        [alert show];
        return;
    }
    
    if ([self.professional.email length] < 5)
    {
        
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"email_missing_prof_page",
                                                                                 @"Sorry this professional doesn't have email configured")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        [alert show];
        return;
    }
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
        NSArray * objs=[NSArray arrayWithObjects:self.professional._id, nil];
        NSArray * keys=[NSArray arrayWithObjects:@"prof_id", nil];
        
//        [HSFlurry logEvent:FLURRY_PROFESIONAL_EMAIL_WRITE withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:NSLocalizedString(@"prof_email_subject", @"Homestyler Professional Enquiry")];
    
    NSArray *toRecipients = [NSArray arrayWithObjects:self.professional.email, nil];
    [mailer setToRecipients:toRecipients];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:mailer animated:YES completion:nil];
    });
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            HSMDebugLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            HSMDebugLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            HSMDebugLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            HSMDebugLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            HSMDebugLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)callNumber:(id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton * btn = (UIButton*)sender;
        NSString * phone = [NSString stringWithFormat:@"tel://%@", btn.titleLabel.text];
        phone = [phone stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSURL *phoneUrl = [NSURL URLWithString:phone];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
        }else {
            UIAlertView * calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [calert show];
        }
    }
}

@end
