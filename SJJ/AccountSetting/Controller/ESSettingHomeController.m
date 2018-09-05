//
//  ESSettingHomeController.m
//  Homestyler
//
//  Created by shiyawei on 28/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESSettingHomeController.h"
#import "ESModifyPasswordController.h"
#import "ESRegisterViewController.h"
#import "ESChangeUserRoleController.h"

#import "ESAccountSettingTableCell.h"


@interface ESSettingHomeController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)    UITableView *tableView;
@end

@implementation ESSettingHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账号设置";
    [self.view addSubview:self.tableView];
}






#pragma mark --- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESAccountSettingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESAccountSettingTableCellS"];
    if (!cell) {
        cell = [[ESAccountSettingTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ESAccountSettingTableCellS"];
    }
    
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"修改密码";
        cell.subLabel.text = @"";
        cell.detailLabel.text = @"";
        cell.cellType = ESAccountSettingTableCellTypeAccessory;
    }else if (indexPath.row == 1) {
        cell.titleLabel.text = @"绑定";
        NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"Account"];
        if ([CoStringManager isEmptyString:phone]) {
            phone = [JRKeychain loadSingleUserInfo:UserInfoCodePhone];
        }
        
        NSString *str = [phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        cell.subLabel.text = str;
//        cell.detailLabel.text = @"修改绑定";
        cell.cellType = ESAccountSettingTableCellTypeNone;
    }else {
        cell.cellType = ESAccountSettingTableCellTypeAccessory;
        cell.titleLabel.text = @"角色管理";
        cell.subLabel.text = @"";
        NSString *role = [JRKeychain loadSingleUserInfo:UserInfoCodeType];
        if ([role isEqualToString:@"designer"]) {
            cell.detailLabel.text = @"当前角色：设计师";
        }else {
            cell.detailLabel.text = @"当前角色：业主";
        }
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ESModifyPasswordController *modifyPSDVC = [[ESModifyPasswordController alloc] init];
        [self.navigationController pushViewController:modifyPSDVC animated:YES];
    }else if (indexPath.row == 1) {
//        ESRegisterViewController *registerVC = [[ESRegisterViewController alloc] init];
//        registerVC.titleName = @"绑定手机";
//        [self.navigationController pushViewController:registerVC animated:YES];
//        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:registerVC];
//        [self presentViewController:navVC animated:YES completion:nil];
    }else {
        ESChangeUserRoleController *changeRole = [[ESChangeUserRoleController alloc] init];
        [self.navigationController pushViewController:changeRole animated:YES];
    }
}


#pragma mark --- 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = self.view.backgroundColor;
        [_tableView registerClass:[ESAccountSettingTableCell class] forCellReuseIdentifier:@"ESAccountSettingTableCellS"];
    }
    return _tableView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
