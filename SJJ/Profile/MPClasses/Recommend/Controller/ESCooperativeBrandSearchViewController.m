//
//  ESCooperativeBrandSearchViewController.m
//  Consumer
//
//  Created by jiang on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCooperativeBrandSearchViewController.h"

#import "MBProgressHUD+NJ.h"
#import "ESMasterSearchHistoryCell.h"
#import "ESMasterSearchHistoryHeaderView.h"
#import "ESOrderAPI.h"
#import "ESDiyRefreshHeader.h"
#import "ESMallAssets.h"
#import "ESCooperativeBrandCollectionViewCell.h"
#import "ESRecommendAPI.h"

#define Cooperative_Brand_Search_HISTORY @"CooperativeBrandSearchHistory"

@interface ESCooperativeBrandSearchViewController ()<UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UITableView *historyTableView;//历史搜索词表单
@property (strong, nonatomic) NSMutableArray *historyDatasSource;//历史搜索词数据
@property (copy, nonatomic) NSString *searchString;//搜索字段

@property (strong, nonatomic) UICollectionView *collectionView;//搜索结果表单
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (nonatomic,strong)NSMutableArray *datasSourse;//搜索结果数据
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL isSearched;

@property (nonatomic, strong) NSString *catalogId;

@end

@implementation ESCooperativeBrandSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _historyDatasSource = [NSMutableArray array];
    _datasSourse = [NSMutableArray array];
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    [self setSearchBar];
    [self setTableView];
    [self loadSearchHistory];
    [self setCollectionView];
    [self.view bringSubviewToFront:_historyTableView];
    // Do any additional setup after loading the view.
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
    _searchTextField.placeholder = @"请输入商品关键词";
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
    NSMutableArray *searchRecords = (NSMutableArray *)[defaults objectForKey:Cooperative_Brand_Search_HISTORY];
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
        [defaults setObject:self.historyDatasSource forKey:Cooperative_Brand_Search_HISTORY];
        [self.historyTableView reloadData];
    } else {
        [_historyDatasSource exchangeObjectAtIndex:0 withObjectAtIndex:[self.historyDatasSource indexOfObject:searchStr]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.historyDatasSource forKey:Cooperative_Brand_Search_HISTORY];
        [self.historyTableView reloadData];
    }
    
}

- (void)clearHistory {
    [self.historyDatasSource removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:Cooperative_Brand_Search_HISTORY];
    [self.historyTableView reloadData];
    
}
//历史搜索词
- (void)setTableView {
    _historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) style:UITableViewStyleGrouped];
    _historyTableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    _historyTableView.tableFooterView = [[UIView alloc] init];
    _historyTableView.estimatedRowHeight = 150;
    _historyTableView.rowHeight = UITableViewAutomaticDimension;
    [_historyTableView registerNib:[UINib nibWithNibName:@"ESMasterSearchHistoryCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESMasterSearchHistoryCell"];
    [_historyTableView registerNib:[UINib nibWithNibName:@"ESMasterSearchHistoryHeaderView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESMasterSearchHistoryHeaderView"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _historyTableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_historyTableView];
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyDatasSource.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.historyDatasSource.count>0) {
        return 40;
    } else {
        return 0.001;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ESMasterSearchHistoryCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMasterSearchHistoryCell" forIndexPath:indexPath];
    if (_historyDatasSource.count>indexPath.row) {
        NSString *hisString = [NSString stringWithFormat:@"%@", _historyDatasSource[indexPath.row]];
        [cell setTitle:hisString];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
}

- (void)searchRequest {
    _isSearched = YES;
    
    WS(weakSelf)
    NSString *search = [_searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [ESRecommendAPI getCooperativeBrandRecommendListWithName:search pageSize:_pageSize pageNum:_pageNum Success:^(NSDictionary *dict) {
         SHLog(@"%@", dict);
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [weakSelf.collectionView.mj_header endRefreshing];
         if (weakSelf.pageNum==0) {
             [weakSelf.datasSourse removeAllObjects];
         }
         NSArray *materialsEsports = dict[@"rows"] ? dict[@"rows"] : [NSArray array];
         if ([materialsEsports isKindOfClass:[NSArray class]]) {
             for (NSDictionary *dic in materialsEsports) {
                 [weakSelf.datasSourse addObject:dic];
             }
         }

         [weakSelf.collectionView reloadData];
         if (weakSelf.datasSourse.count == 0) {
             [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_datas" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"啊哦~暂时没有搜到结果哦~" buttonTitle:nil Block:nil];
         } else {
             [weakSelf removeNoDataView];
         }
         NSInteger recordSetTotal = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"count"]] integerValue];
         if (weakSelf.datasSourse.count >= recordSetTotal) {
             [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
         } else {
             [weakSelf.collectionView.mj_footer endRefreshing];
         }

     } failure:^(NSError *error) {
         [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
         [weakSelf.collectionView.mj_header endRefreshing];
         [weakSelf.collectionView.mj_footer endRefreshing];
         SHLog(@"%@", error);
         if (weakSelf.datasSourse.count == 0) {
             [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_net" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                 [weakSelf.collectionView.mj_header beginRefreshing];
             }];
         } else {
             [MBProgressHUD showError:@"请求失败"];
         }
         if (weakSelf.pageNum >= 10) {
             weakSelf.pageNum= weakSelf.pageNum - 10;
         }
     }];
}

- (void)setCollectionView {
    _pageNum = 0;
    _pageSize = 10;
    _datasSourse = [NSMutableArray array];
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    //    _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //    _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) collectionViewLayout:_collectionViewLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESCooperativeBrandCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ESCooperativeBrandCollectionViewCell"];
    WS(weakSelf)
    _collectionView.mj_header.backgroundColor = [UIColor stec_viewBackgroundColor];
    _collectionView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
    _collectionView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        [weakSelf nextpage];
    }];
    [self.view addSubview:_collectionView];
    
}

- (void)refresh {
    
    _pageNum = 0;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self searchRequest];
}

- (void)nextpage {
    _pageNum = _pageNum+10;
    [self searchRequest];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datasSourse.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESCooperativeBrandCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESCooperativeBrandCollectionViewCell" forIndexPath:indexPath];
    if (_datasSourse.count > indexPath.row) {
        NSDictionary *dic = [_datasSourse objectAtIndex:indexPath.row];
        [cell setInfo:dic];
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((SCREEN_WIDTH-41)/2, (SCREEN_WIDTH-41)/2 + 40 );
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(15, 15, 15, 15);
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isEditing) {
        [self tapOnRightButton:nil];
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

