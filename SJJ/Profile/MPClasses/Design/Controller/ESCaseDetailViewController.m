//
//  ESCaseDetailViewController.m
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseDetailViewController.h"
#import "ESWebTableViewCell.h"
#import "ESCaseFavoriteTableViewCell.h"
#import "ESCaseCommentCell.h"
#import "ESCaseCollectionTableViewCell.h"
#import "Assistant.h"
#import "ESDiyRefreshHeader.h"
#import "HtmlURL.h"
#import "ESCaseHeaderView.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESCaseProduvtListViewController.h"
#import "ESKeyBoardInputView.h"
#import "ESCaseTabBar.h"
#import "MPDesignerInfoModel.h"
#import "CoMyFocusModel.h"
#import "MBProgressHUD+NJ.h"
#import "MPDesignerInfoModel.h"
#import "CoSlidingViewMange.h"
#import "WXApiRequesHandler.h"
#import "WXApiManager.h"
#import "ESCaseAPI.h"
#import "UIImageView+WebCache.h"
#import "MPCaseBaseModel.h"
#import "ESCaseNoCommentCell.h"
#import "ESProductDetailViewController.h"
#import "ESCaseNoNetCommentCell.h"
#import "JRWebViewController.h"
#import "ESShareView.h"
#import <ESNetworking/SHAlertView.h>
#import "ESCommentAPI.h"
#import <ESNetworking/SHRequestTool.h>
#import <ESMallAssets.h>
#import "EZHome-Swift.h"

#import "ESRecViewController.h"


#import "ESCaseHeaderImageView.h"
#import "ESCaseDesignerInfoView.h"
#import "ESCaseSectionView.h"
#import "ESCase4to3ImageView.h"
#import "ESCase16to9ImageView.h"
@interface ESCaseDetailViewController ()<UITableViewDelegate, UITableViewDataSource, WXApiManagerDelegate,ESCaseDesignerInfoViewDelegate, ESLoginManagerDelegate,ESCaseHeaderImageViewDelegate,ESCase16to9ImageViewDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(assign, nonatomic) CGFloat webHeight;
@property(strong, nonatomic) ESWebTableViewCell *webCell;
@property(assign, nonatomic) CaseStyleType myStyleType;
@property(assign, nonatomic) BOOL hasRecommend;
@property(strong, nonatomic) ESKeyBoardInputView *inputView;
@property(strong, nonatomic) ESCaseTabBar *tabBarView;
@property(strong, nonatomic) UITextField *tempTextField;
@property(strong, nonatomic) UIToolbar *toolBar;
@property(strong, nonatomic) UIControl *backKeyBoard;
@property(copy, nonatomic) NSString *caseId;
@property(strong, nonatomic) ESCaseDetailModel *myCaseDetailModel;
@property(strong, nonatomic) ESCaseDetailModel *myDesignerModel;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (nonatomic,strong)NSMutableArray *datasSourse;
@property (assign, nonatomic) NSInteger commentAllNum;
@property (assign, nonatomic) BOOL isNoNet;
@property (assign, nonatomic) BOOL isShowAll;
@property(strong, nonatomic) UIButton *imgBtn;
@property(strong, nonatomic) UIButton *zanBtn;
@property(strong, nonatomic) UIButton *footerBtn;
@property(assign, nonatomic) CaseSourceType caseSource;
@property(assign, nonatomic) CaseCategory caseCategory;
//推荐分享按钮
@property (nonatomic,strong)    UIButton *shareRecBtn;

@property(strong, nonatomic) NSError *caseError;
@property(strong, nonatomic) NSError *commentError;
@property(strong, nonatomic) NSError *H5Error;


///设计师头像
@property (nonatomic,strong)    UIButton *designHeadView;
///头像
@property (nonatomic,strong)    UIImageView *headImgView;
@property (nonatomic,strong)    UILabel *nameLabel;

@end



@implementation ESCaseDetailViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_tabBarView) {
        [_tabBarView setEdgeInsets];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"详情";
    
//    self.designerView.hidden = NO;
    
    [self.rightButton setImage:[UIImage imageNamed:@"nav_share"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"nav_share"];
    _webHeight = 0;
    _pageNum = 1;
    _pageSize = 10;
    _datasSourse = [NSMutableArray array];
    self.view.backgroundColor = UIColor.whiteColor;
    _hasRecommend = NO;
    _isNoNet = NO;
    
    [self createView];

    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        [self createShareRecBtn];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[ESLoginManager sharedManager] addLoginDelegate:self];
    [WXApiManager sharedManager].delegate = self;
    

    
}
- (void)setCaseId:(NSString *)caseId
        caseStyle:(CaseStyleType)caseStyle
       caseSource:(CaseSourceType)source
     caseCategory:(CaseCategory)category {
    _caseId = caseId;//@"1700944";
    _myStyleType = caseStyle;
    _caseSource = source;
    _caseCategory = category;
}

- (void)tapOnRightButton:(id)sender {
    SHLog(@"分享");
    NSString *type = @"detail3D";
    if (self.myStyleType == CaseStyleType2D){
        type = @"detail2D";
    }
    NSString *imgUrl = _myCaseDetailModel.photo3DUrl;
    if (self.myStyleType == CaseStyleType2D){
        type = @"detail2D";
        imgUrl = _myCaseDetailModel.photo2DUrl;
    }
    NSString *sharedUrl = [NSString stringWithFormat:@"%@/h5/share/%@/%@",[JRNetEnvConfig sharedInstance].netEnvModel.mServer,type,self.caseId];
    
    [ESShareView showShareViewWithShareTitle:_myCaseDetailModel.name shareContent:@"居然设计家，省时、省力、省心设计您的家" shareImg:imgUrl shareUrl:sharedUrl shareStyle:ShareStyleTextAndImage Result:^(PlatformType type, BOOL isSuccess) {
        if (isSuccess){
            [ESMBProgressToast showToastAddTo:self.view text:@"分享成功"];
        }else {
            [ESMBProgressToast showToastAddTo:self.view text:@"分享失败"];
        }
    }];
    if ([_myCaseDetailModel.designerInfo.isBindDecoration isEqualToString:@"1"]) {
        [self showShareToast];
    }
    
//    if (_myCaseDetailModel.shareInfo) {
//
//        [ESShareView showShareViewWithShareTitle:_myCaseDetailModel.shareInfo.shareTitle shareContent:_myCaseDetailModel.shareInfo.shareContent shareImg:_myCaseDetailModel.shareInfo.shareImg shareUrl:_myCaseDetailModel.shareInfo.shareUrl shareStyle:ShareStyleTextAndImage Result:^(PlatformType type, BOOL isSuccess) {
//        }];
//        if ([_myCaseDetailModel.designerInfo.isBindDecoration isEqualToString:@"1"]) {
//            [self showShareToast];
//        }
//    } else {
//        [self showAleartWithTitle:@"获取分享信息失败"];
//    }
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardShow:(NSNotification *)notification {

    if (![ESLoginManager sharedManager].isLogin) {
        [self.view endEditing:YES];
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        return;
    }
    [self.view bringSubviewToFront:_backKeyBoard];
}

- (void)keyboardHidden:(NSNotification *)notification {
    [self.view sendSubviewToBack:_backKeyBoard];
    [self.view endEditing:YES];
    [self.view endEditing:YES];
}

- (void)createView {
    CGFloat height = SCREEN_HEIGHT-NAVBAR_HEIGHT - 50;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.estimatedRowHeight = 300;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"ESWebTableViewCell" bundle:nil] forCellReuseIdentifier:@"ESWebTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseFavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"ESCaseFavoriteTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseCommentCell" bundle:nil] forCellReuseIdentifier:@"ESCaseCommentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseNoCommentCell" bundle:nil] forCellReuseIdentifier:@"ESCaseNoCommentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseNoNetCommentCell" bundle:nil] forCellReuseIdentifier:@"ESCaseNoNetCommentCell"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseCollectionTableViewCell" bundle:nil] forCellReuseIdentifier:@"ESCaseCollectionTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"ESCaseHeaderView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseHeaderImageView" bundle:nil] forCellReuseIdentifier:@"ESCaseHeaderImageView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseDesignerInfoView" bundle:nil] forCellReuseIdentifier:@"ESCaseDesignerInfoView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseSectionView" bundle:nil] forCellReuseIdentifier:@"ESCaseSectionView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCase4to3ImageView" bundle:nil] forCellReuseIdentifier:@"ESCase4to3ImageView"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCase16to9ImageView" bundle:nil] forCellReuseIdentifier:@"ESCase16to9ImageView"];
    
    _footerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [_footerBtn setTitle:@"查看全部" forState:UIControlStateNormal];
    _footerBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_footerBtn setTitleColor:[UIColor colorWithRed:158/255 green:177/255 blue:186/255 alpha:1] forState: UIControlStateNormal];
    [_footerBtn addTarget:self action:@selector(showAllComment) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *footerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [footerView addSubview:_footerBtn];
    _tableView.tableFooterView = footerView;
    
    [self.view addSubview:_tableView];
    WS(weakSelf)
    _tableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
    
    _inputView = [ESKeyBoardInputView creatWithPlacetitle:@"说点什么吧" title:nil Block:^(NSString *string) {
        [weakSelf.view endEditing:YES];
        [weakSelf addComment:string];
        
        SHLog(@"评论接口");
    }];
    _imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 30, 40, 16)];
    [_imgBtn setImage:[UIImage imageNamed:@"example_chat"] forState:UIControlStateNormal];
    //[_imgBtn setTitle:[NSString stringWithFormat:@"% ld",(long)_datasSourse.count] forState:UIControlStateNormal];
    _zanBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 30, 50, 16)];
    [_zanBtn setImage:[UIImage imageNamed:@"case_zan"] forState:UIControlStateNormal];
    [_zanBtn setImage:[UIImage imageNamed:@"case_unzan"] forState:UIControlStateSelected];
    [_zanBtn addTarget:self action:@selector(zanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_imgBtn setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    [_zanBtn setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    _zanBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _imgBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _inputView.frame = CGRectMake(60, SCREEN_HEIGHT - 50, SCREEN_WIDTH - 100, 50);
    [self.view addSubview:_inputView];
    [self.view addSubview:_imgBtn];
    [self.view addSubview:_zanBtn];
    [self refresh];
    
    
    
    //设计师头像
    [self.navgationImageview addSubview:self.designHeadView];
}

-(void)zanBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    btn.selected ? [self favoriteClicked] : [self unfavoriteClicked];
}

-(void)showAllComment {
    _isShowAll = YES;
   [_footerBtn setTitle:@"已显示全部" forState:UIControlStateNormal];
   [_tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -网络请求-
- (void)refresh {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WS(weakSelf)
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestCaseDetailDatasCompletion:^(NSError *error) {
            dispatch_group_leave(group);
            weakSelf.caseError = error;
        }];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _pageNum = 1;
        [self requestCommentDatasCompletion:^(NSError *error) {
            dispatch_group_leave(group);
            weakSelf.commentError = error;
        }];
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestH5DetailDatasCompletion:^(NSError *error) {
            dispatch_group_leave(group);
            weakSelf.H5Error = error;
        }];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (weakSelf.caseError || weakSelf.H5Error) {
            weakSelf.titleLabel.text = @"";
            if (_myCaseDetailModel == nil || _myDesignerModel == nil) {
                [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_net" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                    [weakSelf.tableView.mj_header beginRefreshing];
                }];
                [weakSelf.view sendSubviewToBack:weakSelf.tabBarView];
            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:weakSelf.caseError]] toView:weakSelf.view];
            }
        }else if (weakSelf.commentError){
            if (weakSelf.pageNum==1) {
                weakSelf.isNoNet = YES;
            } else {
                weakSelf.pageNum--;
            }
            
            
            [weakSelf.tableView reloadData];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:weakSelf.commentError]] toView:weakSelf.view];
        }else{
            [self.headImgView sd_setImageWithURL:[NSURL URLWithString:_myDesignerModel.designerInfo.avatar] placeholderImage:[UIImage imageNamed:@"headerDeafult"]];
            self.nameLabel.text = _myDesignerModel.designerInfo.nickName;
            [self.tableView reloadData];
        }
    });
}

//Case信息
- (void)requestCaseDetailDatasCompletion:(void (^ __nullable)(NSError *error))completionBlock {
    NSString *type = @"2d";
    if (_myStyleType == CaseStyleType3D) {
        type = @"3d";
    }
    NSString *source = @"";
    switch (_caseSource) {
        case CaseSourceTypeBySearch:
            source = @"1";
            break;
        case CaseSourceTypeBy3D:
            source = @"2";
            break;
        default:
            break;
    }
    [ESCaseAPI getCaseDetailWithCaseId:_caseId caseType:type caseSource:source andSuccess:^(ESCaseDetailModel *caseDetailModel) {
        NSLog(@"%@",caseDetailModel);
        _myCaseDetailModel = caseDetailModel;
        completionBlock(nil);
    } andFailure:^(NSError *error) {
        completionBlock(error);
    }];
    
}

//h5信息
- (void)requestH5DetailDatasCompletion:(void (^ __nullable)(NSError *error))completionBlock {
    NSString *type = @"2d";
    if (_myStyleType == CaseStyleType3D) {
        type = @"3d";
    }
    NSString *source = @"";
    switch (_caseSource) {
        case CaseSourceTypeBySearch:
            source = @"1";
            break;
        case CaseSourceTypeBy3D:
            source = @"2";
            break;
        default:
            break;
    }
    
    [ESCaseAPI getCaseDetailWithCaseId:_caseId brandId:nil caseType:type caseSource:source andSuccess:^(ESCaseDetailModel *caseDetailModel) {
            NSLog(@"%@",caseDetailModel);
            _myDesignerModel = caseDetailModel;
            [_zanBtn setTitle:[NSString stringWithFormat:@"% ld",(long)caseDetailModel.likeCount] forState:UIControlStateNormal];
            completionBlock(nil);
    } andFailure:^(NSError *error) {
            completionBlock(error);
    }];
}

//评论信息
- (void)requestCommentDatasCompletion:(void (^ __nullable)(NSError *error))completionBlock {
    WS(weakSelf)
    [ESCaseAPI getCaseDetailCommentListWithCaseId:_caseId pageNum:_pageNum pageSize:_pageSize andSuccess:^(NSArray *array, NSInteger commentNum) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.tableView.mj_header endRefreshing];
        weakSelf.isNoNet = NO;
        if (weakSelf.pageNum == 1) {
            [weakSelf.datasSourse removeAllObjects];
            _commentAllNum = commentNum;
        }
        [weakSelf.datasSourse addObjectsFromArray:array];
        if (weakSelf.datasSourse.count>=weakSelf.commentAllNum) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        if (weakSelf.datasSourse.count == 0) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
         [_imgBtn setTitle:[NSString stringWithFormat:@"% ld",(long)commentNum] forState:UIControlStateNormal];
        _tableView.tableFooterView.hidden = commentNum <= 3;
        completionBlock(nil);
    } andFailure:^(NSError *error) {
        completionBlock(error);
    }];
}

//翻页操作
- (void)nextpage {
    WS(weakSelf)
    _pageNum = _pageNum+1;
    [self requestCommentDatasCompletion:^(NSError *error) {
        if (weakSelf.pageNum==1) {
            weakSelf.isNoNet = YES;
        } else {
            weakSelf.pageNum--;
        }
        [weakSelf.tableView reloadData];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:weakSelf.commentError]] toView:weakSelf.view];
    }];
}

//用户评论
- (void)addComment:(NSString *)commentStr {
    [self.view endEditing:YES];
    NSString *type = @"1";
    if (_myStyleType == CaseStyleType3D) {
        type = @"2";
    }
    WS(weakSelf)
    [ESCaseAPI saveCaseDetailCommentWithCaseId:_caseId caseName:_myCaseDetailModel.caseName caseType:type caseComment:commentStr andSuccess:^(NSDictionary *dict) {
        [MBProgressHUD showSuccess:@"评论成功~"];
         ESCaseCommentModel *model = [ESCaseCommentModel objFromDict:dict];
        weakSelf.commentAllNum++;
        [weakSelf.datasSourse insertObject:model atIndex:0];
        if (weakSelf.myStyleType == CaseStyleType3D && weakSelf.hasRecommend == YES) {
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
        }
        [_imgBtn setTitle:[NSString stringWithFormat:@"% ld",(long)weakSelf.commentAllNum] forState:UIControlStateNormal];
    } andFailure:^(NSError *error) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
    }];
}

- (void)tabbarTapWithType:(NSString *)type { 
    if ([type isEqualToString:@"2"]) {
        if ([ESLoginManager sharedManager].isLogin) {
            [self addToModelRoom];
        }else {
            [MGJRouter openURL:@"/UserCenter/LogIn"];
        }
    } else {
        if ([ESLoginManager sharedManager].isLogin) {
            
            ESFreeAppointViewController *VC = [[ESFreeAppointViewController alloc]init];
            [VC setSelectedType:@{@"packageType":type, @"selectedType":@"7"}];
            VC.sourceName = _myCaseDetailModel.caseName;
            VC.sourceUrl = _caseId;
            NSString *type = @"2d";
            if (_myStyleType == CaseStyleType3D) {
                type = @"3d";
            }
            VC.sourceType = type;
            [self.navigationController pushViewController:VC animated:YES];
        } else {
            [MGJRouter openURL:@"/UserCenter/LogIn"];
        }
        
    }
}

/// 加入我的样板间
- (void)addToModelRoom {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WS(weakSelf)
    [ESCaseAPI addToModelRoomWithProductId:_caseId andSuccess:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showSuccess:@"加入成功~"];
        weakSelf.myCaseDetailModel.showAddFav = NO;
        [weakSelf.tabBarView setWithPersonInfo:weakSelf.myCaseDetailModel];
    } andFailure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
    }];
}


- (void)favoriteClicked {
    WS(weakSelf)
    //判断是否登录
    BOOL status = [ESLoginManager sharedManager].isLogin;
    if (status == NO ) {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    } else{
        NSString *type = @"";
        switch (_myStyleType) {
            case CaseStyleType2D:
                type = @"1";
                break;
            case CaseStyleType3D:
                type = @"2";
                break;
            default:
                break;
        }
        //点赞接口
        [ESCommentAPI addLikeWithResourceId:_caseId type:type withSuccess:^(NSDictionary *dict) {
            //[weakSelf showAleartWithTitle:@"点赞成功"];
            [MBProgressHUD showSuccess:@"点赞成功" toView:[[UIApplication sharedApplication].windows objectAtIndex:1]];
            weakSelf.myDesignerModel.isMemberLike = YES;
            //                [MBProgressHUD showSuccess:@"点赞成功" toView:nil];
            weakSelf.myDesignerModel.likeCount++;
            [_zanBtn setTitle:[NSString stringWithFormat:@"% ld",(long)weakSelf.myDesignerModel.likeCount] forState:UIControlStateNormal];
            if (weakSelf.myStyleType == CaseStyleType3D && weakSelf.hasRecommend == YES) {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }
        } andFailure:^(NSError *error) {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
        }];
    }
}

- (void)unfavoriteClicked {
    WS(weakSelf)
    //判断是否登录
    BOOL status = [ESLoginManager sharedManager].isLogin;
    if (status == NO ) {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    } else{
        NSString *type = @"";
        switch (_myStyleType) {
            case CaseStyleType2D:
                type = @"1";
                break;
            case CaseStyleType3D:
                type = @"2";
                break;
            default:
                break;
        }
        //点赞接口
        [ESCommentAPI deleteLikeWithResourceId:_caseId type:type withSuccess:^(NSDictionary *dict) {
            [MBProgressHUD showSuccess:@"取消点赞成功" toView:[[UIApplication sharedApplication].windows objectAtIndex:1]];
            weakSelf.myDesignerModel.isMemberLike = NO;
            weakSelf.myDesignerModel.likeCount--;
            [_zanBtn setTitle:[NSString stringWithFormat:@"% ld",(long)weakSelf.myDesignerModel.likeCount] forState:UIControlStateNormal];
            if (weakSelf.myStyleType == CaseStyleType3D && weakSelf.hasRecommend == YES) {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }
        } andFailure:^(NSError *error) {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
        }];
    }
}

- (void)showAleartWithTitle:(NSString *)title{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 3) {
        return  _myStyleType == CaseStyleType2D ? _myCaseDetailModel.roomImages.count + 1 : _myCaseDetailModel.spaceDetails.count + 1;
    }
    if (section == 4) {
        if (_datasSourse.count != 0) {
            return _isShowAll ? _datasSourse.count + 1 :  _datasSourse.count > 3 ? 3 + 1 : _datasSourse.count + 1;
        }else{
            return 2;
        }
        
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0) {
                ESCaseHeaderImageView *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaseHeaderImageView" forIndexPath:indexPath];
                cell.delegate = self;
                cell.myStyleType = _myStyleType;
                cell.model = _myCaseDetailModel;
                return cell;
            }else{
                ESCaseDesignerInfoView *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaseDesignerInfoView" forIndexPath:indexPath];
                cell.model = _myCaseDetailModel;
                cell.delegate = self;
                cell.iconView.hidden = (_myStyleType == CaseStyleType2D);
                cell.iconH.constant = (_myStyleType == CaseStyleType2D) ? 0 : 78;
                cell.myStyleType = _myStyleType;
                cell.desginModel = _myDesignerModel;
                return cell;
            }
        }
        case 1:{
            if (indexPath.row == 0) {
                ESCaseSectionView *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaseSectionView" forIndexPath:indexPath];
                cell.sectionName.text = @"户型图";
                cell.hidden = [_myCaseDetailModel.photo2DUrl isEqualToString:@""];
                return cell;
            }else{
                ESCase4to3ImageView *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCase4to3ImageView" forIndexPath:indexPath];
                [cell.caseImageView sd_setImageWithURL:[NSURL URLWithString:_myCaseDetailModel.photo2DUrl] placeholderImage:nil];
                cell.hidden = [_myCaseDetailModel.photo2DUrl isEqualToString:@""];
                cell.numLab.hidden = YES;
                return cell;
            }
        }
        case 2:{
            if (indexPath.row == 0) {
                ESCaseSectionView *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaseSectionView" forIndexPath:indexPath];
                cell.sectionName.text = @"鸟瞰图";
                cell.hidden = ![ESCase4to3ImageView getCellHeightModel:_myCaseDetailModel];
                return cell;
            }else{
                
                ESCase4to3ImageView *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCase4to3ImageView" forIndexPath:indexPath];
//                [cell.caseImageView sd_setImageWithURL:[NSURL URLWithString:_myCaseDetailModel.photo3DUrl] placeholderImage:nil];
                cell.aerialViewModel = _myCaseDetailModel;
                cell.hidden = ![ESCase4to3ImageView getCellHeightModel:_myCaseDetailModel];
                cell.numLab.hidden = NO;
                return cell;

            }
        }
        case 3:{
            if (indexPath.row == 0) {
                ESCaseSectionView *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaseSectionView" forIndexPath:indexPath];
                cell.sectionName.text = @"案例空间";
                return cell;
            }else{
                ESCase16to9ImageView *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCase16to9ImageView" forIndexPath:indexPath];
                cell.delegate = self;
                cell.myStyleType = _myStyleType;
//                cell.model = _myStyleType == CaseStyleType2D ? _myCaseDetailModel.roomImages[indexPath.row - 1] :
//                 _myCaseDetailModel.spaceDetails[indexPath.row - 1];
                if ( _myStyleType == CaseStyleType2D) {
                    ESCase2DImageModel *model =  _myCaseDetailModel.roomImages[indexPath.row -1];
                    cell.model2d = model;
                } else {
                    ESCaseSpaceDetails *model = _myCaseDetailModel.spaceDetails[indexPath.row - 1];
                    cell.model = model;
                }
                return cell;
            }
        }
        case 4:{
            if (indexPath.row == 0) {
                ESCaseSectionView *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaseSectionView" forIndexPath:indexPath];
                cell.sectionName.text = @"案例评论";
                return cell;
            }else{
                if (_datasSourse.count != 0) {
                    ESCaseCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaseCommentCell" forIndexPath:indexPath];
                    ESCaseCommentModel *model = _datasSourse[indexPath.row - 1];
                    [cell setFavDatas:model tapBlock:nil];
                    return cell;
                }else{
                    ESCaseNoCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESCaseNoCommentCell" forIndexPath:indexPath];
                    return cell;
                }
            }
        }
        default:
            return nil;
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    WS(weakSelf)
//    if (_myStyleType == CaseStyleType3D && _hasRecommend == YES) {
//        if (0 == section || 2 == section) {
//            ESGrayTableViewHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
//            return header;
//        } else if (1 == section) {
//            ESCaseHeaderView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESCaseHeaderView"];
//            [header setTitle:@"推荐商品" subTitle:@"全部商品" subImgName:nil subTitleColor:[UIColor stec_subTitleTextColor] tapBlock:^{
//                SHLog(@"全部商品");
//                ESCaseProduvtListViewController *caseProduvtListViewCon = [[ESCaseProduvtListViewController alloc] init];
//                [caseProduvtListViewCon setCaseId:weakSelf.caseId];
//                [weakSelf.navigationController pushViewController:caseProduvtListViewCon animated:YES];
//            }];
//            return header;
//        } else {
//            ESCaseHeaderView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESCaseHeaderView"];
//            [header setTitle:[NSString stringWithFormat:@"评论(%ld)", (long)_commentAllNum] subTitle:@"说点什么" subImgName:@"case_commit" subTitleColor:[UIColor stec_blueTextColor] tapBlock:^{
//                SHLog(@"调起键盘");
//                [weakSelf keyBoardUp];
//            }];
//            return header;
//        }
//    } else {
//        if (0 == section || 1 == section) {
//            ESGrayTableViewHeaderFooterView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
//            return header;
//        } else {
//            ESCaseHeaderView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESCaseHeaderView"];
//            [header setTitle:[NSString stringWithFormat:@"评论(%ld)", (long)_commentAllNum] subTitle:@"说点什么" subImgName:@"case_commit" subTitleColor:[UIColor stec_blueTextColor] tapBlock:^{
//                SHLog(@"调起键盘");
//                [weakSelf keyBoardUp];
//            }];
//            return header;
//        }
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0) {
                return SCREEN_WIDTH * 0.56;
            }else{
                
                return  _myStyleType == CaseStyleType2D ? 82 : 160;
            }
        }
        case 1:{
            if (indexPath.row == 0) {
                return [_myCaseDetailModel.photo2DUrl isEqualToString:@""] ? 0 : 65;
            }else{
                return [_myCaseDetailModel.photo2DUrl isEqualToString:@""] ? 0 : SCREEN_WIDTH * 0.75 + 8;
            }
        }
        case 2:{
            if (indexPath.row == 0) {
                return [ESCase4to3ImageView getCellHeightModel:_myCaseDetailModel] ? 65 : 0;
            }else{
                
                return [ESCase4to3ImageView getCellHeightModel:_myCaseDetailModel] ? SCREEN_WIDTH * 0.75 + 8 : 0;
            }
        }
        case 3:{
            if (indexPath.row == 0) {
                return 65;
            }else{
                if ( _myStyleType == CaseStyleType2D) {
                  ESCase2DImageModel *model =  _myCaseDetailModel.roomImages[indexPath.row -1];
                    return [ESCase16to9ImageView currentImageViewHeight:model.description_Space];
                } else {
                  ESCaseSpaceDetails *model = _myCaseDetailModel.spaceDetails[indexPath.row - 1];
                    return [ESCase16to9ImageView currentImageViewHeight:model.description_Space];
                }
            }
        }
        case 4:{
            if (indexPath.row == 0) {
                return 65;
            }else{
                if (_datasSourse.count != 0) {
                    ESCaseCommentModel *model = _datasSourse[indexPath.row - 1];
                    return [ESCaseCommentCell currentCommitViewHeight:model.comment];
                }else{
                    return 150;
                }
            }
        }
        default:
            return 0;
    }
}
#pragma mark ---UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self.view endEditing:YES];
//
//    CGFloat oraginY =  160;
//    float per = (scrollView.contentOffset.y - SCREEN_WIDTH * 0.5) / oraginY;
//    self.designHeadView.alpha = per;
////    self.titleLabel.alpha = 1 - per;
//    if (per > 0){
//        self.titleLabel.alpha = 0;
//    }else {
//        self.titleLabel.alpha = 1;
//    }
//
//}

#pragma mark --- Private Method
//添加推荐分享按钮
- (void)createShareRecBtn {
    if ([self isNeedShowSharedRecBtn]) {
        [self.view addSubview:self.shareRecBtn];
    }
}

//是否需要创建推荐分享按钮
- (BOOL)isNeedShowSharedRecBtn {
    BOOL status = [ESLoginManager sharedManager].isLogin;
    if (!status) {//未登录，不需要显示
        return NO;
    }
    
    if (self.myStyleType != CaseStyleType3D ) {//如果案例不是3D案例，不需要显示
        return NO;
    }
    
    return YES;
}
- (void)isHiddenSharedRecBtn {
    if (![SHAppGlobal AppGlobal_GetIsDesignerMode]) {//当前用户非设计师角色
        return;
    }
    NSString *currentPageId = self.myCaseDetailModel.designerInfo.jmemberId;
    NSString *currentUserId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    if (currentUserId == nil || currentPageId == nil) {
        self.shareRecBtn.hidden = YES;
    }else if ([currentPageId isEqualToString:currentUserId]) {//是否为当前用户个人3D案例
        self.shareRecBtn.hidden = NO;
    }else {
        self.shareRecBtn.hidden = YES;
    }
    if ([self.myCaseDetailModel.designerInfo.isContract isEqualToString:@"1"]) {//当前为签约设计师
        self.shareRecBtn.hidden = NO;
    } else {
        self.shareRecBtn.hidden = YES;
    }
}
#pragma mark -- 推荐分享页
- (void)sharedRecAction {
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    ESRecViewController *recVC = [[ESRecViewController alloc] init];
    recVC.sharedModel = self.myCaseDetailModel.shareInfo;
    recVC.sourceType = @10;
    recVC.baseId = [numFormatter numberFromString:self.caseId];
    [self.navigationController pushViewController:recVC animated:YES];
}

#pragma mark ---- 懒加载
- (UIButton *)shareRecBtn {
    if (!_shareRecBtn) {
        _shareRecBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_shareRecBtn setTitle:@"推荐分享 >" forState:UIControlStateNormal];
        [_shareRecBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _shareRecBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//        _shareRecBtn.backgroundColor = ColorFromRGA(0xE28500,0.5);
        [_shareRecBtn addTarget:self action:@selector(sharedRecAction) forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [UIImage imageNamed:@"recommend_share"];
        [_shareRecBtn setBackgroundImage:image forState:UIControlStateNormal];
        _shareRecBtn.frame = CGRectMake(SCREEN_WIDTH - image.size.width, _tabBarView.frame.origin.y - image.size.height - 40, image.size.width, image.size.height);
        _shareRecBtn.hidden = YES;
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_shareRecBtn.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
//        maskLayer.frame = _shareRecBtn.bounds;
//        maskLayer.path = maskPath.CGPath;
//        _shareRecBtn.layer.mask = maskLayer;
    }
    return _shareRecBtn;
}

//- (void)keyBoardUp {
//
//    if ([ESLoginManager sharedManager].isLogin) {
//        _tempTextField.inputAccessoryView = _toolBar;
//        [_tempTextField becomeFirstResponder];
//        [_inputView.textField becomeFirstResponder];
//        [_tempTextField resignFirstResponder];
//    }else {
//        [MGJRouter openURL:@"/UserCenter/LogIn"];
//    }    
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [WXApiManager sharedManager].delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[ESLoginManager sharedManager] removeLoginDelegate:self];
    SHLog(@"ESCaseDetailViewController页面释放");
}



#pragma mark - ESLoginManagerDelegate
- (void)onLogin {
    //[self requestCaseDetailDatasCompletion:nil];
}

- (void)onLogout {
    
}

- (void)showShareToast {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"分享后会随机给客户生成优惠券哦~";
    hud.margin = 30.f;
    hud.bezelView.backgroundColor = [UIColor whiteColor];
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    [hud hideAnimated:YES afterDelay:4];
    
}

-(void)openPhoto360Url:(NSString *)url {
    JRWebViewController *webViewCon = [[JRWebViewController alloc] init];
    [webViewCon setTitle:@"" url:url];
    [webViewCon setNavigationBarHidden:YES hasBackButton:YES];
    webViewCon.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewCon animated:YES];
}

- (void)pushToDesignerPage:(NSString *)designid {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:designid forKey:@"designId"];
    [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];
}

#pragma mark --- private method
//进入设计师详情
- (void)showDesignView {
    NSString *designId = _myCaseDetailModel.designerInfo.jmemberId;
    if (designId == nil){
        designId = _myCaseDetailModel.designerId;
    }
    [self pushToDesignerPage:designId];

}


#pragma mark ----- 懒加载
- (UIView *)designHeadView {
    if (!_designHeadView){
        _designHeadView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_designHeadView addTarget:self action:@selector(showDesignView) forControlEvents:UIControlEventTouchUpInside];
        CGFloat x = (SCREEN_WIDTH - 100) / 2;
        _designHeadView.frame = CGRectMake(x, STATUSBAR_HEIGHT, 100, 44);
        
        _headImgView = [[UIImageView alloc] init];
        _headImgView.frame = CGRectMake(0, 3, 38, 38);
        _headImgView.layer.cornerRadius = 19;
        _headImgView.layer.masksToBounds = YES;
        _headImgView.userInteractionEnabled = YES;
        [_designHeadView addSubview:_headImgView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.frame = CGRectMake(49, 0, 50, 44);
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_designHeadView addSubview:_nameLabel];
        
        _designHeadView.alpha = 0;
    }
    return _designHeadView;
}

@end
