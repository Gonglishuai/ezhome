//
//  ESMasterSearchController.m
//  Mall
//
//  Created by jiang on 2017/8/30.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMasterSearchController.h"
#import "MBProgressHUD+NJ.h"
#import "ESMasterSearchHistoryCell.h"
#import "ESMasterSearchHistoryHeaderView.h"
#import "ESOrderAPI.h"
#import "ESDiyRefreshHeader.h"
#import "GoodsItemCell.h"
#import "ESProductDetailViewController.h"
#import "CFMultistageDropdownMenuView.h"
#import "ESMasterSearchScreenCollectionReusableView.h"
#import "GrayFooterCollectionReusableView.h"
#import "ESMaterialHomeModel.h"

#define SEARCH_HISTORY @"searchHistory"

@interface ESMasterSearchController ()<UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CFMultistageDropdownMenuViewDelegate>
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UITableView *historyTableView;//历史搜索词表单
@property (strong, nonatomic) NSMutableArray *historyDatasSource;//历史搜索词数据
@property (copy, nonatomic) NSString *searchString;//搜索字段
@property (strong, nonatomic) NSMutableArray *screenArray;//筛选项存储
@property (strong, nonatomic) NSMutableDictionary *sortDic;//排序项存储

@property (strong, nonatomic) UICollectionView *collectionView;//搜索结果表单
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (nonatomic,strong)NSMutableArray *datasSourse;//搜索结果数据
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL isSearched;

@property (nonatomic, strong) CFMultistageDropdownMenuView *multistageDropdownMenuView;
@property (nonatomic,strong)NSMutableArray *dropListLeftArr;
@property (nonatomic,strong)NSMutableArray *dropListRightArr;

@property (nonatomic, strong) NSString *catalogId;
@end

@implementation ESMasterSearchController

- (instancetype)initWithCatalogId:(NSString *)catalogId {
    self = [super init];
    if (self) {
        self.catalogId = catalogId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _historyDatasSource = [NSMutableArray array];
    _screenArray = [NSMutableArray array];
    for (int i=0; i<3; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [_screenArray addObject:dic];
    }
    _datasSourse = [NSMutableArray array];
    _dropListLeftArr = [NSMutableArray array];
    _dropListRightArr = [NSMutableArray array];
    _sortDic = [NSMutableDictionary dictionary];
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    [self setSearchBar];
    [self.view addSubview:self.multistageDropdownMenuView];
    [self setTableView];
    [self loadSearchHistory];
    [self setCollectionView];
    [self.view bringSubviewToFront:_historyTableView];
    // Do any additional setup after loading the view.
}


#pragma mark 键盘即将显示
- (void)keyBoardWillShow:(NSNotification *)note{
    
    self.isEditing = YES;
    [_multistageDropdownMenuView hide];
    
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

#pragma mark - lazy
/* 配置CFDropDownMenuView */
- (CFMultistageDropdownMenuView *)multistageDropdownMenuView
{
    // DEMO
    _multistageDropdownMenuView = [[CFMultistageDropdownMenuView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, 45)];
    
    _multistageDropdownMenuView.defaulTitleArray = [NSArray arrayWithObjects:@"分类",@"品牌", @"价格", @"排序", nil];
    _dropListLeftArr = [NSMutableArray arrayWithObjects:@[],@[],@[],@[], nil];
    _multistageDropdownMenuView.delegate = self;
    
    // 下拉列表 起始y
    _multistageDropdownMenuView.startY = CGRectGetMaxY(_multistageDropdownMenuView.frame);
    return _multistageDropdownMenuView;
    
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
        [self clearScreen];
        [self refresh];
        return YES;
    }
}

- (void)loadSearchHistory {
    if (self.historyDatasSource.count>0) {
        [self.historyDatasSource removeAllObjects];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *searchRecords = (NSMutableArray *)[defaults objectForKey:SEARCH_HISTORY];
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
        [defaults setObject:self.historyDatasSource forKey:SEARCH_HISTORY];
        [self.historyTableView reloadData];
    } else {
        [_historyDatasSource exchangeObjectAtIndex:0 withObjectAtIndex:[self.historyDatasSource indexOfObject:searchStr]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.historyDatasSource forKey:SEARCH_HISTORY];
        [self.historyTableView reloadData];
    }
    
}

- (void)clearHistory {
    [self.historyDatasSource removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:SEARCH_HISTORY];
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

#pragma mark - CFMultistageDropdownMenuViewDelegate
- (void)multistageDropdownMenuView:(CFMultistageDropdownMenuView *)multistageDropdownMenuView selecteTitleButtonIndex:(NSInteger)titleButtonIndex conditionLeftIndex:(NSInteger)leftIndex conditionRightIndex:(NSInteger)rightIndex
{
    
    
//    NSString *str = [NSString stringWithFormat:@"(都是从0开始)\n 当前选中是 第%zd个title按钮, 一级条件索引是%zd,  二级条件索引是%zd",titleButtonIndex, leftIndex, rightIndex];
    if (_dropListRightArr.count>titleButtonIndex && titleButtonIndex != 3) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[_dropListRightArr objectAtIndex:titleButtonIndex]];
        if (arr.count>rightIndex) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:rightIndex]];
            [_screenArray replaceObjectAtIndex:titleButtonIndex withObject:dic];
        }
    } else if (titleButtonIndex == 3) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[_dropListRightArr objectAtIndex:titleButtonIndex]];
        if (arr.count>rightIndex) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:rightIndex]];
            _sortDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    }
    [self refresh];
}

//- (void)multistageDropdownMenuView:(CFMultistageDropdownMenuView *)multistageDropdownMenuView selectTitleButtonWithCurrentTitle:(NSString *)currentTitle currentTitleArray:(NSArray *)currentTitleArray
//{
//    NSMutableString *mStr = [NSMutableString stringWithFormat:@" "];
//    
//    for (NSString *str in currentTitleArray) {
//        [mStr appendString:[NSString stringWithFormat:@"\"%@\"", str]];
//        [mStr appendString:@" "];
//    }
//    NSString *str = [NSString stringWithFormat:@"当前选中的是 \"%@\" \n 当前展示的所有条件是:\n (%@)",currentTitle, mStr];
//    
//    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"第二个代理方法" message:str preferredStyle:UIAlertControllerStyleAlert];
//    [self presentViewController:alertController animated:NO completion:^{
//        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//            
//        }];
//        [alertController addAction:alertAction];
//    }];
//}


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
            [self clearScreen];
            [self.view sendSubviewToBack:self.historyTableView];
            [self addHistory:hisString];
            [self refresh];
        }
    }
}

- (void)clearScreen {
    self.screenArray = [NSMutableArray array];
    for (int i=0; i<3; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [self.screenArray addObject:dic];
    }
}

- (void)searchRequest {
    _isSearched = YES;
    NSMutableArray *facetArray = [NSMutableArray array];
    for (int i=0; i<3; i++) {
        NSDictionary *dic = _screenArray[i];
        if (dic.allKeys.count>0) {
            [facetArray addObject:[NSString stringWithFormat:@"%@", dic[@"value"]?dic[@"value"]:@""]];
        }
    }
    NSString *facetString = @"";
    if (facetArray.count>0) {
        facetString = [facetArray componentsJoinedByString:@","];
    }
    
    NSDictionary *dict = _sortDic;
    NSString *sortString = @"";
    if (dict.allKeys.count>0) {
        sortString = [NSString stringWithFormat:@"%@", dict[@"value"]?dict[@"value"]:@""];
    }
    
    WS(weakSelf)
     NSString *search = [_searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *facet = [facetString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *sort = [sortString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [ESOrderAPI searchGoodsListWithName:search
                              catalogId:self.catalogId
                                  facet:facet sort:sort
                               pageSize:_pageSize
                                pageNum:_pageNum
                                Success:^(NSDictionary *dict)
    {
        SHLog(@"%@", dict);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        if (weakSelf.pageNum==0) {
            [weakSelf.datasSourse removeAllObjects];
        }
        NSArray *materialsEsports = dict[@"productList"] ? dict[@"productList"] : [NSArray array];
        if ([materialsEsports isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in materialsEsports) {
                
                NSDictionary *dicNew = [ESMaterialHomeModel updateListDic:dic];
                [weakSelf.datasSourse addObject:dicNew];
            }
        }
        
        [weakSelf.collectionView reloadData];
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_datas" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"啊哦~暂时没有搜到结果哦~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
        NSInteger recordSetTotal = [[NSString stringWithFormat:@"%@", [dict objectForKey:@"recordSetTotal"]] integerValue];
        if (weakSelf.datasSourse.count >= recordSetTotal) {
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
        
        NSMutableArray *array1 = [NSMutableArray array];
        NSMutableArray *array2 = [NSMutableArray array];
        NSMutableArray *array3 = [NSMutableArray array];
        NSMutableArray *array4 = [NSMutableArray array];
        
        NSArray *facetList = dict[@"facetList"] ? dict[@"facetList"] : [NSArray array];
        if ([facetList isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in facetList) {
                NSMutableArray *rightArr = [NSMutableArray array];
                NSArray *facetEntryValueList = dic[@"facetEntryValueList"] ? dic[@"facetEntryValueList"] : [NSArray array];
                NSString *facetFieldName = dic[@"facetFieldName"] ? dic[@"facetFieldName"] : @"";
                if ([facetEntryValueList isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *facetEntryValueListDic in facetEntryValueList) {
                        [rightArr addObject:facetEntryValueListDic];
                    }
                    if ([facetFieldName isEqualToString:@"parentCatgroup_id_facet"]) {
                        [array1 addObjectsFromArray:rightArr];
                    } else if ([facetFieldName isEqualToString:@"brand"]) {
                        [array2 addObjectsFromArray:rightArr];
                    } else if ([facetFieldName isEqualToString:@"price"]) {
                        [array3 addObjectsFromArray:rightArr];
                    }
                }
                
            }
            
        }
        
        NSArray *sortList = dict[@"sortList"] ? dict[@"sortList"] : [NSArray array];
        if ([sortList isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in sortList){
                [array4 addObject:dic];
            }
        }
        
        _dropListRightArr = [NSMutableArray arrayWithObjects:array1, array2, array3, array4, nil];

        NSMutableArray *titleRightArray = [NSMutableArray array];
        for (NSArray *array in _dropListRightArr) {
            NSMutableArray *tempArr = [NSMutableArray array];
//            [tempArr addObject:@"全部"];
            
            for (NSDictionary *rDic in array) {
                NSString *str = [NSString stringWithFormat:@"%@", rDic[@"label"]?rDic[@"label"]:@""];
                [tempArr addObject:str];
            }
            
            [titleRightArray addObject:[NSMutableArray arrayWithObjects:tempArr, nil]];
        }
        
        [_multistageDropdownMenuView setupDataSourceLeftArray:[NSArray arrayWithArray:_dropListLeftArr] rightArray:[NSArray arrayWithArray:titleRightArray]];
        
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
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT+45, SCREEN_WIDTH, SCREEN_HEIGHT-(NAVBAR_HEIGHT+45)) collectionViewLayout:_collectionViewLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"GoodsItemCell" bundle:[ESMallAssets hostBundle]] forCellWithReuseIdentifier:@"GoodsItemCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESMasterSearchScreenCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ESMasterSearchScreenCollectionReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"GrayFooterCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView"];
    
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _pageNum = 0;
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
    GoodsItemCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"GoodsItemCell" forIndexPath:indexPath];
    if (_datasSourse.count > indexPath.row) {
        NSDictionary *dic = [_datasSourse objectAtIndex:indexPath.row];
        [cell setProductListInfo:dic];
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SHLog(@"商品详情");
    if (self.isEditing) {
        [self tapOnRightButton:nil];
    }
    if (_datasSourse.count > indexPath.row) {
        NSDictionary *dic = [_datasSourse objectAtIndex:indexPath.row];
        NSString *goodid = [NSString stringWithFormat:@"%@", dic[@"catalogEntryId"] ? dic[@"catalogEntryId"] : @""];
        ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc]
                                                               initWithProductId:goodid type:ESProductDetailTypeSpu designerId:nil];
        productDetailViewCon.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:productDetailViewCon animated:YES];
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = [ESMaterialHomeModel geiListHeightWithIndex:indexPath.row arr:_datasSourse];
    if (320 == SCREEN_WIDTH) {
        return CGSizeMake((SCREEN_WIDTH-41)/2, (SCREEN_WIDTH-41)/2 + 80 + height);
    } else {
        return CGSizeMake((SCREEN_WIDTH-41)/2, (SCREEN_WIDTH-41)/2 + 80 + height);
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(15, 15, 15, 15);
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        ESMasterSearchScreenCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ESMasterSearchScreenCollectionReusableView" forIndexPath:indexPath];
        WS(weakSelf)
        [header setScreenArray:_screenArray removeBlock:^(NSInteger index) {
            [weakSelf.screenArray replaceObjectAtIndex:index withObject:[NSDictionary dictionary]];
            [weakSelf refresh];
        } clearBlock:^{
            [weakSelf clearScreen];
            [weakSelf refresh];
        }];
        return header;
    } else {

        GrayFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView" forIndexPath:indexPath];
        return footer;
        
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    BOOL isNull = YES;
    for (NSDictionary *dic in _screenArray) {
        if ([dic allKeys].count>0) {
            isNull = NO;
            break;
        }
    }
    if (isNull) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    } else {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 45);
        return size;
    }
    
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
