
#import "MPDesignerDetailViewController.h"
#import "MPDesignerDetailView.h"
#import "MPDesignerBaseModel.h"
#import "MPCaseBaseModel.h"
#import "MPOrderEmptyView.h"
#import "MBProgressHUD.h"
#import "CoCaseDetailController.h"
#import "CoDesignerCommentModel.h"
#import "MP3DCaseBaseModel.h"
#import "MP3DCaseModel.h"
#import "JRKeychain.h"
#import "ESNIMManager.h"
#import "ESCaseDetailViewController.h"
#import <ESNetworking/SHAlertView.h>
#import "ESCommentAPI.h"
#import "ESDesignAPI.h"
#import "ESDesignerInfoModel.h"
#import "EZHome-Swift.h"

@interface MPDesignerDetailViewController ()<MPDesignerDetailViewDelegate, ESLoginManagerDelegate>
@property (strong, nonatomic)ESDesignerInfoModel *designerInfo;
@end

@implementation MPDesignerDetailViewController
{
    MPDesignerDetailView *_designerDetailView;  //!< _designerDetailView the view for controller.
    NSMutableArray *_arrayDS;                   //!< _arrayDS the array for datasource.
    NSInteger _offset;                          //!< _offset offset for request.
    NSInteger _limit;                           //!< _limit limit for request.
    BOOL _isLoadMore;                           //!< _isLoadMore bool is load more or not.
    
    NSMutableArray *_array3DDS;
    NSInteger _offset3D;                          //!< _offset offset for request.
    NSInteger _limit3D;                           //!< _limit limit for request.
    BOOL _is3DLoadMore;
    
    NSString *_designerID;                      //!< _designerID the id for designer.
    
    BOOL _isDesignerPersonCenter;               //!< _isDesignerPersonCenter from designer person or not.
    BOOL _isConsumerNeeds;                      //!< _isConsumerNeeds from consumer or not.
    BOOL _isBidder;                             //!< _isBidder from consumer bidder or not.
    MPOrderEmptyView *_emptyView;               //!< _emptyView the view for no case.
    
    BOOL _firstRequestOver;                     //!< _firstRequestOver the bool for show designer info or not.
    
    NSInteger _designerCellType;                //!< tableview cell type.
    
    NSMutableArray *_commentArray;              //!< _commentArray the array for datasource.
    NSInteger _commentOffset;                          //!< _offset offset for request.
    NSInteger _commentLimit;                           //!< _limit limit for request.
    BOOL _isCommentLoadMore;                           //!< _isLoadMore bool is load more or not.
    CoDesignerCommentModel *_designerModel;
    
    UIButton *_followButton;
    
    BOOL judgeis3D;
    
    BOOL _isRequest;
}

- (instancetype)initWithIsDesignerCenter:(BOOL)isDesignerPersonCenter
                               member_id:(NSString *)member_id
                         isConsumerNeeds:(BOOL)isConsumerNeeds {
    
    self = [super init];
    if (self) {
        _designerID = member_id;
        _isDesignerPersonCenter = isDesignerPersonCenter;
        _isConsumerNeeds = isConsumerNeeds;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.delegate = nil;
    [[ESLoginManager sharedManager] addLoginDelegate:self];
    [self initData];
    [self initUI];
    [self requestDesignerInfo];
}

- (void)tapOnLeftButton:(id)sender {
    if (_isConsumerNeeds && !_isBidder) {
        if (self.success)
            self.success();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData {
    
    _isBidder = YES;
    _firstRequestOver = NO;
    _isRequest = YES;
    
    _limit = 10;
    _offset = 0;
    _limit3D = 10;
    _offset3D = 0;
    _commentLimit = 10;
    _commentOffset = 0;
    
    _arrayDS = [NSMutableArray array];
    _array3DDS = [NSMutableArray array];
    _commentArray = [[NSMutableArray alloc] init];
    
    _designerModel = [[CoDesignerCommentModel alloc] init];
    
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    _designerDetailView = [[MPDesignerDetailView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT)];
    _designerDetailView.delegate = self;
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        _designerDetailView.isDesigner = YES;
    }
    
    [self.view addSubview:_designerDetailView];
    
    self.rightButton.hidden = YES;
    self.navgationImageview.userInteractionEnabled = YES;
    _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _followButton.frame = CGRectMake(SCREEN_WIDTH-70, NAVBAR_HEIGHT-44, 60, 44);
    [_followButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    _followButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_followButton addTarget:self action:@selector(followClick:) forControlEvents:UIControlEventTouchUpInside];
    [_followButton setTitle:@"关注" forState:UIControlStateNormal];
    [self.navgationImageview addSubview:_followButton];
    
}

- (void)followClick:(UIButton *)sender
{
    WS(weakSelf);
    if ([ESLoginManager sharedManager].isLogin) {
        
        if ([_designerInfo.isFollowing integerValue] == 0) {
            
            [self attentionRequestWithFollwsType:@"true" success:^{
                [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
                
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
                
            }];
        }else {
            
            NSString *titleStr = [NSString stringWithFormat:@"您确定取消对%@的关注吗？",_designerInfo.nickName];
            [SHAlertView showAlertWithMessage:titleStr sureKey:^{
                [weakSelf attentionRequestWithFollwsType:@"false" success:^{
                    [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
                    
                } failure:^(NSError *error) {
                    [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
                    
                }];
                
                
            } cancelKey:^{
            }];
        }
        
    }else {
        
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        
    }
    
}
- (void)showAleartWithTitle:(NSString *)title{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    //    hud.labelText = title;
    hud.label.text = title;
    hud.margin = 30.f;
    //    hud.yOffset = 0;
    CGPoint offset = hud.offset;
    [hud setOffset:CGPointMake(offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    //    [hud hide:YES afterDelay:0.75];
    [hud hideAnimated:YES afterDelay:0.75];
    
}

/// 关注设计师
- (void)attentionRequestWithFollwsType:(NSString *)followsType success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    [MBProgressHUD showHUDAddedTo:_designerDetailView animated:YES];
    
    WS(weakSelf);
    NSString *attentionDesignerMemberId = [NSString stringWithFormat:@"%@",_designerInfo.jmemberId];
    
    if ([followsType isEqualToString:@"true"]) {
        [ESCommentAPI addFollowWithFollowId:attentionDesignerMemberId type:@"0" withSuccess:^(NSDictionary *dict) {
            [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
            _followButton.frame = CGRectMake(SCREEN_WIDTH-90, NAVBAR_HEIGHT-44, 80, 44);
            [_followButton setTitle:@"取消关注" forState:UIControlStateNormal];
            _designerInfo.isFollowing = @"1";
            [weakSelf showAleartWithTitle:@"关注成功"];
            if (success) {
                success();
            }
            _isRequest = NO;
        } andFailure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
            [SHAlertView showAlertForNetError];
            
            if (failure) {
                failure(error);
            }
        }];
    } else {
        [ESCommentAPI deleteFollowWithFollowId:attentionDesignerMemberId type:@"0" withSuccess:^(NSDictionary *dict) {
            [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
            _followButton.frame = CGRectMake(SCREEN_WIDTH-70, NAVBAR_HEIGHT-44, 60, 44);
            [_followButton setTitle:@"关注" forState:UIControlStateNormal];
            _designerInfo.isFollowing = @"0";
            if (success) {
                success();
            }
            _isRequest = NO;
        } andFailure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
            [SHAlertView showAlertForNetError];
            
            if (failure) {
                failure(error);
            }
        }];
    }
}

- (void)requestDesignerInfo {
    WS(weakSelf);
    if (_isDesignerPersonCenter) {
        _designerID = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    } else {
        if (!_designerID) {
            [SHAlertView showAlertForParameterError];
            [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
            return;
        }
    }
    [MBProgressHUD showHUDAddedTo:_designerDetailView animated:YES];
    [ESDesignAPI getDesignerInfoWithDesignerId:_designerID success:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
        ESDesignerInfoModel *model = [ESDesignerInfoModel createModelWithDic:dict];
        [weakSelf finishRequestDesignerInfo:model];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
        [SHAlertView showAlertForNetError];
    }];
}

- (void)finishRequestDesignerInfo:(ESDesignerInfoModel *)model {
    _designerInfo = model;
    self.titleLabel.text = model.nickName;
    
    
    
    if ([ESLoginManager sharedManager].isLogin) {
        
        if ([model.isFollowing integerValue] == 0) {
            
            _followButton.frame = CGRectMake(SCREEN_WIDTH-70, NAVBAR_HEIGHT-44, 60, 44);
            
            [_followButton setTitle:@"关注" forState:UIControlStateNormal];
            
        }else {
            _followButton.frame = CGRectMake(SCREEN_WIDTH-90, NAVBAR_HEIGHT-44, 80, 44);
            
            [_followButton setTitle:@"取消关注" forState:UIControlStateNormal];
            
        }
        
    }else {
        _followButton.frame = CGRectMake(SCREEN_WIDTH-70, NAVBAR_HEIGHT-44, 60, 44);
        
        [_followButton setTitle:@"关注" forState:UIControlStateNormal];
    }
    
    [_designerDetailView refreshDesignerDetailUI];
    
    if (_isRequest == YES) {
        if (_designerCellType == 0) {
            [self requestData];
            
        }else if (_designerCellType == 2)
        {
            // 3D 案例集的请求
            [self request3DData];
        }else {
            [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
            
        }
        
    }else{
        [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
        
    }
    
}

#pragma mark Network
// 2D请求数据
- (void)requestData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:_designerDetailView animated:YES];
    if (_isDesignerPersonCenter) {
        _designerID = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];//[SHMember shareMember].acs_member_id;
    }
    
    if (_designerID == nil) {
        [SHAlertView showAlertForParameterError];
        [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
        [self createEmptyViewWithTitle:@"0"];
        [weakSelf endRefreshView:NO];
        return;
    }

    
    [MPCaseBaseModel getDataWithParameters:@{@"designer_id":_designerID,@"offset":@(_offset),@"limit":@(_limit)} success:^(NSArray *array,NSString *count) {
        [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
        _firstRequestOver = YES;
        judgeis3D = NO;;
        if (!_isLoadMore)
            [_arrayDS removeAllObjects];
        [weakSelf endRefreshView:_isLoadMore];
        [_arrayDS addObjectsFromArray:array];
        _offset = _arrayDS.count;
        
        if (array.count == 0) {
            _designerDetailView.deisgnerTableView.mj_footer.hidden = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (_isLoadMore) {
                if (array.count != 0) {
                    [_designerDetailView refreshDesignerDetailUI];
                }
                    
            }else{
                [_designerDetailView refreshDesignerDetailUI];
            }
            
            if (_arrayDS.count == 0) {
                [self createEmptyViewWithTitle:@"0"];
            } else {
                if (_emptyView) [_emptyView removeFromSuperview];
            }
        });
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
        [weakSelf endRefreshView:_isLoadMore];
        [SHAlertView showAlertForNetError];
    }];
    
    
}

// 3D请求数据
- (void)request3DData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:_designerDetailView animated:YES];
    
    if (_isDesignerPersonCenter) {
        _designerID = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];//[SHMember shareMember].acs_member_id;
    }
    if (_designerID == nil) {
        [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
        
        [SHAlertView showAlertForParameterError];
        [weakSelf endRefreshView:NO];
        
        return;
    }
    
    [MP3DCaseBaseModel getDataWithParameters:@{@"designer_id":_designerID,@"offset":@(_offset3D),@"limit":@(_limit3D)} success:^(NSArray *array,NSString *count) {
        
        _firstRequestOver = YES;
        judgeis3D = YES;
        
        if (!_is3DLoadMore)
            [_array3DDS removeAllObjects];
        [weakSelf endRefreshView:_is3DLoadMore];
        [_array3DDS addObjectsFromArray:array];
        _offset3D = _array3DDS.count;
        
        if (array.count == 0) {
            _designerDetailView.deisgnerTableView.mj_footer.hidden = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
            if (_is3DLoadMore) {
                if (array.count != 0) {
                    [_designerDetailView refreshDesignerDetailUI];
                }
            }else{
                [_designerDetailView refreshDesignerDetailUI];
            }
            
            if (_array3DDS.count == 0) {
                [self createEmptyViewWithTitle:@"0"];
            } else {
                if (_emptyView) [_emptyView removeFromSuperview];
            }
            
        });
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
        [weakSelf endRefreshView:_isLoadMore];
        [SHAlertView showAlertForNetError];
        
    }];
    
}


/// 设计师评价
- (void)requestDesignerCommentData {
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:_designerDetailView animated:YES];
        
    });
    [CoDesignerCommentModel createDesignerCommentListWithDesignerId:_designerID Parameter:@{@"offset":@(_commentOffset),@"limit":@(_commentLimit)} success:^(NSMutableArray *array) {
        
        if (!_isCommentLoadMore)
            [_commentArray removeAllObjects];
        
        [weakSelf endRefreshView:_isCommentLoadMore];
        
        [_commentArray addObjectsFromArray:array];
        _commentOffset = _commentArray.count;
        
        if (array.count == 0) {
            _designerDetailView.deisgnerTableView.mj_footer.hidden = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
            
            if (_commentArray.count == 0) {
                [self createEmptyViewWithTitle:@"暂无评价"];
            } else {
                if (_emptyView) [_emptyView removeFromSuperview];
                
            }
            
            if (_isCommentLoadMore) {
                
                if (array.count != 0) {
                    [_designerDetailView refreshDesignerDetailUI];
                }
                
            }else{
                [_designerDetailView refreshDesignerDetailUI];
            }
            
        });
        
        
        
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:_designerDetailView animated:YES];
        });
        
        [weakSelf endRefreshView:_isCommentLoadMore];
        [SHAlertView showAlertForNetError];
        
    }];
}

- (void)createEmptyViewWithTitle:(NSString *)string{
    //    if (_emptyView) return;
    [_emptyView removeFromSuperview];
    _emptyView = [[[NSBundle mainBundle] loadNibNamed:@"MPOrderEmptyView" owner:self options:nil] lastObject];
    //    CGFloat emptyViewY = [SHAppGlobal AppGlobal_GetIsDesignerMode]?188.0f:231.0f;
    CGFloat emptyViewY = 300.0f;
    _emptyView.frame = CGRectMake(0, emptyViewY , SCREEN_WIDTH, SCREEN_HEIGHT - emptyViewY - NAVBAR_HEIGHT);
    
    _emptyView.imageViewY.constant = 50.0f;
    
    NSString *emptyInfo;
    
    if ([string isEqualToString:@"0"]) {
        emptyInfo = @"暂无案例";
    }else {
        emptyInfo = string;
    }
    _emptyView.infoLabel.text = emptyInfo;
    [_designerDetailView.deisgnerTableView addSubview:_emptyView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    view.backgroundColor = [UIColor lightGrayColor];
    view.alpha = 0.3;
    [_emptyView addSubview:view];
}

#pragma mark - MPDesignerDetailViewDelegate

- (NSInteger)getDesignerDetailCommentsCount {
    return _commentArray.count+1;
}
- (NSInteger)getDesignerDetailCaseCount {
    
    if (_firstRequestOver) {
        return _arrayDS.count;
    }
    return 0;
}
- (NSInteger)getDesignerDetail3DCaseCount{
    
    if (_firstRequestOver) {
        return _array3DDS.count;
    }
    return 0;
}

- (void)didSelectCellAtIndex:(NSInteger)index withInSection:(NSInteger)section{
    if ((index == 0 && section ==0) || (_designerCellType==1) ) {
        return;
    }
    if (judgeis3D == NO) {
        ESDesignCaseList * model = [_arrayDS objectAtIndex:index];
        
        UIViewController *caseDetailVC = nil;
        if (model.isNew)
        {
            ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
            [vc setCaseId:model.assetId caseStyle:CaseStyleType2D caseSource: CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
            caseDetailVC = vc;
        }
        else
        {
            caseDetailVC = [[CoCaseDetailController alloc] initWithCaseID:model.assetId];
        }
        [self.navigationController pushViewController:caseDetailVC animated:YES];
        
    } else if(judgeis3D == YES){
        
        ESDesignCaseList * model = [_array3DDS objectAtIndex:index];
        if (model.designerId == nil || [model.designerId isKindOfClass:[NSNull class]] || [model.designerId isEqualToString:@""]) {
            
            if ([[JRKeychain loadSingleUserInfo:UserInfoCodeJId] isEqualToString:model.designerId]) {//[SHMember shareMember].acs_member_id
                [SHAlertView showAlertWithMessage:@"方案尚未完成，请至网页端完善设计" sureKey:nil];
            } else {
                [SHAlertView showAlertWithMessage:@"方案还在设计中，请浏览其他3D方案" sureKey:nil];
            }
            return;
        }
        ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
        [vc setCaseId:model.assetId caseStyle:CaseStyleType3D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)designerDetailViewRefreshLoadNewData:(void (^)(void))finish {
    
    self.refreshForLoadNew = finish;
    _designerDetailView.deisgnerTableView.mj_footer.hidden = NO;
    
    if (_designerCellType == 0) {
        _offset = 0;
        _isLoadMore = NO;
        [self requestData];
    }else if (_designerCellType == 2){
        // 3D 案例集请求
        _offset3D = 0;
        _is3DLoadMore = NO;
        [self request3DData];
    }else {
        _commentOffset = 0;
        _isCommentLoadMore = NO;
        [self requestDesignerCommentData];
    }
}

- (void)designerDetailViewRefreshLoadMoreData:(void (^)(void))finish {
    
    self.refreshForLoadMore = finish;
    if (_designerCellType == 0) {
        _isLoadMore = YES;
        [self requestData];
    }else if (_designerCellType == 2)
    {
        // 3D 案例集的请求
        _is3DLoadMore = YES;;
        [self request3DData];
    }else {
        _isCommentLoadMore = YES;
        [self requestDesignerCommentData];
    }
}

#pragma mark - MPDesignerDetailHeaderTableViewCellDelegate
- (ESDesignerInfoModel *)getDesignerInfoModel {
    return _designerInfo;
}

- (void)chatWithDesigner {
    if ([ESLoginManager sharedManager].isLogin) {
        
        if (_isConsumerNeeds) {
            if (self.thread_id.length == 0) {
                [SHAlertView showAlertForParameterError];
                return;
            }
            [ESNIMManager startP2PSessionFromVc:self withJMemberId:_designerInfo.jmemberId andSource:ESIMSourceDesignerHome];
        } else {
            [ESNIMManager startP2PSessionFromVc:self withJMemberId:_designerInfo.jmemberId andSource:ESIMSourceDesignerHome];
        }
    } else {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    }
}

- (void)chooseTAMeasure {
    if (![ESLoginManager sharedManager].isLogin) {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        return;
    }
    
    ESFreeAppointViewController *coPackageEstimateViewCon = [[ESFreeAppointViewController alloc]init];
    [coPackageEstimateViewCon setSelectedType:@{@"packageType":@"", @"selectedType":@"7"}];
    
    if (_isConsumerNeeds) {
        
    } else {
        
        if ([_designerInfo.isRealName integerValue] == 2) {
            
        } else {
            [SHAlertView showAlertWithMessage:NSLocalizedString(@"设计师未通过认证", nil)
                      autoDisappearAfterDelay:1];
            return;
        }
    }
    [self.navigationController pushViewController:coPackageEstimateViewCon animated:YES];
}
#pragma mark - CoDesignerDetailHeadViewDelegate

/// 设计师评价总数.
- (NSInteger)getDesignerCommentsCount {
    
    return [_designerInfo.commentCount integerValue];
}

//设计师个人主页的选项卡
- (void)selectSegBtnClickWithTitleIndex:(NSInteger)index {
    
    if (index == 1) {
        //加载评论
        SHLog(@"/n 评论加载数据");
        if (_commentArray.count == 0) {
            [self createEmptyViewWithTitle:@"暂无评价"];
            _isCommentLoadMore = NO;
            _commentOffset = 0;
            [self requestDesignerCommentData];
        } else{
            if (_emptyView) [_emptyView removeFromSuperview];
        }
        
    } else if(index == 0) {
        SHLog(@"/N2D 加载在数据");
        judgeis3D = NO;
        if (_arrayDS.count == 0) {
            [self createEmptyViewWithTitle:@"0"];
            _isLoadMore = NO;
            _offset = 0;
            [self requestData];
            
        } else {
            if (_emptyView) [_emptyView removeFromSuperview];
        }
    } else if(index == 2){
        SHLog(@"/N3D 加载在数据");
        judgeis3D = YES;
        if (_array3DDS.count == 0) {
            
            _is3DLoadMore = NO;
            _offset3D = 0;
            [self createEmptyViewWithTitle:@"0"];
            [self request3DData];
        } else{
            if (_emptyView) [_emptyView removeFromSuperview];
        }
    }
    _designerCellType = index;
    [_designerDetailView refreshDesignerDetailUI];
}

#pragma mark - CoDesignerDetailScoreCellDelegate

/// 设计师评分.
- (float)getDesignerScore {
    
    return [_designerInfo.commentScores floatValue];
    //    return 4.5;
    
}

#pragma mark - CoDesignerCommentCellDelegate

- (CoDesignerCommentModel *)getDesignerCommentModelAtIndex:(NSInteger)index {
    
    if (_commentArray.count) {
        return _commentArray[index - 1];
    }
    return nil;
}
#pragma mark - MPDesignerDetailTableViewCellDelegate


- (NSInteger)getDesignerCellType {
    return _designerCellType;
}

- (ESDesignCaseList *)getDesignerDetailModelAtIndex:(NSInteger)index {
    if (_arrayDS.count) {
        return _arrayDS[index];
    }
    return nil;
}

#pragma mark - MPDesignerDetail3DTableViewCellDelegate
- (ESDesignCaseList *)get3DDesignerDetailModelAtIndex:(NSInteger)index {
    if (_array3DDS.count) {
        return _array3DDS[index];
    }
    return nil;
}

- (void)returnBool:(ReturnBoolBlock)block {
    self.returnBoolBlock = block;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.returnBoolBlock != nil) {
        self.returnBoolBlock(NO);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ESLoginManagerDelegate
- (void)onLogin {
    [self refreshView];
}

- (void)onLogout {
    [self refreshView];
}

- (void)refreshView {
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        _designerDetailView.isDesigner = YES;
    }
    [_designerDetailView refreshDesignerDetailUI];
}

- (void)dealloc {
    [[ESLoginManager sharedManager] removeLoginDelegate:self];
}
@end
