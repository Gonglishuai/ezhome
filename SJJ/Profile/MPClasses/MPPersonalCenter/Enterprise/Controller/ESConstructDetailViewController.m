
#import "ESConstructDetailViewController.h"
#import "ESConstructDetailView.h"
#import "ESConstructDetailModel.h"
#import "ESTransactionDetailViewController.h"
#import "MBProgressHUD.h"

@interface ESConstructDetailViewController ()<ESConstructDetailViewDelegate>

@end

@implementation ESConstructDetailViewController
{
    ESConstructDetailView *_constructDetailView;
    ESConstructDetailModel *_detailModel;
    NSString *_projectNum;
}

- (instancetype)initWithprojectId:(NSString *)projectNum;
{
    self = [super init];
    if (self)
    {
        if (projectNum
            && [projectNum isKindOfClass:[NSString class]])
        {
            _projectNum = projectNum;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    [self initData];
    
    [self initUI];
    
    [self requestData];
}

- (void)initData
{
    
}

- (void)initUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rightButton.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleLabel.text = @"项目详情";
    
    CGRect rect = CGRectMake(
                             0,
                             NAVBAR_HEIGHT,
                             SCREEN_WIDTH,
                             SCREEN_HEIGHT - NAVBAR_HEIGHT
                             );
    _constructDetailView = [[ESConstructDetailView alloc] initWithFrame:rect];
    _constructDetailView.viewDelegate = self;
    [self.view addSubview:_constructDetailView];
}

- (void)requestData
{
    __weak ESConstructDetailViewController *weakSelf = self;
    __weak UIView *weakView = _constructDetailView;
    [MBProgressHUD showHUDAddedTo:_constructDetailView animated:YES];
    [ESConstructDetailModel requestProjectDetailWithId:_projectNum
                                               success:^(ESConstructDetailModel *model)
    {
     
        [weakSelf updateDataAndRefreshUIWithModel:model];
        [MBProgressHUD hideHUDForView:weakView animated:YES];
        
    } failure:^(NSError *error) {
        
        SHLog(@"施工订单列表:%@", error.localizedDescription);
        
        [weakSelf updateRequestFailureUI];
        [MBProgressHUD hideHUDForView:weakView animated:YES];
    }];
}

- (void)updateDataAndRefreshUIWithModel:(ESConstructDetailModel *)model
{
    _detailModel = model;
    
    [self removeNoDataView];
    
    [_constructDetailView tableViewReload];
}

- (void)updateRequestFailureUI
{
    __weak ESConstructDetailViewController *weakSelf = self;
    [self showNoDataIn:_constructDetailView
               imgName:@"nodata_net"
                 frame:self.view.frame
                 Title:@"网络有问题\n刷新一下试试吧"
           buttonTitle:@"刷新"
                 Block:^
     {
         [weakSelf requestData];
     }];
}

#pragma mark - ESConstructDetailViewDelegate
- (NSInteger)getConstructDetailSections
{
    if ([_detailModel isKindOfClass:[ESConstructDetailModel class]])
    {
        return _detailModel.dataSourceDesigner.count;
    }
    
    return 0;
}

- (NSInteger)getConstructDetailRowsWithSection:(NSInteger)section
{
    if (section < _detailModel.dataSourceDesigner.count)
    {
        NSArray *arr = _detailModel.dataSourceDesigner[section];
        return arr.count;
    }
    
    return 0;
}

- (void)cellDidTappedWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= _detailModel.dataSourceDesigner.count)
    {
        return;
    }
    NSArray *arr = _detailModel.dataSourceDesigner[indexPath.section];
    if (indexPath.row >= arr.count)
    {
        return;
    }
    NSDictionary *dict = arr[indexPath.row];
    if (dict
        && [dict isKindOfClass:[NSDictionary class]])
    {
        if (dict[@"showArrow"]
            && [dict[@"showArrow"] boolValue])
        {
            SHLog(@"查看支付明细");

            ESTransactionDetailViewController *vc = [[ESTransactionDetailViewController alloc] initWithOrderNumber:_detailModel.sourceOrderId];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - ESConstructDetailCellDelegate
- (NSDictionary *)getDetailDataWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _detailModel.dataSourceDesigner.count)
    {
        NSArray *arr = _detailModel.dataSourceDesigner[indexPath.section];
        if (indexPath.row < arr.count)
        {
            return arr[indexPath.row];
        }
    }
    
    return nil;
}

#pragma mark - Super Method
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
