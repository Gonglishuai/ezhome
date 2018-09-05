//
//  ESRecommendSearchViewController.m
//  Consumer
//
//  Created by jiang on 2018/1/4.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommendSearchViewController.h"
#import "MBProgressHUD+NJ.h"
#import "ESMasterSearchHistoryCell.h"
#import "ESMasterSearchHistoryHeaderView.h"
#import "ESMallAssets.h"
#import "ESRecommendAPI.h"
#import "MJRefresh.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESRecommendListTableViewCell.h"
#import "ESRecommendDetailViewController.h"

#define Recommend_SEARCH_HISTORY @"recommendSearchHistory"

@interface ESRecommendSearchViewController ()<UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UITableView *historyTableView;//历史搜索词表单
@property (strong, nonatomic) NSMutableArray *historyDatasSource;//历史搜索词数据
@property (copy, nonatomic) NSString *searchString;//搜索字段

@property (strong, nonatomic) UITableView *searchTableView;//搜索结果表单
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (nonatomic,strong)NSMutableArray *datasSourse;//搜索结果数据
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL isSearched;

@end

@implementation ESRecommendSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _historyDatasSource = [NSMutableArray array];
    _datasSourse = [NSMutableArray array];
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
    _searchTextField.placeholder = @"请输入关键词进行搜索";
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
    NSMutableArray *searchRecords = (NSMutableArray *)[defaults objectForKey:Recommend_SEARCH_HISTORY];
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
        [defaults setObject:self.historyDatasSource forKey:Recommend_SEARCH_HISTORY];
        [self.historyTableView reloadData];
    } else {
        [_historyDatasSource exchangeObjectAtIndex:0 withObjectAtIndex:[self.historyDatasSource indexOfObject:searchStr]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.historyDatasSource forKey:Recommend_SEARCH_HISTORY];
        [self.historyTableView reloadData];
    }
    
}

- (void)clearHistory {
    [self.historyDatasSource removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:Recommend_SEARCH_HISTORY];
    [self.historyTableView reloadData];
    
}
//历史搜索词
- (void)setTableView {
    _historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) style:UITableViewStyleGrouped];
    _historyTableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    _historyTableView.tableFooterView = [[UIView alloc] init];
    _historyTableView.estimatedRowHeight = 100;
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
    [_searchTableView registerNib:[UINib nibWithNibName:@"ESRecommendListTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ESRecommendListTableViewCell"];
    [_searchTableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    _searchTableView.estimatedRowHeight = 120.0f;
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
        return _datasSourse.count;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _historyTableView) {
        return _historyDatasSource.count;
    } else {
        return 1;
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
        if (0 == section) {
            return 0.001;
        }
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == _historyTableView) {
        return 0.001;
    } else {
        return 0.001;
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
        ESGrayTableViewHeaderFooterView *header = [_searchTableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
        [header setBackViewColor:[UIColor stec_viewBackgroundColor]];
        return header;
    }
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *header = [_searchTableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [header setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return header;
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
        ESRecommendListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESRecommendListTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section < _datasSourse.count) {
            NSDictionary *info = [_datasSourse objectAtIndex:indexPath.section];
            [cell setInfo:info isBrand:NO];
        }
        return cell;
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
        if (indexPath.section < _datasSourse.count) {
            NSDictionary *info = [_datasSourse objectAtIndex:indexPath.section];
            ESRecommendDetailViewController *recommendDetailViewCon = [[ESRecommendDetailViewController alloc]init];
            NSString *recommendId = [NSString stringWithFormat:@"%@", info[@"baseId"] ? info[@"baseId"] : @""];
            [recommendDetailViewCon setRecommendId:recommendId];
            [self.navigationController pushViewController:recommendDetailViewCon animated:YES];
        }
        if (self.isEditing) {
            [self tapOnRightButton:nil];
        }
    }
    
}

- (void)searchRequest {
    _isSearched = YES;
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESRecommendAPI getRecommendListWithName:[_searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] pageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.searchTableView.mj_header endRefreshing];
        if (weakSelf.pageNum==0) {
            [weakSelf.datasSourse removeAllObjects];
        }
        NSArray *list = dict[@"list"] ? dict[@"list"] : [NSArray array];
        if ([list isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in list) {
                [weakSelf.datasSourse addObject:dic];
            }
        }

        [weakSelf.searchTableView reloadData];
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.searchTableView imgName:@"nodata_search" frame:weakSelf.searchTableView.bounds Title:@"搜索不到内容哦~\n换个关键词试试~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
        NSInteger recordSetTotal = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"count"]] integerValue];
        if (weakSelf.datasSourse.count >= recordSetTotal) {
            [weakSelf.searchTableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.searchTableView.mj_footer endRefreshing];
        }

    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.searchTableView.mj_header endRefreshing];
        [weakSelf.searchTableView.mj_footer endRefreshing];
        SHLog(@"%@", error);
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.searchTableView imgName:@"nodata_net" frame:weakSelf.searchTableView.bounds Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf.searchTableView.mj_header beginRefreshing];
            }];
        } else {
            [MBProgressHUD showError:@"请求失败"];
        }
        if (weakSelf.pageNum >= 10) {
            weakSelf.pageNum= weakSelf.pageNum - 10;
        }
    }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
