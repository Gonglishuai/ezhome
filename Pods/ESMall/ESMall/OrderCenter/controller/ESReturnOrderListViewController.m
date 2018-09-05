//
//  ESReturnOrderListViewController.m
//  Consumer
//
//  Created by jiang on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnOrderListViewController.h"
#import "ESOrderAPI.h"
#import "ESReturnGoodsDetailController.h"

#import "ESOrderListProductCell.h"
#import "ESSeparatePriceCell.h"
#import "ESOrderListButtonCell.h"
#import "ESLabelHeaderFooterView.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESDiyRefreshHeader.h"
#import "MBProgressHUD+NJ.h"

@interface ESReturnOrderListViewController ()
<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datasSource;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@end

@implementation ESReturnOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navgationImageview.hidden = YES;
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

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-DECORATION_SEGMENT_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESOrderListProductCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderListProductCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESSeparatePriceCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESSeparatePriceCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESOrderListButtonCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderListButtonCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESLabelHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESLabelHeaderFooterView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    _tableView.estimatedRowHeight = 100.0f;
    [self.view addSubview:_tableView];
    WS(weakSelf)
    _tableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
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
    [ESOrderAPI getReturnOrderListWithPageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
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
    NSArray *array = [orderDic objectForKey:@"detailList"];
    //    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"", @"", nil];
    NSString *orderState = [NSString stringWithFormat:@"%@", [orderDic objectForKey:@"processStatus"]];
    if ([orderState isEqualToString:@"30"]) {//交易关闭
        return array.count+2;
    } else {
        return array.count+1;
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESLabelHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESLabelHeaderFooterView"];
    NSDictionary *orderDic = _datasSource[section];
    NSString * brandName = [NSString stringWithFormat:@"%@", orderDic[@"brandName"] ? orderDic[@"brandName"] : @""];
    
    NSString *orderState = [NSString stringWithFormat:@"%@", [orderDic objectForKey:@"processStatus"]];
    if ([orderState isEqualToString:@"10"]) {//退款处理中
        [header setTitle:brandName titleColor:[UIColor stec_titleTextColor] subTitle:@"退款处理中" subTitleColor:[UIColor stec_subTitleTextColor] backColor:[UIColor whiteColor]];
    } else if ([orderState isEqualToString:@"20"]) {//退款关闭
        [header setTitle:brandName titleColor:[UIColor stec_titleTextColor] subTitle:@"退款关闭" subTitleColor:[UIColor stec_subTitleTextColor] backColor:[UIColor whiteColor]];
    } else if ([orderState isEqualToString:@"30"]) {//退款同意
        [header setTitle:brandName titleColor:[UIColor stec_titleTextColor] subTitle:@"退款同意" subTitleColor:[UIColor stec_subTitleTextColor] backColor:[UIColor whiteColor]];
    } else if ([orderState isEqualToString:@"40"]) {//退款成功
        [header setTitle:brandName titleColor:[UIColor stec_titleTextColor] subTitle:@"退款成功" subTitleColor:[UIColor stec_subTitleTextColor] backColor:[UIColor whiteColor]];
    } else if ([orderState isEqualToString:@"50"]) {//退款拒绝
        [header setTitle:brandName titleColor:[UIColor stec_titleTextColor] subTitle:@"退款拒绝" subTitleColor:[UIColor stec_subTitleTextColor] backColor:[UIColor whiteColor]];
    } else {//退款拒绝
        [header setTitle:brandName titleColor:[UIColor stec_titleTextColor] subTitle:@"退款拒绝" subTitleColor:[UIColor stec_subTitleTextColor] backColor:[UIColor whiteColor]];
    }
    
    
    
    header.backgroundColor = [UIColor whiteColor];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *orderDic = _datasSource[indexPath.section];
    NSArray *array = [orderDic objectForKey:@"detailList"];
    
    //    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"", @"", nil];
    
    if (indexPath.row < array.count) {
        NSDictionary *skuDic = [array objectAtIndex:indexPath.row];
        ESOrderListProductCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderListProductCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *orderType = [NSString stringWithFormat:@"%@", [orderDic objectForKey:@"orderType"]];
        [cell setProductInfo:skuDic orderType:orderType];
        return cell;
    } else if (array.count == indexPath.row) {
        NSInteger num = 0;
        for (NSDictionary *dic in array) {
            NSString *numm = dic[@"itemQuantity"] ? dic[@"itemQuantity"] : @"1";
            num = num + [numm integerValue];
        }
        ESSeparatePriceCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESSeparatePriceCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        double pay = [[NSString stringWithFormat:@"%@", (orderDic[@"returnAmount"] ? orderDic[@"returnAmount"] : @"0.00")] doubleValue];
        
        NSString *payAccount = @"";
        if (pay > 10000000.0) {
            payAccount = [NSString stringWithFormat:@"￥%@万",[NSString stringWithFormat:@"%.2f",pay/10000.0]];
        } else {
            payAccount = [NSString stringWithFormat:@"￥%@",[NSString stringWithFormat:@"%.2f",pay]];
        }
        
        double payed = [[NSString stringWithFormat:@"%@", (orderDic[@"payed"] ? orderDic[@"payed"] : @"0.00")] doubleValue];
        NSString *payedAccount = @"";
        if (payed > 10000000.0) {
            payedAccount = [NSString stringWithFormat:@"￥%@万",[NSString stringWithFormat:@"%.2f",payed/10000.0]];
        } else {
            payedAccount = [NSString stringWithFormat:@"￥%@",[NSString stringWithFormat:@"%.2f",payed]];
        }
        
//        [cell setTitle:[NSString stringWithFormat:@"共%ld件商品 合计", (long)num] subTitle:payAccount];
        NSString *orderType = [NSString stringWithFormat:@"%@", [orderDic objectForKey:@"orderType"]];
        if ([orderType isEqualToString:@"0"]) {
            if (payed > 0) {
                [cell setTitle:@"剩余支付" subTitle:@"" describeTitle:[NSString stringWithFormat:@"定金%@(已付 %@)", payAccount, payedAccount]];
            }else {
                [cell setTitle:@"剩余支付" subTitle:@"" describeTitle:[NSString stringWithFormat:@"定金%@", payAccount]];
            }
            
//            [cell setTitle:[NSString stringWithFormat:@"定金"] subTitle:payAccount];
        } else {
            if (payed > 0) {
                [cell setTitle:@"剩余支付" subTitle:@"" describeTitle:[NSString stringWithFormat:@"共%ld件商品 合计%@(已付 %@)", (long)num, payAccount, payedAccount]];
            } else {
                [cell setTitle:@"剩余支付" subTitle:@"" describeTitle:[NSString stringWithFormat:@"共%ld件商品 合计%@", (long)num, payAccount]];
            }
            
//            [cell setTitle:[NSString stringWithFormat:@"共%ld件商品 合计", (long)num] subTitle:payAccount];
        }
        
        return cell;
    } else {
        ESOrderListButtonCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESOrderListButtonCell" forIndexPath:indexPath];
        WS(weakSelf)
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setReturnInfo:orderDic block:^(ESOrderTabbarBtnType orderTabbarBtnType) {
            [weakSelf getMoney:orderDic];
        }];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *orderDic = _datasSource[indexPath.section];
    NSArray *array = [orderDic objectForKey:@"detailList"];
    if (indexPath.row < array.count) {
        return 110;
    } else if (indexPath.row == array.count) {
        return UITableViewAutomaticDimension;
    } else {
        return 45;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *orderDic = _datasSource[indexPath.section];
    NSString *returnId = [NSString stringWithFormat:@"%@", orderDic[@"returnGoodsId"] ? orderDic[@"returnGoodsId"] : @""];
    WS(weakSelf)
    ESReturnGoodsDetailController *returnOrderDetailViewCon = [[ESReturnGoodsDetailController alloc]initWithOrderId:returnId Block:^(BOOL isChanged) {
        if (isChanged) {
            [weakSelf refresh];
        }
    }];
    [self.navigationController pushViewController:returnOrderDetailViewCon animated:YES];
    
}

- (void)getMoney:(NSDictionary *)orderDic {

    WS(weakSelf)
    NSString *title = @"";
    if (orderDic
        && [orderDic isKindOfClass:[NSDictionary class]]
        && orderDic[@"refundType"])
    {
        NSInteger refundType = [orderDic[@"refundType"] integerValue];
        title = refundType == 1?@"是否确定退货退款?":@"是否确定退款?";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [weakSelf getMoneyWithDic:orderDic];
                                                   }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
    
    

}
- (void)getMoneyWithDic:(NSDictionary *)orderDic {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *orderId = [orderDic objectForKey:@"returnGoodsId"] ? [orderDic objectForKey:@"returnGoodsId"] : @"";
    [ESOrderAPI confirmReturnGoodsWithId:orderId withSuccess:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf requestData];
    } andFailure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [self getErrorMessage:error]]];
    }];
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
