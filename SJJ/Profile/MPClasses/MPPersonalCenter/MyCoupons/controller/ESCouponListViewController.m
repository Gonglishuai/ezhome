//
//  ESCouponListViewController.m
//  Mall
//
//  Created by jiang on 2017/9/7.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESCouponListViewController.h"
#import "ESDiyRefreshHeader.h"
#import "MBProgressHUD+NJ.h"
#import "ESCouponCell.h"
#import "ESAlertView.h"
#import "ESOrderAPI.h"
#import <ESNetworking/SHRequestTool.h>

@interface ESCouponListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datasSource;
@property (assign, nonatomic) CouponStatus myStatus;
@property (assign, nonatomic) BOOL isCanSelect;
@property (assign, nonatomic) BOOL hasChanged;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;

@property (assign, nonatomic) NSInteger selectNum;
@property (copy, nonatomic) NSString *subOrderId;
@property (copy, nonatomic) NSString *orderId;
@property (strong, nonatomic) void(^myblock)(NSMutableDictionary*);

@property (strong, nonatomic) NSMutableDictionary *selectDictionary;

@end

@implementation ESCouponListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectNum = -1;
    _pageNum = 0;
    _pageSize = 10;
    _datasSource = [NSMutableArray array];
    _selectDictionary = [NSMutableDictionary dictionary];
    [self setTableView];
    
}

- (void)setStatus:(CouponStatus)status isCanSelect:(BOOL)isCanSelect subOrderId:(NSString *)subOrderId orderId:(NSString *)orderId {
    _orderId = orderId;
    _subOrderId =subOrderId;
    _myStatus = status;
    _isCanSelect = isCanSelect;
}

- (void)setBlock:(void(^)(NSMutableDictionary *couponDic))block {
    _myblock = block;
}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-DECORATION_SEGMENT_HEIGHT+10) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"ESCouponCell" bundle:nil] forCellReuseIdentifier:@"ESCouponCell"];
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
    if (_myStatus == CouponStatusAbleUse || _myStatus == CouponStatusUnableUse) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *type = @"1";
        if (_myStatus == CouponStatusUnableUse) {
            type = @"2";
        }
        [ESOrderAPI getSelectCouponsListWithType: type SubOrderId:_subOrderId orderId:_orderId Success:^(NSDictionary *dict) {
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
            [weakSelf endLoading];
            
            [_tableView.mj_footer endRefreshingWithNoMoreData];
            
            if (_datasSource.count == 0) {
                if (_myStatus == CouponStatusAbleUse) {
                    [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_coupon" frame:_tableView.frame Title:@"没有可用优惠券~" buttonTitle:nil Block:nil];
                } else {
                    [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_coupon_unable" frame:_tableView.frame Title:@"什么都没有~" buttonTitle:nil Block:nil];
                }
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
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *type = [NSString stringWithFormat:@"%ld", (long)_myStatus];
        [ESOrderAPI getMyCouponsListWithType:type pageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
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
            NSString *totalCount = [NSString stringWithFormat:@"%@", [dict objectForKey:@"totalCount"]];
            [weakSelf endLoading];
            if ([totalCount isEqualToString:[NSString stringWithFormat:@"%ld", _datasSource.count]]) {
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            if (_datasSource.count == 0) {
                if (_myStatus == CouponStatusAbleUse) {
                    [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_coupon" frame:_tableView.frame Title:@"没有可用优惠券~" buttonTitle:nil Block:nil];
                } else {
                    [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_coupon_unable" frame:_tableView.frame Title:@"什么都没有~" buttonTitle:nil Block:nil];
                }
                
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
}

- (void)endLoading {
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasSource.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ESCouponCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESCouponCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WS(weakSelf)
    if (_datasSource.count>indexPath.row) {
        NSDictionary *info = _datasSource[indexPath.row];
        
        if (_hasChanged == NO) {
            NSString *isChecked = [NSString stringWithFormat:@"%@", info[@"isChecked"]];
            if ([isChecked isEqualToString:@"1"]) {
                _selectNum = indexPath.row;
                _selectDictionary = [NSMutableDictionary dictionaryWithDictionary:info];
            }
            
        }
        if(_selectNum == indexPath.row && _myStatus == CouponStatusAbleUse) {
            [cell setStatus:CouponStatusSelect info:info block:^{
                SHLog(@"使用规则");
                [weakSelf showAlertWithMessage:info[@"detail"]];
            }];
        } else {
            [cell setStatus:_myStatus info:info block:^{
                SHLog(@"使用规则");
                [weakSelf showAlertWithMessage:info[@"detail"]];
            }];
        }
    }
    
    
    return cell;
}

- (void)showAlertWithMessage:(NSString *)message {
    if ([message isKindOfClass:[NSString class]]) {
        [ESAlertView showTitle:@"规则说明" message:message buttonTitle:@"知道了" withClickedBlock:^{
            SHLog(@"点击回调");
        }];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0.57*(SCREEN_WIDTH-30)+20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isCanSelect) {
        _hasChanged = YES;
        if (_selectNum == indexPath.row) {
            _selectNum = -1;
            _selectDictionary = [NSMutableDictionary dictionary];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            NSIndexPath *oldIndex = [NSIndexPath indexPathForRow:_selectNum inSection:0];
            _selectNum = indexPath.row;
            if (_datasSource.count>_selectNum) {
                _selectDictionary = [NSMutableDictionary dictionaryWithDictionary:_datasSource[_selectNum]];
            }
            [tableView reloadRowsAtIndexPaths:@[oldIndex, indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        if (self.myblock) {
            self.myblock(_selectDictionary);
        }
        
    }
}
@end
