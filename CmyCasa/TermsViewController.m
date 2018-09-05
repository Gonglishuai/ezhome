//
//  TermsViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 12/28/12.
//
//

#import "TermsViewController.h"
#import "LoginDefs.h"

@interface TermsViewController ()

@end

@implementation TermsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:[[ConfigManager sharedInstance] termsLink]];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
