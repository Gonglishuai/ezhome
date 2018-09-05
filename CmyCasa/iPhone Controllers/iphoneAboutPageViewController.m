//
//  iphoneAboutPageViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import "iphoneAboutPageViewController.h"

@interface iphoneAboutPageViewController ()

@end

@implementation iphoneAboutPageViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:NO];
}

@end
