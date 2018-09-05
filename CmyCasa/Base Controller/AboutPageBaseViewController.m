//
//  AboutPageBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import "AboutPageBaseViewController.h"

@interface AboutPageBaseViewController ()

@end

@implementation AboutPageBaseViewController
@synthesize isTermsScreen;

-(void)viewWillAppear:(BOOL)animated {
    if (!CGAffineTransformIsIdentity(self.parentViewController.view.transform)) {
        CGPoint p = self.parentViewController.view.center;
        self.view.center = CGPointMake(p.y, p.x);
    } else {
        self.view.center = self.parentViewController.view.center;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.frame = [UIScreen currentScreenBoundsDependOnOrientation];
    
    NSMutableDictionary * dict=[[ConfigManager sharedInstance] getMainConfigDict];
    if(dict!=NULL){
    
        if (isTermsScreen) {
            self.aboutPageTitle.text=NSLocalizedString(@"page_title_terms2",@"Terms and Conditions");
            [self.aboutPageTitle setHidden:YES];
            [self.termsPageTitle setHidden:NO];
            
            self.termsLayout.hidden=NO;
        
            NSURL *url = [NSURL URLWithString:[[ConfigManager sharedInstance] termsLink]];
            
            //URL Requst Object
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            
            //Load the request in the UIWebView.
            [self.termsWebview loadRequest:requestObj];
            
        }else{
            NSString* path = [[NSBundle mainBundle] pathForResource:@"about"
                                                             ofType:@"txt"];
            NSString * loadedText = [NSString stringWithContentsOfFile:path
                                                              encoding:NSUTF8StringEncoding
                                                                 error:NULL];

            self.aboutCopy.text = loadedText;
            self.aboutPageTitle.text=NSLocalizedString(@"page_title_about2",@"About");
            
            [self.aboutPageTitle setHidden:NO];
            [self.termsPageTitle setHidden:YES];
        }
    }
}

- (IBAction)closeAboutPage:(id)sender {
    
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (IBAction)navBackIphone:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
