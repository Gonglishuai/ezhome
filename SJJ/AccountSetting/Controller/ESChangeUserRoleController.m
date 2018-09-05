//
//  ESChangeUserRoleController.m
//  Homestyler
//
//  Created by shiyawei on 28/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESChangeUserRoleController.h"
#import "ESAccountSettingTableCell.h"

#import "ESLoginAPI.h"

@interface ESChangeUserRoleController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)    UITableView *tableView;
@property (nonatomic,copy)    NSString *role;
@end

@implementation ESChangeUserRoleController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"角色管理";
    self.role = [JRKeychain loadSingleUserInfo:UserInfoCodeType];
    
    [self.view addSubview:self.tableView];
}

- (void)showAlertView {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定切换角色吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"切换" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([self.role isEqualToString:@"designer"]) {
            [self changeRoleType:@"member"];
        }else if ([self.role isEqualToString:@"member"] || self.role.length == 0) {
            [self changeRoleType:@"designer"];
        }else {
            return;
        }
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];
    
    [self.navigationController presentViewController:alertVC animated:YES completion:nil];
}

- (void)changeRoleType:(NSString *)role {
    [ESMBProgressToast showToastAddTo:self.view];
    [ESLoginAPI changeMemberType:role andSuccess:^(NSDictionary *dict) {
        [ESMBProgressToast hideToastForView:self.view];
        SHLog(@"dict %@",dict);
        [JRKeychain saveSingleInfo:role infoCode:UserInfoCodeType];
//        [self.navigationController popToRootViewControllerAnimated:YES];
        
        AppDelegate *delegate = (id)[UIApplication sharedApplication].delegate;
        [delegate gotoSJJ];
        
    } andFailure:^(NSError *error) {
        [ESMBProgressToast hideToastForView:self.view];
        NSString *text = [ESLoginAPI errMessge:error];
        [ESMBProgressToast showToastAddTo:self.view text:text];
        SHLog(@"error %@",error);
    }];
}

#pragma mark --- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESAccountSettingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESAccountSettingTableCellC" forIndexPath:indexPath];
    cell.cellType = ESAccountSettingTableCellTypeSlected;
    
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"设计师";
        if ([self.role isEqualToString:@"designer"]) {
            cell.isSelected = YES;
        }
        
    }else {
        cell.titleLabel.text = @"业主";
        if ([self.role isEqualToString:@"member"] || self.role.length == 0) {
            cell.isSelected = YES;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ESAccountSettingTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell.isSelected) {
        [self showAlertView];
        
    }
    
}
#pragma mark --- 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.tableFooterView = [UIView new];
        
        [_tableView registerClass:[ESAccountSettingTableCell class] forCellReuseIdentifier:@"ESAccountSettingTableCellC"];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
