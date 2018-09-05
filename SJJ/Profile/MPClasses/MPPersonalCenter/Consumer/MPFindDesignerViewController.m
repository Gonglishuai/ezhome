//
//  MPFindDesignerViewController.m
//  Consumer
//
//  Created by Zhangzz on 16/8/18.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "MPFindDesignerViewController.h"

@interface MPFindDesignerViewController ()

@end

@implementation MPFindDesignerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"找设计师";
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    self.view.backgroundColor = COLOR(238, 241, 244, 1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
