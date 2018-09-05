//
//  HomePageDesignerViewController.m
//  Consumer
//
//  Created by jiang on 2017/5/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "HomePageDesignerViewController.h"
#import "DesignerExampleViewController.h"
#import "ESIMSessionListViewController.h"
#import "SHRNViewController.h"
#import "LoopCollectionViewCell.h"
#import "ItemDesignerCell.h"
#import "HeaderCollectionReusableView.h"
#import "PerfectInfoCell.h"
#import "SelectExampleCell.h"
#import "ESHotTalkCollectionViewCell.h"
#import "EZHome-Swift.h"
#import "ESDesignerInfoController.h"
#import "JRWebViewController.h"
#import "HtmlURL.h"
#import "JRHomeAPI.h"
#import "MBProgressHUD.h"
#import "ESDiyRefreshHeader.h"
#import "Assistant.h"
#import "CoCaseDetailController.h"
#import "MPCaseBaseModel.h"
#import "JRKeychain.h"
#import "CheckMoreReusableView.h"
#import "CoHomeBaseViewController.h"
#import "ESNIMManager.h"
#import "ESCaseDetailViewController.h"
#import "MBProgressHUD+NJ.h"
#import "GrayFooterCollectionReusableView.h"
#import "ESAppConfigManager.h"
#import <ESFoundation/UMengServices.h>
#import "HomeConsumerExampleModel.h"
#import <ESMallAssets.h>

@interface HomePageDesignerViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, ESNIMManagerDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (strong, nonatomic) NSMutableArray *showCaseDatas;
@property (strong, nonatomic) NSMutableArray *exampleDatas;
@property (copy, nonatomic) NSString *perfectStatus;
@property (strong, nonatomic)SDCycleScrollView *loopView;

@end

@implementation HomePageDesignerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkMemberType];
    [self updatePersonalInfoBtn];
    [self configTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:kHomePageReloadNotification object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftButton.hidden = YES;
    _perfectStatus = @"0";
    self.titleLabel.text = @"居然设计家";
    [self.rightButton setImage:[UIImage imageNamed:@"nav_chat"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"nav_chat"];
    
    

    _showCaseDatas = [NSMutableArray array];
    _exampleDatas = [NSMutableArray array];
    
    
    [self steCollectionView];
    [self getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configTimer) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTimer) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[ESNIMManager sharedManager] addESIMDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeTimer];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PersonalInfo
-(void)updatePersonalInfoBtn {
    if ([ESLoginManager sharedManager].isLogin) {
//        SHMember *member = [[SHMember alloc]init];
        NSInteger unReadCount = [[ESNIMManager sharedManager] getNIMAllUnreadCount];
        self.msgCenterUnReadView.hidden = unReadCount <= 0;
    }
}

- (void)steCollectionView {
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    //    _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //    _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT) collectionViewLayout:_collectionViewLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"LoopCollectionViewCell" bundle:[ESMallAssets hostBundle]] forCellWithReuseIdentifier:@"LoopCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ItemDesignerCell" bundle:nil] forCellWithReuseIdentifier:@"ItemDesignerCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"PerfectInfoCell" bundle:nil] forCellWithReuseIdentifier:@"PerfectInfoCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"SelectExampleCell" bundle:nil] forCellWithReuseIdentifier:@"SelectExampleCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"ESHotTalkCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ESHotTalkCollectionViewCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"HeaderCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"CheckMoreReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CheckMoreReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"GrayFooterCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GrayFooterCollectionReusableView"];
    [_collectionView registerNib:[UINib nibWithNibName:@"GrayFooterCollectionReusableView" bundle:[ESMallAssets hostBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView"];
    WS(weakSelf)
    _collectionView.mj_header.backgroundColor = [UIColor stec_viewBackgroundColor];
    _collectionView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    [self.view addSubview:_collectionView];
}

- (void)configTimer {
    if (_loopView) {
        [_loopView refreshTimer];
    }
}
- (void)removeTimer {
    if (_loopView) {
        [_loopView invalidateTimer];
    }
}

- (void)tapOnRightButton:(id)sender {
    if ([ESLoginManager sharedManager].isLogin) {
        ESIMSessionListViewController *sessionListVc = [[ESIMSessionListViewController alloc] init];
        sessionListVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:sessionListVc animated:YES];
    } else {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    }
}

- (ESDesProjectMainController *)pushToMyProjectList
{
    if ([ESLoginManager sharedManager].isLogin) {
        ESDesProjectMainController *vc = [[ESDesProjectMainController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        return vc;
    } else {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        return nil;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 5;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return _exampleDatas.count;
            break;
        default:
            return 0;
            break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        LoopCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"LoopCollectionViewCell" forIndexPath:indexPath];
        
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
        WS(weakSelf)
        if (imgArray.count > 0) {
            [cell setDatasImgArray:imgArray loopBlock:^(NSInteger index) {
                SHLog(@"-----%ld-----", (long)index);
                [UMengServices eventWithEventId:Event_designerhome_banner attributes:Event_Param_position((long)index)];
                [Assistant jumpWithShowCaseDic:weakSelf.showCaseDatas[index] viewController:weakSelf];
            }];
        }
        _loopView = cell.apView;
        return cell;
    } else if (1 == indexPath.section) {
        ItemDesignerCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ItemDesignerCell" forIndexPath:indexPath];
        [cell setDataSource:nil calculateBlock:^(NSInteger index) {
            SHLog(@"-----%ld-----", (long)index);
            [UMengServices eventWithEventId:Event_designer_home_notice attributes:Event_Param_position((long)index)];
            switch (index) {
                case 1: {
                    if ([ESLoginManager sharedManager].isLogin) {
                        self.tabBarController.selectedIndex = 2;
                        self.tabBarController.selectedViewController = self.tabBarController.viewControllers[2];
                    } else {
                        [MGJRouter openURL:@"/UserCenter/LogIn"];
                    }
                    break;
                }
                    
                case 2: {
                    if ([ESLoginManager sharedManager].isLogin) {
                        [self pushToMyProjectList];
                    } else {
                        [MGJRouter openURL:@"/UserCenter/LogIn"];
                    }
                    break;
                }
                case 3: {
                    AppDelegate *appDelegate = (id)[UIApplication sharedApplication].delegate;
                    if ([appDelegate isKindOfClass:[AppDelegate class]])
                    {
                        // 切换到商城Tab 3
                        [appDelegate resetTabsWithIndex:3];
                    }
                    break;
                }
                    
                case 4: {
                    if ([ESLoginManager sharedManager].isLogin) {
                        DesignerExampleViewController* designerExampleViewCon = [[DesignerExampleViewController alloc] init];
                        designerExampleViewCon.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:designerExampleViewCon animated:YES];
                    } else {
                        [MGJRouter openURL:@"/UserCenter/LogIn"];
                    }
                    
                    break;
                }
                default:
                    break;
            }
        }];
        return cell;
    } else if (2 == indexPath.section) {
        
        ESHotTalkCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"ESHotTalkCollectionViewCell" forIndexPath:indexPath];
        NSString *title = (indexPath.row == 0) ? @"3D云设计" : @"家装日记";
        NSString *imgName = [NSString stringWithFormat:@"home_hot_back%ld", (long)indexPath.row+1];
        [cell setTitle:title imageName:imgName];
        return cell;
    } else if (3 == indexPath.section) {
        PerfectInfoCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"PerfectInfoCell" forIndexPath:indexPath];
        if (![ESLoginManager sharedManager].isLogin) {
            [cell setTitle:@"完善资料" subTitle:@"去登录"];
        } else if ([self.perfectStatus isEqualToString:@"0"]) {
            [cell setTitle:@"完善资料" subTitle:@"完善基本信息"];
        } else {
            [cell setTitle:@"完善资料" subTitle:@"已完善"];
        }
        
        return cell;
    } else {
        HomeConsumerExampleModel *model = _exampleDatas[indexPath.row];
        SelectExampleCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"SelectExampleCell" forIndexPath:indexPath];
        [cell setNewModel:model headerBlock:^{
            //个人页面
            HomeConsumerExampleModel *caseModel = _exampleDatas[indexPath.row];
            NSDictionary *dict = [NSDictionary dictionaryWithObject:caseModel.designer_member_id forKey:@"designId"];
            [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
            
        } IMBlock:^{
            //IM聊天
            HomeConsumerExampleModel *model = _exampleDatas[indexPath.row];
            SHLog(@"%@",model.designer_member_id);
            
            if ([ESLoginManager sharedManager].isLogin) {
                [ESNIMManager startP2PSessionFromVc:self withJMemberId:model.designer_member_id andSource:ESIMSourceNone];
            } else {
                [MGJRouter openURL:@"/UserCenter/LogIn"];
            }
            
        }];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (2 == indexPath.section) {
        if (indexPath.row == 0) {
            [self jumpToBBSWithUrl:[ESAppConfigManager sharedManager].appConfig.design_url];
        } else {
            SHLog(@"家装日记");
            [self jumpToBBSWithUrl:[ESAppConfigManager sharedManager].appConfig.diary_url];
        }
        
    } else if (3 == indexPath.section) {
        SHLog(@"----(long)-%ld-----", (long)indexPath.row);
        
        [UMengServices eventWithEventId:Event_designer_home_perfect_data];
        if ([ESLoginManager sharedManager].isLogin) {
            ESDesignerInfoController *vc = [[ESDesignerInfoController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            [MGJRouter openURL:@"/UserCenter/LogIn"];
        }
        
    } else if (4 == indexPath.section) {
        SHLog(@"----(long)-%ld-----", (long)indexPath.row);
        [UMengServices eventWithEventId:Event_designer_home_case attributes:Event_Param_position(indexPath.item)];
        HomeConsumerExampleModel * model = [_exampleDatas objectAtIndex:indexPath.row];
        
        UIViewController *caseDetailVC = nil;
        if (model.is_new)
        {
            ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
            [vc setCaseId:model.case_id caseStyle:CaseStyleType2D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
            caseDetailVC = vc;
        }
        else
        {
            caseDetailVC = [[CoCaseDetailController alloc] initWithCaseID:model.case_id];
        }
        [self customPushViewController:caseDetailVC animated:YES];
        
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
            return CGSizeMake(SCREEN_WIDTH-0.1, 0.5*(SCREEN_WIDTH-0.1));
            break;
        case 1:
            return CGSizeMake(SCREEN_WIDTH-0.1, 0.466*(SCREEN_WIDTH-0.1));
            break;
        case 2:
            return CGSizeMake((SCREEN_WIDTH-40-1)/2, 0.25*(SCREEN_WIDTH-40-1)/2);
            break;
        case 3:
            return CGSizeMake(SCREEN_WIDTH-0.1, 0.21*(SCREEN_WIDTH-0.1));
            break;
        case 4:
            return CGSizeMake(SCREEN_WIDTH-0.1, 0.8*(SCREEN_WIDTH-0.1));
            break;
        default:
            return CGSizeMake(SCREEN_WIDTH-0.1, 0.001);
            break;
    }
    
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    if (0 == section || 1 == section) {
//        return UIEdgeInsetsMake(0.1, 0.1, 0.1, 0.1);
//    } else if (2 == section) {
//        return UIEdgeInsetsMake(20, 15, 20, 15);
//    } else {
//        return UIEdgeInsetsMake(20, 0.1, 20, 0.1);
//    }
    if (2 == section) {
        return UIEdgeInsetsMake(0.1, 15, 20, 15);
    } else{
        return UIEdgeInsetsMake(0.1, 0.1, 0.1, 0.1);
    }
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.001;
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.001;
}

#pragma mark - GrayFooterCollectionReusableView
- (void)moreButtonDidTapped
{
    [self jumpToBBSWithUrl:[ESAppConfigManager sharedManager].appConfig.bbs_home_url];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (2 == indexPath.section) {
            GrayFooterCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GrayFooterCollectionReusableView" forIndexPath:indexPath];
            header.titleLabel.hidden = NO;
            header.backgroundColor = [UIColor whiteColor];
            header.titleLabel.font = [UIFont stec_bigTitleFount];
            header.titleLabel.textColor = [UIColor stec_titleTextColor];
            header.titleLabel.text = @"热门话题";
            header.viewDelegate = (id)self;
            header.moreButton.hidden = NO;
            return header;
        } else{
            HeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderCollectionReusableView" forIndexPath:indexPath];
            if (4 == indexPath.section) {
                [header setTitle:@"热门案例" subTitle:@"HOT CASE"];
            } else {
                [header setTitle:@"" subTitle:@""];
            }
            
            return header;
        }
        
    } else {
        if (4 == indexPath.section) {
            CheckMoreReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CheckMoreReusableView" forIndexPath:indexPath];
            footer.backgroundColor = [UIColor whiteColor];
            [footer setBlock:^{
                
                [UMengServices eventWithEventId:Event_designer_home_case_more];
                CoHomeBaseViewController *example = [[CoHomeBaseViewController alloc] init];
                example.isFromHome = YES;
                example.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:example animated:YES];
            }];
            return footer;
        } else {
            GrayFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GrayFooterCollectionReusableView" forIndexPath:indexPath];
            footer.titleLabel.hidden = YES;
            return footer;
        }
        
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (4 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.18*SCREEN_WIDTH);
        return size;
    } else if (2 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.15*SCREEN_WIDTH);
        return size;
    } else {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (1 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 10);
        return size;
    } else if (4 == section) {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 50);
        return size;
    } else {
        CGSize size= CGSizeMake(SCREEN_WIDTH, 0.001);
        return size;
    }
    
    
}

- (void)getData {
    WS(weakSelf)
    [JRHomeAPI getHomePageWithType:@"2" loginStatus:[ESLoginManager sharedManager].isLogin Success:^(NSDictionary *dict) {
        SHLog(@"%@", dict);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        [weakSelf.showCaseDatas removeAllObjects];
        [weakSelf.exampleDatas removeAllObjects];
        
        NSMutableDictionary *datasSourse = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSArray *showcases = datasSourse[@"banner"] ? datasSourse[@"banner"] : [NSArray array];
        for (NSDictionary *dic in showcases) {
            [weakSelf.showCaseDatas addObject:dic];
        }
        
        NSArray *cases = datasSourse[@"cases"] ? datasSourse[@"cases"] : [NSArray array];
        for (NSDictionary *dic in cases) {
            [weakSelf.exampleDatas addObject:[HomeConsumerExampleModel createModelWithDic:dic]];
        }
        
        [weakSelf.collectionView reloadData];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.collectionView.mj_header endRefreshing];
        SHLog(@"%@", error);
    }];
    
    NSString *jid = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    if (jid != nil && ![jid isEqualToString:@""]) {
        [JRHomeAPI getPerfectInfoOrNotWithJid:jid withSuccess:^(NSDictionary *dict) {
            SHLog(@"%@", dict);
            weakSelf.perfectStatus = [NSString stringWithFormat:@"%@", dict[@"status"]];
            [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:3]];
        } andFailure:^(NSError *error) {
            SHLog(@"%@", error);
        }];
    }
}

#pragma mark - 检测用户是否设置用户类型
- (void)checkMemberType
{
    // 未登录状态不处理
    if (![ESLoginManager sharedManager].isLogin) {return;}
    
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

- (void)dealloc {
    [[ESNIMManager sharedManager] removeESIMDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
