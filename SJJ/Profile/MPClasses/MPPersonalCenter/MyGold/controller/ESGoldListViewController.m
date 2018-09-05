//
//  ESGoldListViewController.m
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESGoldListViewController.h"
#import "ESDiyRefreshHeader.h"
#import "MBProgressHUD+NJ.h"
#import "ESMyGoldTableViewCell.h"
#import "ESMyGoldHeaderFooterView.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESOrderAPI.h"
#import "ESOrderDetailViewController.h"
#import "ESGoldPayTableViewCell.h"
#import "ESGoldPayTableViewCell.h"
#import <ESNetworking/SHRequestTool.h>
#import <ESMallAssets.h>

@interface ESGoldListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datasSource;
@property (copy, nonatomic) NSString *myType;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;

@end

@implementation ESGoldListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pageNum = 0;
    _pageSize = 10;
    _datasSource = [NSMutableArray array];
    [self setTableView];
}

- (void)setType:(NSString *)type {
    _myType = type;
}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-DECORATION_SEGMENT_HEIGHT+10) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESMyGoldTableViewCell" bundle:nil] forCellReuseIdentifier:@"ESMyGoldTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGoldPayTableViewCell" bundle:nil] forCellReuseIdentifier:@"ESGoldPayTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESMyGoldHeaderFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"ESMyGoldHeaderFooterView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_tableView];
    WS(weakSelf)
    _tableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
    
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf nextpage];
    }];
    [self refresh];
}

- (void)refresh {
    _pageNum = 0;
    [self requestData];
}

- (void)nextpage {
    _pageNum = _pageNum+10;
    [self requestData];
}

-(void)requestData{
    WS(weakSelf)
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESOrderAPI getMyGoldListWithType:_myType pageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
        SHLog(@"++++++%@",dict);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if ([[dict objectForKey:@"list"] isKindOfClass:[NSArray class]]) {
            NSArray *orderArray = [dict objectForKey:@"list"];
            if (weakSelf.pageNum==0) {
                [weakSelf.datasSource removeAllObjects];
            }
            if (orderArray.count > 0) {
                for (NSDictionary *dic in orderArray) {
                    [_datasSource addObject:dic];
                }
            }
        }
        [_tableView reloadData];
        NSString *hasNextPage = [NSString stringWithFormat:@"%@", [dict objectForKey:@"hasNextPage"]];
        [weakSelf endLoading];
        if ([hasNextPage isEqualToString:@"0"]) {
            [_tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        if (_datasSource.count == 0) {
            [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_datas" frame:_tableView.frame Title:@"啊哦~暂时没有数据~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf endLoading];
        if (_datasSource.count == 0) {
            [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_net" frame:_tableView.frame Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf.tableView.mj_header beginRefreshing];
            }];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
        }
    }];
    
}

- (void)endLoading {
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _datasSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;//_datasSource.count;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESMyGoldHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESMyGoldHeaderFooterView"];
    if ([_myType isEqualToString:@"1"] && 0 == section) {
        [header setTitle:@"活动期间订单较多，支付成功后，返现将在60分钟内返回至您的账户中。" backgroundColor:[UIColor stec_redBackgroundColor] ];
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([_myType isEqualToString:@"1"] && 0 == section) {
        return 60;
    } else {
        return 0.0001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_myType isEqualToString:@"1"]) {
        return 146;
    } else {
        return 130;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_myType isEqualToString:@"1"]) {
        ESMyGoldTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMyGoldTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_datasSource.count>indexPath.section) {
            NSDictionary *dic = _datasSource[indexPath.section];
            [cell setType:_myType info:dic block:^{
                SHLog(@"进入订单");
                NSString *orderIdStr = [NSString stringWithFormat:@"%@",dic[@"orderId"] ? dic[@"orderId"] : @""];
                ESOrderDetailViewController *orderDetailViewCon = [[ESOrderDetailViewController alloc] init];
                [orderDetailViewCon setOrderId:orderIdStr Block:nil];
                [self.navigationController pushViewController:orderDetailViewCon animated:YES];
                
            }];
        }
        return cell;
    } else {
        
        ESGoldPayTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESGoldPayTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_datasSource.count>indexPath.section) {
            NSDictionary *dic = _datasSource[indexPath.section];
            [cell setType:_myType info:dic block:^{
                SHLog(@"进入订单");
                NSString *orderIdStr = [NSString stringWithFormat:@"%@",dic[@"orderId"] ? dic[@"orderId"] : @""];
                ESOrderDetailViewController *orderDetailViewCon = [[ESOrderDetailViewController alloc] init];
                [orderDetailViewCon setOrderId:orderIdStr Block:nil];
                [self.navigationController pushViewController:orderDetailViewCon animated:YES];
                
            }];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
