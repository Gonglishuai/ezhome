//
//  MPCaseScreenViewController.m
//  MarketPlace
//
//  Created by xuezy on 16/2/23.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import "MPCaseScreenViewController.h"
#import "MPCaseScreenView.h"
@interface MPCaseScreenViewController ()<caseScreenViewDelegate>
{
    NSMutableDictionary *typeDict;
    MPCaseScreenView *caseScreenView;
}
@end

@implementation MPCaseScreenViewController
- (NSMutableDictionary *)selectDict {
    if (_selectDict == nil) {
        _selectDict = [NSMutableDictionary dictionary];
    }
    return _selectDict;
}

- (NSMutableDictionary *)selectTypeDict {
    if (_selectTypeDict == nil) {
        _selectTypeDict = [NSMutableDictionary dictionary];
    }
    return _selectTypeDict;
}

/// Rewrite the superclass showMenu method.
- (void)tapOnLeftButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleLabel.text = @"筛选";
    typeDict = [NSMutableDictionary dictionary];
    self.rightButton.hidden = YES;
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self createCaseScreenView];
    
    
    UIButton * cancelBtn  = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width/2, 50)];
    cancelBtn.backgroundColor = [UIColor redColor];
    [cancelBtn setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"重置" forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelBtn) forControlEvents:UIControlEventTouchUpInside];
    

    UIButton * doneBtn  = [[UIButton alloc]initWithFrame:CGRectMake((self.view.bounds.size.width/2), self.view.bounds.size.height-50, self.view.bounds.size.width/2, 50)];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    doneBtn.backgroundColor = [UIColor stec_ableButtonBackColor];
    [self.view addSubview:doneBtn];
    [doneBtn addTarget:self action:@selector(doneBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * colView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width/2, 1)];
    colView.backgroundColor = [UIColor stec_viewBackgroundColor];
    [self.view addSubview:colView];

}

- (void)cancelBtn
{
    [self.selectDict removeAllObjects];
    [self.selectDict setObject:@(0) forKey:@(0)];
    [self.selectDict setObject:@(0) forKey:@(1)];
    [self.selectDict setObject:@(0) forKey:@(2)];
    [self.selectTypeDict setObject:@"全部" forKey:@"风格"];
    [self.selectTypeDict setObject:@"全部" forKey:@"户型"];
    [self.selectTypeDict setObject:@"全部" forKey:@"面积"];
    [caseScreenView refreshTableViewWithSelect:self.selectDict];
}

- (void)doneBtn
{
    [self.delegate selectedClassificationDict:self.selectTypeDict withSelectDict:self.selectDict];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createCaseScreenView {
    SHLog(@"选中的信息:%@",self.selectDict);

    caseScreenView = [[MPCaseScreenView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-50) withSelectDict:self.selectDict withSelectionType:self.selectionsStr];
    caseScreenView.delegate = self;
    [self.view addSubview:caseScreenView];
    
}

- (void)didSelectType:(NSString *)buttonTitle type:(NSString *)type  withSelectCellSection:(NSMutableDictionary *)cellSectionDict{
    SHLog(@"%@_______%@",buttonTitle,type);
    [self.selectTypeDict setObject:buttonTitle forKey:type];
    self.selectDict = cellSectionDict;

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
