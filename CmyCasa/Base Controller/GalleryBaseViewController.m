//
//  GalleryBaseViewController.m
//  Homestyler
//
//  Created by xiefei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "GalleryBaseViewController.h"
#import "ControllersFactory.h"
#import "CustomNavigationController.h"

@interface GalleryBaseViewController ()

@end

@implementation GalleryBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //now Menu can push/ pop App sections
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)toDIY:(id)sender {
    if ([self.delegate respondsToSelector:@selector(changeApp:)]) {
        [self.delegate changeApp:APP_DIY];
    }
}

- (IBAction)toSJJ:(id)sender {
    if ([self.delegate respondsToSelector:@selector(changeApp:)]) {
        [self.delegate changeApp:APP_SJJ];
    }
}


@end
