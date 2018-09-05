//
//  ESRecommendOrderSearchViewController.m
//  Consumer
//
//  Created by jiang on 2018/1/4.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommendOrderSearchViewController.h"
#import "MBProgressHUD+NJ.h"
#import "ESMasterSearchHistoryCell.h"
#import "ESMasterSearchHistoryHeaderView.h"
#import "ESMallAssets.h"
#import "ESRecommendAPI.h"
#import "MJRefresh.h"
#import "ESGrayTableViewHeaderFooterView.h"

#import "ESRecommendAPI.h"
#import "ESOrderDetailViewController.h"
#import "ESOrderListProductCell.h"
#import "ESSeparatePriceCell.h"
#import "ESRecommendOrderHeaderView.h"

#define Recommend_Order_SEARCH_HISTORY @"recommendOrderSearchHistory"

@interface ESRecommendOrderSearchViewController ()<UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UITableView *historyTableView;//历史搜索词表单
@property (strong, nonatomic) NSMutableArray *historyDatasSource;//历史搜索词数据
@property (copy, nonatomic) NSString *searchString;//搜索字段

@property (strong, nonatomic) UITableView *searchTableView;//搜索结果表单
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (nonatomic,strong)NSMutableArray *datasSource;//搜索结果数据
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL isSearched;

@end

@implementation ESRecommendOrderSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _historyDatasSource = [NSMutableArray array];
    _datasSource = [NSMutableArray array];
    self.isEditing = YES;
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    [self setSearchBar];
    [self setTableView];
    [self loadSearchHistory];
    [self setSearchTabView];
    [self.view bringSubviewToFront:_historyTableView];
    
}

#pragma mark 键盘即将显示
- (void)keyBoardWillShow:(NSNotification *)note{
    self.isEditing = YES;
    
}
#pragma mark 键盘即将退出
- (void)keyBoardWillHide:(NSNotification *)note{
    self.isEditing = NO;
}

- (void)tapOnRightButton:(id)sender {
    if (self.isEditing) {
        if (_isSearched == NO) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            self.searchTextField.text = _searchString;
            [self.searchTextField resignFirstResponder];
            [self.view sendSubviewToBack:_historyTableView];
        }
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

//搜索bar
- (void)setSearchBar {
    self.leftButton.hidden = YES;
    [self.rightButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.rightButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor stec_ableButtonBackColor] forState:UIControlStateNormal];
    self.rightButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, NAVBAR_HEIGHT-DECORATION_SEGMENT_HEIGHT, SCREEN_WIDTH-60, 33)];
    _searchTextField.placeholder = @"请输入品牌名称";
    _searchTextField.clipsToBounds = YES;
    _searchTextField.layer.cornerRadius = 3.0;
    _searchTextField.backgroundColor = [UIColor stec_lineGrayColor];
    _searchTextField.delegate = self;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    _searchTextField.textColor = [UIColor stec_titleTextColor];
    _searchTextField.font = [UIFont stec_titleFount];
    UIImageView *imageViewPwd=[[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 40, 30)];
    imageViewPwd.image=[UIImage imageNamed:@"master_search"];
    imageViewPwd.contentMode = UIViewContentModeCenter;
    _searchTextField.leftView=imageViewPwd;
    _searchTextField.leftViewMode=UITextFieldViewModeAlways;
    _searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _searchTextField.enablesReturnKeyAutomatically = YES;
    [_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_searchTextField becomeFirstResponder];
    [self.navgationImageview addSubview:_searchTextField];
}

#pragma mark textFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 50) {
        textField.text = [textField.text substringToIndex:50];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    SHLog(@"显示历史搜索");
    [self.view bringSubviewToFront:_historyTableView];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textField.text.length < 1) {
        [MBProgressHUD showError:@"搜索内容不得为空"];
        return NO;
    } else {
        //取消第一响应项
        [self.view sendSubviewToBack:self.historyTableView];
        [self addHistory:textField.text];
        [textField resignFirstResponder];
        _searchString = textField.text;
        [self refresh];
        return YES;
    }
}

- (void)loadSearchHistory {
    if (self.historyDatasSource.count>0) {
        [self.historyDatasSource removeAllObjects];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *searchRecords = (NSMutableArray *)[defaults objectForKey:Recommend_Order_SEARCH_HISTORY];
    if (searchRecords && searchRecords.count>0) {
        [self.historyDatasSource addObjectsFromArray:searchRecords];
    }
    [self.historyTableView reloadData];
    
}

- (void)addHistory:(NSString *)searchStr {
    if ([self.historyDatasSource indexOfObject:searchStr] == NSNotFound) {
        [self.historyDatasSource insertObject:searchStr atIndex:0];
        if (self.historyDatasSource.count>5) {
            self.historyDatasSource = [NSMutableArray arrayWithArray:[self.historyDatasSource subarrayWithRange:NSMakeRange(0, 5)]];
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.historyDatasSource forKey:Recommend_Order_SEARCH_HISTORY];
        [self.historyTableView reloadData];
    } else {
        [_historyDatasSource exchangeObjectAtIndex:0 withObjectAtIndex:[self.historyDatasSource indexOfObject:searchStr]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.historyDatasSource forKey:Recommend_Order_SEARCH_HISTORY];
        [self.historyTableView reloadData];
    }
    
}

- (void)clearHistory {
    [self.historyDatasSource removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:Recommend_Order_SEARCH_HISTORY];
    [self.historyTableView reloadData];
    
}
//历史搜索词
- (void)setTableView {
    _historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) style:UITableViewStyleGrouped];
    _historyTableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    _historyTableView.tableFooterView = [[UIView alloc] init];
    _historyTableView.estimatedRowHeight = 100.0f;
    _historyTableView.rowHeight = UITableViewAutomaticDimension;
    [_historyTableView registerNib:[UINib nibWithNibName:@"ESMasterSearchHistoryCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMasterSearchHistoryCell"];
    [_historyTableView registerNib:[UINib nibWithNibName:@"ESMasterSearchHistoryHeaderView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESMasterSearchHistoryHeaderView"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _historyTableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_historyTableView];
    
}
- (void)setSearchTabView {
    _pageNum = 0;
    _pageSize = 10;
    
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) style:UITableViewStyleGrouped];
    _searchTableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    [_searchTableView registerNib:[UINib nibWithNibName:@"ESOrderListProductCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderListProductCell"];
    [_searchTableView registerNib:[UINib nibWithNibName:@"ESSeparatePriceCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESSeparatePriceCell"];
    [_searchTableView registerNib:[UINib nibWithNibName:@"ESRecommendOrderHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"ESRecommendOrderHeaderView"];
    [_searchTableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    _searchTableView.estimatedRowHeight = 100.0f;
    _searchTableView.tableFooterView = [[UIView alloc] init];
    _searchTableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_searchTableView];
    
    WS(weakSelf)
    _searchTableView.mj_header.backgroundColor = [UIColor stec_viewBackgroundColor];
    _searchTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
    _searchTableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [weakSelf nextpage];
    }];
    
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _historyTableView) {
        return 1;
    } else {
        return _datasSource.count;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _historyTableView) {
        return _historyDatasSource.count;
    } else {
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
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _historyTableView) {
        if (self.historyDatasSource.count>0) {
            return 40;
        } else {
            return 0.001;
        }
    } else {
        return 100;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == _historyTableView) {
        return 0.001;
    } else {
        return 10;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _historyTableView) {
        
        ESMasterSearchHistoryHeaderView *header = [_historyTableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESMasterSearchHistoryHeaderView"];
        if (self.historyDatasSource.count>0) {
            WS(weakSelf)
            [header setTitle:@"最近搜索" Block:^{
                SHLog(@"删除搜索历史");
                [weakSelf clearHistory];
            }];
        }
        header.clipsToBounds = YES;
        return header;
    } else {
        ESRecommendOrderHeaderView *header = [_searchTableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESRecommendOrderHeaderView"];
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
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        return header;
    }
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_searchTableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _historyTableView) {
        ESMasterSearchHistoryCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMasterSearchHistoryCell" forIndexPath:indexPath];
        if (_historyDatasSource.count>indexPath.row) {
            NSString *hisString = [NSString stringWithFormat:@"%@", _historyDatasSource[indexPath.row]];
            [cell setTitle:hisString];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
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
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _historyTableView) {
        if (_historyDatasSource.count>indexPath.row) {
            NSString *hisString = [NSString stringWithFormat:@"%@", _historyDatasSource[indexPath.row]];
            if (![_searchString isEqualToString:hisString]) {
                _searchString = hisString;
                _searchTextField.text = _searchString;
                [_searchTextField resignFirstResponder];
                [self.view sendSubviewToBack:self.historyTableView];
                [self addHistory:hisString];
                [self refresh];
            }
        }
        if (self.isEditing) {
            [self tapOnRightButton:nil];
        }
    } else {
        NSDictionary *orderDic = _datasSource[indexPath.section];
        WS(weakSelf)
        ESOrderDetailViewController *orderDetailViewCon = [[ESOrderDetailViewController alloc]init];
        [orderDetailViewCon setIsFromRecommendCon:YES];
        NSString *orderId = [NSString stringWithFormat:@"%@", orderDic[@"ordersId"] ? orderDic[@"ordersId"] : @""];
        [orderDetailViewCon setOrderId:orderId Block:^(BOOL isChanged) {
            if (isChanged) {
                [weakSelf refresh];
            }
        }];
        [self.navigationController pushViewController:orderDetailViewCon animated:YES];
        if (self.isEditing) {
            [self tapOnRightButton:nil];
        }
    }
    
}

- (void)searchRequest {
    _isSearched = YES;
    NSString *searchStrUtf8 = [_searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WS(weakSelf)
     [ESRecommendAPI getRecommendOrderListWithName:searchStrUtf8 OrderType:@"" pageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
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
        [_searchTableView reloadData];
        NSString *hasNextPage = [NSString stringWithFormat:@"%@", [dict objectForKey:@"hasNextPage"]];
        [weakSelf endLoading];
        if ([hasNextPage isEqualToString:@"0"]) {
            [weakSelf.searchTableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        if (_datasSource.count == 0) {
            [weakSelf showNoDataIn:weakSelf.searchTableView imgName:@"nodata_search" frame:weakSelf.searchTableView.frame Title:@"搜索不到内容哦~\n换个关键词试试~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf endLoading];
        if (_datasSource.count == 0) {
            [weakSelf showNoDataIn:weakSelf.searchTableView imgName:@"nodata_net" frame:weakSelf.searchTableView.frame Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf.searchTableView.mj_header beginRefreshing];
            }];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [weakSelf getErrorMessage:error]]];
        }
    }];
}

- (void)endLoading {
    [_searchTableView.mj_header endRefreshing];
    [_searchTableView.mj_footer endRefreshing];
}

- (void)refresh {
    _pageNum = 0;
    [self searchRequest];
}

- (void)nextpage {
    _pageNum = _pageNum+10;
    [self searchRequest];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isEditing) {
        [self tapOnRightButton:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

