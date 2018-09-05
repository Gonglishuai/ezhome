
#import "ESCaseFittingRoomHomeViewController.h"
#import "ESCaseFittingRoomHomeView.h"
#import "ESCaseFittingRoomListViewController.h"
#import "ESFittingHomeModel.h"
#import "MBProgressHUD.h"
#import "Assistant.h"
//#import "ESCaseDetailViewController.h"
#import "SDCycleScrollView.h"
#import <ESFoundation/UMengServices.h>
#import "DefaultSetting.h"
#import <ESBasic/ESDevice.h>

@interface ESCaseFittingRoomHomeViewController ()<ESCaseFittingRoomHomeViewDelegate>

@end

@implementation ESCaseFittingRoomHomeViewController
{
    ESCaseFittingRoomHomeView *_fittingRoomView;
    ESFittingHomeModel *_model;
    SDCycleScrollView *_loopView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initData];
    
    [self initUI];
    
    [_fittingRoomView beginRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestData:NO];
    
    [self refreshTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self invalidateTimer];
}

- (void)initData
{
    
}

- (void)initUI
{
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"家装试衣间";
    
    CGFloat frameHeight = 0.0f;
    if (self.needBackBtn)
    {
        self.leftButton.hidden = NO;
        frameHeight = SCREEN_HEIGHT - NAVBAR_HEIGHT;
    }
    else
    {
        self.leftButton.hidden = YES;
        frameHeight = SCREEN_HEIGHT - NAVBAR_HEIGHT - TABBAR_HEIGHT;
    }
    CGRect fittingRoomFrame = CGRectMake(
                                         0,
                                         NAVBAR_HEIGHT,
                                         SCREEN_WIDTH,
                                         frameHeight
                                         );
    _fittingRoomView = [[ESCaseFittingRoomHomeView alloc] initWithFrame:fittingRoomFrame];
    _fittingRoomView.viewDelegate = self;
    [self.view addSubview:_fittingRoomView];
}

- (void)requestData:(BOOL)showHUD
{
    __weak ESCaseFittingRoomHomeViewController *weakSelf = self;
    if (showHUD)
    {
        [MBProgressHUD showHUDAddedTo:_fittingRoomView animated:YES];
    }
    [ESFittingHomeModel requestForCaseFittingRoomHomeSuccess:^(ESFittingHomeModel *model) {
        
        [weakSelf updateDataAndRefreshUIWithModel:model];
        [MBProgressHUD hideHUDForView:_fittingRoomView animated:YES];
        
    } failure:^(NSError *error) {
        
        SHLog(@"试衣间列表数据请求失败:%@", error.localizedDescription);
        
        [weakSelf updateRequestFailureUI];
        [MBProgressHUD hideHUDForView:_fittingRoomView animated:YES];
    }];
}

- (void)updateDataAndRefreshUIWithModel:(ESFittingHomeModel *)model
{
    [_fittingRoomView endHeaderRefresh];

    _model = model;
    
    if ((!_model.banner
         || ![_model.banner isKindOfClass:[NSArray class]]
         || _model.banner.count <= 0)
        && (!_model.sampleList
            || ![_model.sampleList isKindOfClass:[NSArray class]]
            || _model.sampleList.count <= 0))
    {
        [self showNoDataIn:_fittingRoomView
                   imgName:@"nodata_datas"
                     frame:self.view.frame
                     Title:@"啊哦~暂时没有数据~"
               buttonTitle:nil
                     Block:nil];
    }
    else
    {
        [self removeNoDataView];
        
        [_fittingRoomView tableViewReload];
    }
}

- (void)updateRequestFailureUI
{
    [_fittingRoomView endHeaderRefresh];
    
    [self showNoDataIn:_fittingRoomView
               imgName:@"nodata_net"
                 frame:self.view.frame
                 Title:@"网络有问题\n刷新一下试试吧"
           buttonTitle:@"刷新"
                 Block:^
     {
         [_fittingRoomView beginRefresh];
     }];
}

#pragma mark - ESCaseFittingRoomHomeViewDelegate
- (NSInteger)getFittingRoomTableViewRowsAtSection:(NSInteger)section
{
    if ([_model.sampleList isKindOfClass:[NSArray class]]
        && [_model.banner isKindOfClass:[NSArray class]])
    {
        return _model.sampleList.count + 1;
    }
    
    return 0;
}

- (void)fittingRoomHomeDidPull
{
    SHLog(@"下拉刷新");
    [self requestData:YES];
}

#pragma mark - ESCaseFittingRoomHomeHeaderCellDelegate
- (NSArray <ESFittingRoomBannerModel *> *)getFittingRoomHeaderDataWithIndexPath:(NSIndexPath *)indexPath
{
    return _model.banner;
}

- (void)loopViewDidCreated:(SDCycleScrollView *)loopView
{
    if (loopView
        && [loopView isKindOfClass:[SDCycleScrollView class]])
    {
        _loopView = loopView;
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView
   didSelectItemAtIndex:(NSInteger)index
{
    SHLog(@"轮播图的第 %ld 张图片被点击", index);
    if (_model.banner.count > index)
    {
        //banner埋点统计
        [UMengServices eventWithEventId:Event_fitting_room_banner attributes:@{@"index":@(index)}];
        ESFittingRoomBannerModel *model = _model.banner[index];
        [Assistant jumpWithShowCaseDic:model.dataDic
                        viewController:self];
    }
}

#pragma mark - ESCaseFittingRoomHomeCellDelegate
- (ESFittingSampleModel *)getFittingRoomHomeCellDataWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row - 1 < _model.sampleList.count)
    {
        return _model.sampleList[indexPath.row - 1];
    }
    
    return nil;
}

- (void)categoryImageDidTappedWithIndex:(NSInteger)index
{
    SHLog(@"第 %ld 类试衣间被点击", index);
    if (index - 1 < _model.sampleList.count)
    {
        //入口埋点统计
        switch (index - 1) {
            case 0:
                [UMengServices eventWithEventId:Event_fitting_room_parlor attributes:@{@"location":@"entry"}];
                break;
            case 1:
                [UMengServices eventWithEventId:Event_fitting_room_study attributes:@{@"location":@"entry"}];
                break;
            case 2:
                [UMengServices eventWithEventId:Event_fitting_room_kitchen attributes:@{@"location":@"entry"}];
                break;
            default:
                break;
        }
        ESFittingSampleModel *sampleModel = _model.sampleList[index - 1];
        ESCaseFittingRoomListViewController *vc = [[ESCaseFittingRoomListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.sampModel = sampleModel;
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
}

- (void)categoryMoreDidTappedWithIndex:(NSInteger)index {
    //更多埋点统计
    switch (index - 1) {
        case 0:
            [UMengServices eventWithEventId:Event_fitting_room_parlor attributes:@{@"location":@"more"}];
            break;
        case 1:
            [UMengServices eventWithEventId:Event_fitting_room_study attributes:@{@"location":@"more"}];
            break;
        case 2:
            [UMengServices eventWithEventId:Event_fitting_room_kitchen attributes:@{@"location":@"more"}];
            break;
        default:
            break;
    }
    
    [self categoryImageDidTappedWithIndex:index];
}

- (void)caseImageDidTappedWithIndex:(NSInteger)index
                          caseIndex:(NSInteger)caseIndex
{
    SHLog(@"第 %ld 类试衣间下的第 %ld 张图片被点击", index, caseIndex);
    if (index - 1 < _model.sampleList.count) {
        ESFittingSampleModel *sampleModel = _model.sampleList[index - 1];
        if ([sampleModel isKindOfClass:[ESFittingSampleModel class]]
            && [sampleModel.caseList isKindOfClass:[NSArray class]]
            && caseIndex < sampleModel.caseList.count) {
            //试衣间案例统计
            NSMutableDictionary *analysisDic = [NSMutableDictionary dictionary];
            switch (caseIndex) {
                case 0:
                    [analysisDic setObject:@"left" forKey:@"location"];
                    break;
                case 1:
                    [analysisDic setObject:@"middle" forKey:@"location"];
                    break;
                case 2:
                    [analysisDic setObject:@"right" forKey:@"location"];
                    break;
                default:
                    break;
            }
            
            switch (index - 1) {
                case 0:
                    [UMengServices eventWithEventId:Event_fitting_room_parlor attributes:analysisDic];
                    break;
                case 1:
                    [UMengServices eventWithEventId:Event_fitting_room_study attributes:analysisDic];
                    break;
                case 2:
                    [UMengServices eventWithEventId:Event_fitting_room_kitchen attributes:analysisDic];
                    break;
                default:
                    break;
            }
        }
        ESFittingCaseModel *caseModel = sampleModel.caseList[caseIndex];
        
        NSString *brandId = caseModel.brandId?caseModel.brandId:@"";
        NSString *caseId = caseModel.caseId?caseModel.caseId:@"";
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:brandId forKey:@"brandId"];
        [info setObject:caseId forKey:@"caseId"];
        [info setObject:@"3d" forKey:@"caseType"];
        [MGJRouter openURL:@"/Case/CaseDetail/FittingRoom" withUserInfo:info completion:nil];
    }
}

#pragma mark - Methods
- (void)refreshTimer
{
    if (_loopView)
    {
        [_loopView refreshTimer];
    }
}

- (void)invalidateTimer
{
    if (_loopView)
    {
        [_loopView invalidateTimer];
    }
}

#pragma mark - Super Method
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
