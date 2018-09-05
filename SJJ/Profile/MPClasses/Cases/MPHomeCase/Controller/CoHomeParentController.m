//
//  CoHomePublicController.m
//  Consumer
//
//  Created by 董鑫 on 16/8/29.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoHomeParentController.h"

@interface CoHomeParentController ()<ESLoginManagerDelegate>

@end

@implementation CoHomeParentController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[ESLoginManager sharedManager] addLoginDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.navgationImageview];
}

- (void)refreshView {
    
}

- (void)dealloc {
    [[ESLoginManager sharedManager] removeLoginDelegate:self];
}

#pragma mark - ESLoginManagerDelegate
- (void)onLogin {
    [self refreshView];
}

- (void)onLogout {
    [self refreshView];
}

@end
