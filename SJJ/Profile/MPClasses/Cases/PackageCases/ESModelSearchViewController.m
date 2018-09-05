
#import "ESModelSearchViewController.h"
#import "ESSampleRoomListModel.h"
#import "ESModelSearcHistoryView.h"
#import "ESModelListView.h"
#import "MBProgressHUD.h"
#import "ESCaseDetailViewController.h"
#import "ESCaseDetailViewController.h"
#import "CoCaseDetailController.h"

#define SEARCH_CASE_MODEL_HISTORY @"SEARCH_CASE_MODEL_HISTORY"

@interface ESModelSearchViewController ()<
UITextFieldDelegate,
ESModelListViewDelegate,
ESModelSearcHistoryViewDelegate
>

@end

@implementation ESModelSearchViewController
{
    UITextField *_searchTextField;
    ESModelSearcHistoryView *_historyView;
    ESModelListView *_modelListView;
    
    BOOL _editingStatus;
    BOOL _searchedStatus;
    BOOL _isLoadMore;
    BOOL _showCountLabelStatus;
    NSInteger _limit;
    NSInteger _offset;
    
    NSString *_searchString;
    NSMutableArray *_arrSearchStr;
    NSMutableArray *_arrayDS;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
    
    [self loadSearchHistory];
}

- (void)initData
{
    _searchString = @"";
    _arrSearchStr = [NSMutableArray array];
    _arrayDS = [NSMutableArray array];
    
    _showCountLabelStatus = YES;
    _limit = 10;
    _offset = 0;
}

- (void)initUI
{
    [self initSearchBar];
    
    [self initTableView];
}

- (void)loadSearchHistory
{
    if (_arrSearchStr.count>0)
    {
        [_arrSearchStr removeAllObjects];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *searchRecords = (NSMutableArray *)[defaults objectForKey:SEARCH_CASE_MODEL_HISTORY];
    if (searchRecords && searchRecords.count>0)
    {
        [_arrSearchStr addObjectsFromArray:searchRecords];
    }
    [_historyView refreshHistory];
    
}

- (void)initSearchBar
{
    self.leftButton.hidden = YES;
    [self.rightButton setImage:nil
                      forState:UIControlStateNormal];
    [self.rightButton setTitle:@"取消"
                      forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor stec_ableButtonBackColor] forState:UIControlStateNormal];
    self.rightButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, NAVBAR_HEIGHT-DECORATION_SEGMENT_HEIGHT, SCREEN_WIDTH-60, 33)];
    _searchTextField.placeholder = @"输入套餐样板间关键词";
    _searchTextField.clipsToBounds = YES;
    _searchTextField.layer.cornerRadius = 3.0;
    _searchTextField.backgroundColor = [UIColor stec_lineGrayColor];
    _searchTextField.delegate = self;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    _searchTextField.textColor = [UIColor stec_titleTextColor];
    _searchTextField.font = [UIFont stec_titleFount];
    UIImageView *imageViewPwd = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 40, 30)];
    imageViewPwd.image = [UIImage imageNamed:@"master_search"];
    imageViewPwd.contentMode = UIViewContentModeCenter;
    _searchTextField.leftView = imageViewPwd;
    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
    _searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _searchTextField.enablesReturnKeyAutomatically = YES;
    [_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_searchTextField becomeFirstResponder];
    [self.navgationImageview addSubview:_searchTextField];
}

- (void)initTableView
{
    CGRect modelListFrame = CGRectMake(
                                       0,
                                       NAVBAR_HEIGHT,
                                       SCREEN_WIDTH,
                                       SCREEN_HEIGHT - NAVBAR_HEIGHT
                                       );
    _modelListView = [[ESModelListView alloc] initWithFrame:modelListFrame];
    _modelListView.viewDelegate = self;
    [self.view addSubview:_modelListView];
    
    CGRect searchHistoryFrame = CGRectMake(
                                           0,
                                           NAVBAR_HEIGHT,
                                           SCREEN_WIDTH,
                                           SCREEN_HEIGHT - NAVBAR_HEIGHT
                                           );
    _historyView = [[ESModelSearcHistoryView alloc] initWithFrame:searchHistoryFrame];
    _historyView.viewDelegate = self;
    [self.view addSubview:_historyView];
}

- (void)requestForSearchModelCase
{
    _searchedStatus = YES;
    
    __weak ESModelSearchViewController *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:_modelListView animated:YES];
    [ESSampleRoomListModel
     requestForSampleRoomListWithOffset:_offset
     limlt:_limit
     tagStr:nil
     searchTerm:_searchString
     success:^(ESSampleRoomListModel *model)
     {
         _searchedStatus = NO;
         [weakSelf updateDataAndRefreshUIWithModel:model];
         [MBProgressHUD hideHUDForView:_modelListView animated:YES];
         
     } failure:^(NSError *error) {
         
         SHLog(@"样板间列表数据请求失败:%@", error.localizedDescription);
         _searchedStatus = NO;
         [weakSelf updateRequestFailureUI];
         [MBProgressHUD hideHUDForView:_modelListView animated:YES];
     }];
}

- (void)updateDataAndRefreshUIWithModel:(ESSampleRoomListModel *)model
{
    if (!_isLoadMore)
    {
        [_arrayDS removeAllObjects];
        [_modelListView endHeaderRefreshStatus];
    }
    else
    {
        if (model.data
            && [model.data isKindOfClass:[NSArray class]]
            && model.data.count > 0)
        {
            [_modelListView endFooterRefreshWithNoMoreDataStatus:NO];
        }
        else
        {
            [_modelListView endFooterRefreshWithNoMoreDataStatus:YES];
        }
    }
    
    if (model.data
        && [model.data isKindOfClass:[NSArray class]])
    {
        [_arrayDS addObjectsFromArray:model.data];
    }
    
    if (_arrayDS.count <= 0)
    {
        [self showNoDataIn:_modelListView
                   imgName:@"nodata_search"
                     frame:self.view.frame
                     Title:@"搜不到内容哦~\n换个关键词试试~"
               buttonTitle:nil
                     Block:nil];
    }
    else
    {
        [self removeNoDataView];
        
        [_modelListView tableViewReload];
        
        if (_showCountLabelStatus)
        {
            _showCountLabelStatus = NO;
            [_modelListView tableviewScrollToTop];
            [_modelListView showCountToast:model.count];
        }
    }
}

- (void)updateRequestFailureUI
{
    if (!_isLoadMore)
    {
        [_modelListView endHeaderRefreshStatus];
    }
    else
    {
        [_modelListView endFooterRefreshWithNoMoreDataStatus:NO];
    }
    
    [self showNoDataIn:_modelListView
               imgName:@"nodata_net"
                 frame:self.view.frame
                 Title:@"网络有问题\n刷新一下试试吧"
           buttonTitle:@"刷新"
                 Block:^
     {
         [_modelListView beginRefreshing];
     }];
}

#pragma mark - TF Target
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 50)
    {
        textField.text = [textField.text substringToIndex:50];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _editingStatus = YES;
    
    /// 显示历史搜索
    [self.view bringSubviewToFront:_historyView];

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _editingStatus = NO;
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (textField.text.length < 1)
    {
        [self showHudWithMessage:@"搜索内容不得为空"
                  hideAfterDelay:1];
        return NO;
    }
    else
    {
        //取消第一响应项
        [self.view sendSubviewToBack:_historyView];
        [self addSearchHistory:textField.text];
        [_historyView refreshHistory];

        [textField resignFirstResponder];
        _searchString = textField.text;
        [self refresh];
        return YES;
    }
}

- (void)addSearchHistory:(NSString *)searchStr
{
    if ([_arrSearchStr indexOfObject:searchStr] == NSNotFound)
    {
        [_arrSearchStr insertObject:searchStr atIndex:0];
        if (_arrSearchStr.count>5)
        {
            _arrSearchStr = [[_arrSearchStr subarrayWithRange:NSMakeRange(0, 5)] mutableCopy];
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_arrSearchStr forKey:SEARCH_CASE_MODEL_HISTORY];
    }
    else
    {
        [_arrSearchStr exchangeObjectAtIndex:0 withObjectAtIndex:[_arrSearchStr indexOfObject:searchStr]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_arrSearchStr forKey:SEARCH_CASE_MODEL_HISTORY];
    }
}

- (void)refresh
{
    _offset = 0;
    _showCountLabelStatus = YES;
    [self requestForSearchModelCase];
}

#pragma mark - Super Method
- (void)tapOnRightButton:(id)sender
{
    if (_editingStatus) {
        if (_searchedStatus == NO) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            _searchTextField.text = _searchString;
            [_searchTextField resignFirstResponder];
            [self.view sendSubviewToBack:_historyView];
        }
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - ESModelListViewDelegate
- (void)cellDidTappedWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _arrayDS.count)
    {
        return;
    }
    
    SHLog(@"第%ld个样板间被点击", (long)indexPath.row);
    ESSampleRoomModel *model = _arrayDS[indexPath.row];
    if (model.caseEnumVersion == CaseVersionNew)
    {
        ESCaseDetailViewController *caseDetailVC = [[ESCaseDetailViewController alloc] init];
        if (model.caseEnumType == CaseType2D)
        {
            [caseDetailVC setCaseId:model.caseId caseStyle:CaseStyleType2D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryPackage];
        }
        else if (model.caseEnumType == CaseType3D)
        {
            [caseDetailVC setCaseId:model.caseId caseStyle:CaseStyleType3D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryPackage];
        }
        else
        {
            SHLog(@"未知案例类型");
            return;
        }
        [self.navigationController pushViewController:caseDetailVC
                                             animated:YES];
    }
    else if (model.caseEnumVersion == CaseVersionOld)
    {
        UIViewController *caseDetailVC = nil;
        if (model.caseEnumType == CaseType2D)
        {
            caseDetailVC = [[CoCaseDetailController alloc] initWithCaseID:model.caseId];
        }
        else if (model.caseEnumType == CaseType3D)
        {
            ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
            [vc setCaseId:model.caseId caseStyle:CaseStyleType3D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryPackage];
            caseDetailVC = vc;
        }
        else
        {
            SHLog(@"未知案例类型");
            return;
        }
        [self.navigationController pushViewController:caseDetailVC
                                             animated:YES];
    }
    else
    {
        SHLog(@"未知案例版本");
    }
}

- (NSInteger)getModelCount
{
    return _arrayDS.count;
}

- (void)tableViewDidPull
{
    SHLog(@"下拉刷新");
    _isLoadMore = NO;
    _offset = 0;
    _showCountLabelStatus = YES;
    
    [self requestForSearchModelCase];
}

- (void)tableViewDidPush
{
    SHLog(@"上拉加载更多");
    _isLoadMore = YES;
    _offset += 10;
    
    [self requestForSearchModelCase];
}

#pragma mark - ESModelSearcHistoryViewDelegate
- (NSInteger)getModelSearchHistoryRowsCount
{
    if (_arrSearchStr
        && _arrSearchStr.count > 0)
    {
        return _arrSearchStr.count + 1;
    }
    
    return 0;
}

- (void)historyItemDidTapped:(NSIndexPath *)indexPath
{
    if (_arrSearchStr.count > indexPath.row - 1)
    {
        NSString *hisString = [NSString stringWithFormat:@"%@", _arrSearchStr[indexPath.row - 1]];
        if (![_searchString isEqualToString:hisString])
        {
            _searchString = hisString;
            _searchTextField.text = _searchString;
            [_searchTextField resignFirstResponder];
            [self.view sendSubviewToBack:_historyView];
            [self addSearchHistory:hisString];
            [_historyView refreshHistory];
            [self refresh];
        }
    }
}

#pragma mark - ESModelSearcHistoryItemCellDelegate
- (NSString *)getSearchHistoryItemTextWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row - 1 < _arrSearchStr.count)
    {
        return _arrSearchStr[indexPath.row - 1];
    }
    
    return @"";
}

#pragma mark - ESModelSearcHistoryCleanCellDelegate
- (NSString *)getSearchHistoryTipTextWithIndexPath:(NSIndexPath *)indexPath
{
    return @"最近搜索记录";
}

- (void)cleanButtonDidTapped
{
    [_arrSearchStr removeAllObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:SEARCH_CASE_MODEL_HISTORY];
    [_historyView refreshHistory];
}

#pragma mark - ESModelListCellDelegate
- (ESSampleRoomModel *)getModelListCellDataWithIndexPath:(NSIndexPath *)indexPath
{
    return _arrayDS[indexPath.row];
}

#pragma mark - HUD
- (void)showHudWithMessage:(NSString *)message
            hideAfterDelay:(NSTimeInterval)afterDelay
{
    if (!message
        || ![message isKindOfClass:[NSString class]])
    {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_modelListView
                                              animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:afterDelay];
}

@end
