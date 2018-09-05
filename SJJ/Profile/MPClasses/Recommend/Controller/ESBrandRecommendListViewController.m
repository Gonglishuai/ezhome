//
//  ESBrandRecommendListViewController.m
//  Consumer
//
//  Created by jiang on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESBrandRecommendListViewController.h"
#import "MJRefresh.h"
#import "MBProgressHUD+NJ.h"
#import "ESRecommendAPI.h"
#import "ESBrandRecommendDetailViewController.h"
#import "ESRecommendListTableViewCell.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESRecommendSearchViewController.h"
#import "ESMallAssets.h"

@interface ESBrandRecommendListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (nonatomic,strong)NSMutableArray *datasSourse;


@end

@implementation ESBrandRecommendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pageNum = 0;
    _pageSize = 10;
    _datasSourse = [NSMutableArray array];
    [self setTableView];
    [self getData];
    
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)tapOnRightButton:(id)sender {
    ESRecommendSearchViewController *recommendSearchViewCon = [[ESRecommendSearchViewController alloc] init];
    [self.navigationController pushViewController:recommendSearchViewCon animated:YES];
}

- (void)refresh {
    _pageNum = 0;
    [self getData];
}

- (void)nextpage {
    _pageNum = _pageNum+10;
    [self getData];
}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-DECORATION_SEGMENT_HEIGHT+10) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESRecommendListTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ESRecommendListTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 120.0f;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_tableView];
    WS(weakSelf)
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
    
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf nextpage];
    }];
}

- (void)getData {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESRecommendAPI getBrandRecommendListWithName:@"" pageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.tableView.mj_header endRefreshing];
        if (weakSelf.pageNum==0) {
            [weakSelf.datasSourse removeAllObjects];
        }
        NSArray *list = dict[@"list"] ? dict[@"list"] : [NSArray array];
        if ([list isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in list) {
                [weakSelf.datasSourse addObject:dic];
            }
        }
        
        [weakSelf.tableView reloadData];
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_datas" frame:weakSelf.tableView.bounds Title:@"暂时还没有任何推荐哦~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
        NSInteger recordSetTotal = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"total"]] integerValue];
        if (weakSelf.datasSourse.count >= recordSetTotal) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        SHLog(@"%@", error);
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_net" frame:weakSelf.tableView.bounds Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf.tableView.mj_header beginRefreshing];
            }];
        } else {
            [MBProgressHUD showError:@"请求失败"];
        }
        if (weakSelf.pageNum >= 10) {
            weakSelf.pageNum= weakSelf.pageNum - 10;
        }
    }];
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _datasSourse.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        return 0.001;
    }
    return 10;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [header setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return header;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [header setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return header;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESRecommendListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESRecommendListTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section < _datasSourse.count) {
        NSDictionary *info = [_datasSourse objectAtIndex:indexPath.section];
        [cell setInfo:info isBrand:YES];
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section < _datasSourse.count) {
        NSDictionary *info = [_datasSourse objectAtIndex:indexPath.section];
        ESBrandRecommendDetailViewController *recommendDetailViewCon = [[ESBrandRecommendDetailViewController alloc]init];
        NSString *recommendId = [NSString stringWithFormat:@"%@", info[@"recommendsBrandId"] ? info[@"recommendsBrandId"] : @""];
        [recommendDetailViewCon setRecommendId:recommendId];
        [self.navigationController pushViewController:recommendDetailViewCon animated:YES];
    }
    
    
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

