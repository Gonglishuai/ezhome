//
//  ESRecommendOrderListViewController.m
//  Consumer
//
//  Created by jiang on 2018/1/4.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommendOrderListViewController.h"
#import "ESRecommendAPI.h"
#import "ESOrderDetailViewController.h"

#import "ESOrderListProductCell.h"
#import "ESSeparatePriceCell.h"
#import "ESRecommendOrderHeaderView.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "MJRefresh.h"
#import "MBProgressHUD+NJ.h"
#import "ESMallAssets.h"


@interface ESRecommendOrderListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datasSource;
@property (copy, nonatomic) NSString *myType;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;

@end

@implementation ESRecommendOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navgationImageview.hidden = YES;
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    _pageNum = 0;
    _pageSize = 10;
    _datasSource = [NSMutableArray array];
    [self setTableView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_datasSource == nil || _datasSource.count == 0) {
        [_tableView.mj_header beginRefreshing];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setType:(NSString *)type {
    _myType = type;
}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-DECORATION_SEGMENT_HEIGHT+10) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESOrderListProductCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderListProductCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESSeparatePriceCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESSeparatePriceCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESRecommendOrderHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"ESRecommendOrderHeaderView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 100.0f;
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
    [ESRecommendAPI getRecommendOrderListWithName:@"" OrderType:_myType pageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
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
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
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
    NSDictionary *orderDic = _datasSource[section];
    NSArray *array = [orderDic objectForKey:@"itemList"];
    //    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"", @"", nil];
    NSString *orderState = [NSString stringWithFormat:@"%@", [orderDic objectForKey:@"orderStatus"]];
    NSString *canRefund = [NSString stringWithFormat:@"%@", [orderDic objectForKey:@"canRefund"]];
    if ([orderState isEqualToString:@"50"] || [orderState isEqualToString:@"51"] || [canRefund isEqualToString:@"0"]) {//交易关闭
        return array.count+1;
    } else {
        return array.count+1;
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESRecommendOrderHeaderView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESRecommendOrderHeaderView"];
    NSDictionary *orderDic = _datasSource[section];
    NSString * brandName = [NSString stringWithFormat:@"%@", orderDic[@"brandName"] ? orderDic[@"brandName"] : @""];
    NSString *avatar = [NSString stringWithFormat:@"%@", orderDic[@"consumerAvatar"] ? orderDic[@"consumerAvatar"] : @""];
    NSString *nickName = [NSString stringWithFormat:@"%@", orderDic[@"consumerName"] ? orderDic[@"consumerName"] : @""];
    NSString *phoneNum = [NSString stringWithFormat:@"%@", orderDic[@"consumerMobile"] ? orderDic[@"consumerMobile"] : @""];
    NSString *subTitle = @"";
    UIColor *subTitleColor = [UIColor stec_subTitleTextColor];
    
    NSString *orderState = [NSString stringWithFormat:@"%@", [orderDic objectForKey:@"orderStatus"]];
    if ([orderState isEqualToString:@"10"] ||
        [orderState isEqualToString:@"15"] ||
        [orderState isEqualToString:@"16"]) {//未支付 部分支付
        subTitle = @"待支付";
        subTitleColor = [UIColor stec_redTextColor];
    } else if ([orderState isEqualToString:@"20"]) {//已支付
        subTitle = @"已支付";
        subTitleColor = [UIColor stec_subTitleTextColor];
    } else if ([orderState isEqualToString:@"40"] || [orderState isEqualToString:@"41"]) {//交易完成
        subTitle = @"交易完成";
        subTitleColor = [UIColor stec_subTitleTextColor];
    } else {//交易关闭
        subTitle = @"交易关闭";
        subTitleColor = [UIColor stec_subTitleTextColor];
    }
    [header setAvatar:avatar name:nickName phone:phoneNum Title:brandName subTitle:subTitle subTitleColor:subTitleColor phoneBlock:^(NSString *phoneNum) {
        if (phoneNum.length>0) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        } else {
            [MBProgressHUD showError:@"手机号码为空"];
        }
    }];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *orderDic = _datasSource[indexPath.section];
    NSArray *array = [orderDic objectForKey:@"itemList"];
    
    //    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"", @"", nil];
    
    if (indexPath.row < array.count) {
        NSDictionary *skuDic = [array objectAtIndex:indexPath.row];
        ESOrderListProductCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderListProductCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *orderType = [NSString stringWithFormat:@"%@", [orderDic objectForKey:@"orderType"]];
        [cell setProductInfo:skuDic orderType:orderType];
        
        return cell;
    } else {
        NSInteger num = 0;
        for (NSDictionary *dic in array) {
            NSString *numm = dic[@"itemQuantity"] ? dic[@"itemQuantity"] : @"1";
            num = num + [numm integerValue];
        }
        ESSeparatePriceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESSeparatePriceCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        double pay = [[NSString stringWithFormat:@"%@", (orderDic[@"payAmount"] ? orderDic[@"payAmount"] : @"0.00")] doubleValue];
        
        double pay = [[NSString stringWithFormat:@"%@", (orderDic[@"payAmount"] ? orderDic[@"payAmount"] : @"0.00")] doubleValue];
        
        NSString *payAccount = @"";
        if (pay > 10000000.0) {
            payAccount = [NSString stringWithFormat:@"￥%@万",[NSString stringWithFormat:@"%.2f",pay/10000.0]];
        } else {
            payAccount = [NSString stringWithFormat:@"￥%@",[NSString stringWithFormat:@"%.2f",pay]];
        }
        
        //已支付
        double paidAmount = [[NSString stringWithFormat:@"%@", (orderDic[@"paidAmount"] ? orderDic[@"paidAmount"] : @"0.00")] doubleValue];
        NSString *payedAccount = @"";
        if (paidAmount > 10000000.0) {
            payedAccount = [NSString stringWithFormat:@"￥%@万",[NSString stringWithFormat:@"%.2f",paidAmount/10000.0]];
        } else {
            payedAccount = [NSString stringWithFormat:@"￥%@",[NSString stringWithFormat:@"%.2f",paidAmount]];
        }
        
        //剩余支付
        double unPaidAmount = [[NSString stringWithFormat:@"%@", (orderDic[@"unPaidAmount"] ? orderDic[@"unPaidAmount"] : @"0.00")] doubleValue];
        NSString *unpayAccount = @"";
        if (unPaidAmount > 10000000.0) {
            unpayAccount = [NSString stringWithFormat:@"￥%@万",[NSString stringWithFormat:@"%.2f",unPaidAmount/10000.0]];
        } else {
            unpayAccount = [NSString stringWithFormat:@"￥%@",[NSString stringWithFormat:@"%.2f",unPaidAmount]];
        }
        
        //[cell setTitle:[NSString stringWithFormat:@"共%ld件商品 合计", (long)num] subTitle:payAccount];
        NSString *orderType = [NSString stringWithFormat:@"%@", [orderDic objectForKey:@"orderType"]];
        unpayAccount = unPaidAmount > 0 ? unpayAccount : @"";
        NSString *descTitle = @"";
        if ([orderType isEqualToString:@"0"]) {
            if (paidAmount > 0) {
                descTitle = [NSString stringWithFormat:@"定金%@ (已付 %@)", payAccount, payedAccount];
            } else {
                descTitle = [NSString stringWithFormat:@"定金%@", payAccount];
            }
        } else {
            if (paidAmount > 0) {
                descTitle = [NSString stringWithFormat:@"共%ld件商品 合计%@ (已付 %@)", (long)num, payAccount, payedAccount];
            } else {
                descTitle = [NSString stringWithFormat:@"共%ld件商品 合计%@", (long)num, payAccount];
            }
        }
        
        [cell setTitle:@"剩余支付" subTitle:unpayAccount describeTitle:descTitle];
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, SCREEN_WIDTH, 1);
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *orderDic = _datasSource[indexPath.section];
    NSArray *array = [orderDic objectForKey:@"itemList"];
    //    NSDictionary *skuDic = [array objectAtIndex:indexPath.row];
    //    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"", @"", nil];
    
    if (indexPath.row < array.count) {
        return 110;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *orderDic = _datasSource[indexPath.section];
    WS(weakSelf)
    ESOrderDetailViewController *orderDetailViewCon = [[ESOrderDetailViewController alloc]init];
    NSString *orderId = [NSString stringWithFormat:@"%@", orderDic[@"ordersId"] ? orderDic[@"ordersId"] : @""];
    [orderDetailViewCon setOrderId:orderId Block:^(BOOL isChanged) {
        if (isChanged) {
            [weakSelf refresh];
        }
    }];
    [orderDetailViewCon setIsFromRecommendCon:YES];
    [self.navigationController pushViewController:orderDetailViewCon animated:YES];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGFloat sectionHeaderHeight = 50; //sectionHeaderHeight
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
}

- (NSString *)getErrorMessage:(NSError *)error {
    NSString *msg = @"网络错误, 请稍后重试!";
    @try {
        NSData *data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *err = nil;
        NSDictionary * errorDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        if (err == nil && errorDict && [errorDict objectForKey:@"msg"]) {
            msg = [errorDict objectForKey:@"msg"];
        }
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    } @finally {
        return msg;
    }
}

@end

