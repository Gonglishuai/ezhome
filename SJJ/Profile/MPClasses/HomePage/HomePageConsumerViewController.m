//
//  HomePageConsumerViewController.m
//  Consumer
//
//  Created by jiang on 2017/5/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "HomePageConsumerViewController.h"
#import "ESIMSessionListViewController.h"
#import "SHRNViewController.h"
#import "LoopCollectionViewCell.h"
#import "HeaderCollectionReusableView.h"
#import "SelectExampleSmallCell.h"
#import "DesignersCollectionViewCell.h"
#import "GrayFooterCollectionReusableView.h"
#import "JRWebViewController.h"
#import "HtmlURL.h"
#import "JRHomeAPI.h"
#import "HomeConsumerExampleModel.h"
#import "HomeConsumerDesignerModel.h"
#import "Assistant.h"
#import "MPDesignerInfoModel.h"
#import "CoCaseDetailController.h"
#import "SHMemberModel.h"
#import "JRKeychain.h"
#import "MPFindDesignersViewController.h"
#import "CheckMoreReusableView.h"
#import "ESNoMoreReusableView.h"
#import "MBProgressHUD+NJ.h"
#import "ESNIMManager.h"
#import "ESAppConfigManager.h"
#import <ESFoundation/UMengServices.h>
#import "ESCaseDetailViewController.h"
#import <ESMallAssets.h>
#import "ESHomePageRecommendCell.h"
#import "ESHomePageHeadLineCell.h"
#import "ESHomePageItemsCell.h"
#import "ESFinanceServices.h"
#import "ESCaseFittingRoomHomeViewController.h"
#import "JRLocationServices.h"
#import "ESHomePageNavigatorBar.h"
#import "MPSearchCaseViewController.h"
#import "ESHomePageHeadLoopCell.h"
#import "ESDiyRefreshHeader.h"
#import "ESAppConfigManager.h"

@interface HomePageConsumerViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
ESNIMManagerDelegate,
ESHomePageHeadItemCellDelegate,
ESHomePageHeadLineCellDelegate,
ESHomePageRecommendCellDelegate,
ESHomePageNavigatorBarDelegate,
ESHomePageHeadLoopCellDelegate,
ESLoginManagerDelegate
>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;

@property (strong, nonatomic) NSMutableArray *showCaseDatas;
@property (strong, nonatomic) NSMutableArray *exampleDatas;
@property (strong, nonatomic) NSMutableArray *designerDatas;
@property (strong, nonatomic) NSArray *navigations;
@property (strong, nonatomic) NSArray *recommends;
@property (strong, nonatomic) NSArray *headlines;
@property (strong, nonatomic) NSDictionary *extend_dic;//扩展字段
@property (assign, nonatomic)BOOL isRefresh;
@end

@implementation HomePageConsumerViewController
{
    ESHomePageHeadLineCell *_headLineCell;
    ESHomePageHeadLoopCell *_headerLoopImageCell;
    ESHomePageNavigatorBar *_homePageBar;
    UIView *_headerBackgroundView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkMemberType];
    [self updatePersonalInfoBtn];
    [self setTimers];
    [self updateLocation];
    
    /// 将导航条提到最前
    [self.view bringSubviewToFront:_homePageBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initHomePageNavigationBar];
    
    // Do any additional setup after loading the view.
    _showCaseDatas = [NSMutableArray array];
    _exampleDatas = [NSMutableArray array];
    _designerDatas = [NSMutableArray array];
    _navigations = @[];
    _headlines = @[];
    _recommends = @[];
    
    [self steCollectionView];
    [self getData];
    [[ESNIMManager sharedManager] addESIMDelegate:self];
    [[ESLoginManager sharedManager] addLoginDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self invalidateTimers];
}

- (void)initHomePageNavigationBar
{
    [self.navgationImageview removeFromSuperview];
    _homePageBar = [ESHomePageNavigatorBar homePageNavigatorBar];
    _homePageBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    _homePageBar.delegate = self;
    [self.view addSubview:_homePageBar];
}

- (void)updateLocation
{
    __weak ESHomePageNavigatorBar *weakBar = _homePageBar;
    [[JRLocationServices sharedInstance] requestLocation:^(JRCityInfo *cityInfo) {
        dispatch_async_get_main_safe((^{
            
            NSString *cityName = @"北京";
            if (cityInfo
                && [cityInfo isKindOfClass:[JRCityInfo class]]
                && cityInfo.locatedCityName
                && [cityInfo.locatedCityName isKindOfClass:[NSString class]])
            {
                NSString *locatedCityName = [NSString stringWithFormat:@"%@", cityInfo.locatedCityName];
                if (locatedCityName.length > 2
                    && [[locatedCityName substringFromIndex:locatedCityName.length - 1] isEqualToString:@"市"])
                {
                    cityName = [locatedCityName substringToIndex:locatedCityName.length - 1];
                }
            }
            weakBar.cityLabel.text = cityName;
        }))
    }];
}

#pragma mark - PersonalInfo
-(void)updatePersonalInfoBtn {
    if ([ESLoginManager sharedManager].isLogin) {
//        SHMember *member = [[SHMember alloc]init];
        NSInteger unReadCount = [[ESNIMManager sharedManager] getNIMAllUnreadCount];
        _homePageBar.unreadStatusView.hidden = unReadCount <= 0;
    }
}

- (void)steCollectionView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
//    _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT) collectionViewLayout:_collectionViewLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
//    _collectionView.backgroundColor = ColorFromRGA(0xf8f8f8, 1);
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"LoopCollectionViewCell" bundle:[ESMallAssets hostBundle]] forCellWithReuseIdentifier:@"LoopCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"SelectExampleSmallCell" bundle:nil] forCellWithReuseIdentifier:@"SelectExampleSmallCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"DesignersCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"DesignersCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESHomePageItemsCell" bundle:nil] forCellWithReuseIdentifier:@"ESHomePageItemsCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESHomePageHeadLineCell" bundle:nil] forCellWithReuseIdentifier:@"ESHomePageHeadLineCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESHomePageRecommendCell" bundle:nil] forCellWithReuseIdentifier:@"ESHomePageRecommendCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESHomePageHeadLoopCell" bundle:nil] forCellWithReuseIdentifier:@"ESHomePageHeadLoopCell"];

    [_collectionView registerNib:[UINib nibWithNibName:@"HeaderCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionReusableView"];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"GrayFooterCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GrayFooterCollectionReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"GrayFooterCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"CheckMoreReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CheckMoreReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESNoMoreReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ESNoMoreReusableView"];
    
    WS(weakSelf)
    _collectionView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        weakSelf.isRefresh = YES;
        [weakSelf getData];
    }];
    
    _headerBackgroundView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    _headerBackgroundView.backgroundColor = ColorFromRGA(0xeeeeee, 1);
    [_collectionView insertSubview:_headerBackgroundView atIndex:0];
    
    [self.view addSubview:_collectionView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UICollectionView class]])
    {
        CGPoint point = scrollView.contentOffset;
        if (point.y < 0)
        {
            CGRect rect = _headerBackgroundView.frame;
            rect.origin.y = point.y;
            rect.size.height = -point.y;
            _headerBackgroundView.frame = rect;
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 7;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        case 1:
        case 2:
        case 3:
            return 1;
        case 4:
            return _exampleDatas.count;
            break;
        case 5:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        
        _headerLoopImageCell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESHomePageHeadLoopCell" forIndexPath:indexPath];
        _headerLoopImageCell.cellDelegate = self;
        [_headerLoopImageCell updateCellWithIndexPath:indexPath];
        [_headerLoopImageCell updateBottomSpaceStatus:YES];
        return _headerLoopImageCell;
        
    } else if (1 == indexPath.section) {
        
        ESHomePageItemsCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESHomePageItemsCell" forIndexPath:indexPath];
        cell.cellDelegate = self;
        [cell updateCellWithIndexPath:indexPath];
        return cell;

    } else if (2 == indexPath.section) {
        
        _headLineCell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESHomePageHeadLineCell" forIndexPath:indexPath];
        _headLineCell.cellDelegate = self;
        [_headLineCell updateCellWithIndexPath:indexPath];
        return _headLineCell;
    } else if (3 == indexPath.section) {
        
        ESHomePageRecommendCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESHomePageRecommendCell" forIndexPath:indexPath];
        cell.cellDelegate = self;
        [cell updateCellWithIndexPath:indexPath];
        return cell;
    } else if (4 == indexPath.section) {
        SelectExampleSmallCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"SelectExampleSmallCell" forIndexPath:indexPath];
        if (_exampleDatas.count > indexPath.row) {
            HomeConsumerExampleModel *model = _exampleDatas[indexPath.row];
            [cell setModel:model];
        }
        return cell;
    } else if (5 == indexPath.section){
        DesignersCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"DesignersCollectionViewCell" forIndexPath:indexPath];
        WS(weakSelf)
        [cell setDataSource:_designerDatas calculateBlock:^(NSInteger index) {
            SHLog(@"-----%ld-----", (long)index);
            if (index == 10) {
                MPFindDesignersViewController *designers = [[MPFindDesignersViewController alloc] init];
                designers.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:designers animated:YES];
                return ;
            }
            
            [UMengServices eventWithEventId:Event_consumer_home_designer attributes:Event_Param_position(index)];
            if (weakSelf.designerDatas == nil || weakSelf.designerDatas.count <= index) {
                return;
            }
            HomeConsumerDesignerModel *model = weakSelf.designerDatas[index];
            MPDesignerInfoModel *designerInfo = [[MPDesignerInfoModel alloc] init];
            NSString *mid = model.designer_id ? model.designer_id : @"";
            if (![mid isEqualToString:@""]) {
                designerInfo.member_id = [NSNumber numberWithInteger:[mid integerValue]];
            }
            designerInfo.hs_uid = model.hs_uid ? model.hs_uid : @"";
            
            
            NSDictionary *dict = [NSDictionary dictionaryWithObject:designerInfo.member_id forKey:@"designId"];
            [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
            
        }];
        return cell;
    } else {
        UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

        if (4 == indexPath.section) {
        SHLog(@"-----%ld-----", (long)indexPath.row);
        if (_exampleDatas.count > indexPath.row) {
            [UMengServices eventWithEventId:Event_consumer_home_case attributes:Event_Param_position(indexPath.item)];
            HomeConsumerExampleModel *model = _exampleDatas[indexPath.row];
            
            UIViewController *caseDetailVC = nil;
            if ([model.is_new boolValue])
            {
                ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
                [vc setCaseId:model.case_id caseStyle:CaseStyleType2D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
                caseDetailVC = vc;

            }
            else
            {
                caseDetailVC = [[CoCaseDetailController alloc] initWithCaseID:model.case_id ? model.case_id : @""];
            }
            caseDetailVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:caseDetailVC animated:YES];
        }
        
    }
}

- (void)jumpToBBSWithUrl:(NSString *)url {
    if (url == nil || [url isKindOfClass:[NSNull class]] || [url isEqualToString:@""]) {
        [MBProgressHUD showError:@"敬请期待~" toView:self.view];
        return;
    }
    JRWebViewController *webviewCon = [[JRWebViewController alloc] init];
    [webviewCon setTitle:@"" url:url];
    [webviewCon setNavigationBarHidden:YES
                         hasBackButton:NO];
    [webviewCon hideRefreshStatus];
    webviewCon.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webviewCon animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return CGSizeMake(SCREEN_WIDTH-0.1, (125/375.0f)*(SCREEN_WIDTH-0.1) + 4);
            break;
        case 1:
            return CGSizeMake(SCREEN_WIDTH-0.1, 84);
            break;
        case 2:
            return CGSizeMake(SCREEN_WIDTH-0.1, 46.0f);
            break;
        case 3:
            return CGSizeMake(SCREEN_WIDTH-0.1, (164/374.0) * SCREEN_WIDTH-0.1);
            break;
        case 4:
            return CGSizeMake((SCREEN_WIDTH-40-1)/2, 0.88*(SCREEN_WIDTH-40-1)/2);
            break;
        case 5:
            return CGSizeMake(SCREEN_WIDTH-0.1, 0.96*(SCREEN_WIDTH-0.1));
            break;
        default:
            return CGSizeMake(SCREEN_WIDTH-0.1, 0.001);
            break;
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (0 == section || 1 == section || 2 == section || 3 == section || 5 == section) {
        return UIEdgeInsetsMake(0.1, 0.1, 0.1, 0.1);
    } else if (4 == section) {
        return UIEdgeInsetsMake(20, 15, 20, 15);
    } else {
        return UIEdgeInsetsMake(20, 0.1, 20, 0.1);
    }
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (4 == section) {
        return 10;
    }
    return 0.001;
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (4 == section) {
        return 15;
    }
    return 0.001;
}

#pragma mark - GrayFooterCollectionReusableView
- (void)moreButtonDidTapped
{
    [self jumpToBBSWithUrl:[ESAppConfigManager sharedManager].appConfig.bbs_home_url];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

        HeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionReusableView" forIndexPath:indexPath];
        if (4 == indexPath.section) {
            [header setTitle:@"精选案例" subTitle:@"SELECTED CASE"];
        } else if (5 == indexPath.section) {
            [header setTitle:@"遇见设计师" subTitle:@"MEETING DESIGNER"];
            header.lineLabel.hidden = YES;
        } else {
            [header setTitle:@"" subTitle:@""];
        }
        return header;
        
    } else {
        if (5 == indexPath.section) {
            CheckMoreReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CheckMoreReusableView" forIndexPath:indexPath];
            footer.backgroundColor = [UIColor whiteColor];
            WS(weakSelf)
            [footer setBlock:^{                
                [UMengServices eventWithEventId:Event_consumer_home_designer_more];
                MPFindDesignersViewController *designers = [[MPFindDesignersViewController alloc] init];
                designers.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:designers animated:YES];
            }];
            return footer;
        } else if (6 == indexPath.section) {
            ESNoMoreReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ESNoMoreReusableView" forIndexPath:indexPath];
            return footer;
        } else {
            GrayFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView" forIndexPath:indexPath];
            footer.titleLabel.hidden = YES;
            return footer;
        }
        
        
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (0 == section || 1 == section || 2 == section || 3 == section || 6 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    } else {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.18*SCREEN_WIDTH);
        return size;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (4 == section || 3 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 10);
        return size;
    } else if (5 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 60);
        return size;
    } else {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    }

}

- (void)getData {
    WS(weakSelf)
    [JRHomeAPI getHomePageWithType:@"1" loginStatus:[ESLoginManager sharedManager].isLogin Success:^(NSDictionary *dict) {
        SHLog(@"%@", dict);
        
        [weakSelf.showCaseDatas removeAllObjects];
        [weakSelf.exampleDatas removeAllObjects];
        [weakSelf.designerDatas removeAllObjects];
        NSMutableDictionary *datasSourse = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSArray *showcases = datasSourse[@"banner"] ? datasSourse[@"banner"] : [NSArray array];
        NSArray *cases = datasSourse[@"cases"] ? datasSourse[@"cases"] : [NSArray array];
        NSArray *designers = datasSourse[@"designers"] ? datasSourse[@"designers"] : [NSArray array];
        for (NSDictionary *dic in showcases) {
            [weakSelf.showCaseDatas addObject:dic];
        }
        for (NSDictionary *dic in cases) {
            [weakSelf.exampleDatas addObject:[HomeConsumerExampleModel createModelWithDic:dic]];
        }
        for (NSDictionary *dic in designers) {
            [weakSelf.designerDatas addObject:[HomeConsumerDesignerModel createModelWithDic:dic]];
        }
        if (dict[@"headline"]
            && [dict[@"headline"] isKindOfClass:[NSArray class]])
        {
            weakSelf.headlines = [dict[@"headline"] copy];
        }
        if (dict[@"navigations"]
            && [dict[@"navigations"] isKindOfClass:[NSArray class]])
        {
            weakSelf.navigations = [dict[@"navigations"] copy];
        }
        if (dict[@"recommend"]
            && [dict[@"recommend"] isKindOfClass:[NSArray class]])
        {
            weakSelf.recommends = [dict[@"recommend"] copy];
        }
        if (dict[@"extend_dic"]
            && [dict[@"extend_dic"] isKindOfClass:[NSDictionary class]])
        {
            weakSelf.extend_dic = dict[@"extend_dic"];
        }

        [weakSelf.collectionView.mj_header endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.collectionView reloadData];

        
    } failure:^(NSError *error) {
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        SHLog(@"%@", error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 检测用户是否设置用户类型
- (void)checkMemberType
{
    // 未登录状态不处理
    if (![ESLoginManager sharedManager].isLogin) return;
    
    // 用户类型存在不处理
    if ([JRKeychain loadSingleUserInfo:UserInfoCodeType].length > 0) return;
    
    // 未设置用户类型, 去设置
//    SHRNViewController *setMemberTypeController = [[SHRNViewController alloc] init];
//    [self presentViewController:setMemberTypeController animated:NO completion:nil];
    [MGJRouter openURL:@"/UserCenter/LogIn"];
}

#pragma mark - ESNIMManagerDelegate
- (void)hasNewMessage:(BOOL)newMsg {
    self.msgCenterUnReadView.hidden = !newMsg;
}

#pragma mark - ESHomePageHeadItemCellDelegate
- (NSArray *)getHeadItemsInformation
{
    return self.navigations;
}

- (void)itemDidTappedWithType:(NSInteger)index
{
    SHLog(@"navigations被点击: %ld", index);
    if (self.navigations
        && [self.navigations isKindOfClass:[NSArray class]]
        && index < self.navigations.count)
    {
        [Assistant jumpWithShowCaseDic:self.navigations[index] viewController:self];
    }
}

#pragma mark - ESHomePageHeadLineCellDelegate
- (NSArray *)getHeadLineInformation
{
    return self.headlines;
}

- (void)headLineDidTappedWithIndex:(NSInteger)index
{
    SHLog(@"头条被点击: %ld", index);
    if (index < self.headlines.count)
    {
        [Assistant jumpWithShowCaseDic:self.headlines[index] viewController:self];
    }
}

#pragma mark - HeaderLineTimer
- (void)setTimers
{
    if (_headLineCell
        && [_headLineCell isKindOfClass:[ESHomePageHeadLineCell class]])
    {
        [_headLineCell setupTimer];
    }
    if (_headerLoopImageCell
        && [_headerLoopImageCell isKindOfClass:[ESHomePageHeadLoopCell class]])
    {
        [_headerLoopImageCell setupTimer];
    }
}

- (void)invalidateTimers
{
    if (_headLineCell
        && [_headLineCell isKindOfClass:[ESHomePageHeadLineCell class]])
    {
        [_headLineCell invalidateTimer];
    }
    if (_headerLoopImageCell
        && [_headerLoopImageCell isKindOfClass:[ESHomePageHeadLoopCell class]])
    {
        [_headerLoopImageCell invalidateTimer];
    }
}

#pragma mark - ESHomePageRecommendCellDelegate
- (NSArray *)getRecommendInformation
{
    return self.recommends;
}

- (void)recommendDidTappedWithType:(ESHomePageRecommendType)type
{
    SHLog(@"recommend模块被点击: 第%ld区", type);
    if (self.recommends
        && [self.recommends isKindOfClass:[NSArray class]]
        && type < self.recommends.count)
    {
        [Assistant jumpWithShowCaseDic:self.recommends[type] viewController:self];
    }
}

#pragma mark - ESHomePageHeadLoopCellDelegate
- (NSArray *)getHeadLoopInformation
{
    NSMutableArray *imgArray = [NSMutableArray array];
    for (NSDictionary *caseDic in _showCaseDatas) {
        NSMutableDictionary *dic = caseDic[@"extend_dic"] ? caseDic[@"extend_dic"] : [NSMutableDictionary dictionary];
        NSString *imgUrl = dic[@"image"] ? dic[@"image"] : @"";
        if ([imgUrl hasPrefix:@"http"]) {
            [imgArray addObject:imgUrl];
        } else {
            [imgArray addObject:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgUrl]];
        }
    }
    
    return [imgArray copy];
}

- (void)imageDidTappedWithIndex:(NSInteger)index
{
    SHLog(@"第%ld张图被点击", index);
    if (index < self.showCaseDatas.count)
    {
        [UMengServices eventWithEventId:Event_consumerhome_banner attributes:Event_Param_position(index)];
        [Assistant jumpWithShowCaseDic:self.showCaseDatas[index] viewController:self];
    }
}

#pragma mark - ESHomePageNavigatorBarDelegate
- (void)leftButtonDidTapped
{
    [self updateLocation];
    
    [SHAlertView showAlertWithMessage:@"不好意思，现在只开通了北京地区哦~" autoDisappearAfterDelay:1.2f];
}

- (void)rightButtonDidTapped
{
    if ([ESLoginManager sharedManager].isLogin) {
        ESIMSessionListViewController *sessionListVc = [[ESIMSessionListViewController alloc] init];
        sessionListVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:sessionListVc animated:YES];
    } else {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    }
}

- (void)searchButtonDidTapped
{
    MPSearchCaseViewController *searchVC = [[MPSearchCaseViewController alloc] init];
    searchVC.searchType = @"3D";
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - ESLoginManagerDelegate
- (void)onLogin {
    [self getData];
}

- (void)onLogout {
    [self getData];
}
#pragma mark - Dealloc
- (void)dealloc {
    [[ESNIMManager sharedManager] removeESIMDelegate:self];
    [[ESLoginManager sharedManager] removeLoginDelegate:self];
    [self invalidateTimers];
}

@end
