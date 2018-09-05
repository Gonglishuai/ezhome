//
//  DesignerExampleViewController.m
//  Consumer
//
//  Created by jiang on 2017/5/18.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "DesignerExampleViewController.h"
#import "SHSegmentedControl.h"
#import "MBProgressHUD.h"
#import "MPOrderEmptyView.h"
#import "MPCaseBaseModel.h"
#import "MP3DCaseBaseModel.h"
#import "CoCaseDetailController.h"
#import "ESDiyRefreshHeader.h"
#import "MPDesignerDetail3DTableViewCell.h"
#import "MP3DCaseModel.h"
#import "MPCaseModel.h"
#import "JRKeychain.h"
#import "ESCaseDetailViewController.h"
#import <ESNetworking/SHAlertView.h>
#import "MPDesignerDetailTableViewCell.h"

@interface DesignerExampleViewController ()<SHSegmentedControlDelegate, UITableViewDelegate, UITableViewDataSource>
{
    MPOrderEmptyView *_emptyView;               //!< _emptyView the view for no case.
}
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *twoDTableView;
@property (nonatomic, strong) UITableView *threeDTableView;
@property (nonatomic, strong) NSMutableArray *twoDdatas;
@property (nonatomic, strong) NSMutableArray *threeDdatas;
@property (nonatomic, assign) BOOL isLoadMore;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger offset3D;
@end

@implementation DesignerExampleViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.delegate = nil;
    _twoDdatas = [NSMutableArray array];
    _threeDdatas = [NSMutableArray array];
    [self loadBaseUI];
    [self initData];
    [self setupNavigationBar];
    [self init3DTableView];
    [self init2DTableView];
    [self requestData];
}

- (void)initData {
    
    _limit = 10;
    _offset = 0;
    _offset3D = 0;
}

- (void)init2DTableView {
    self.twoDTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT)];
    self.twoDTableView.delegate = self;
    self.twoDTableView.dataSource = self;
    self.twoDTableView.showsVerticalScrollIndicator = NO;
    self.twoDTableView.backgroundColor = [UIColor whiteColor];
    self.twoDTableView
    .separatorStyle = UITableViewCellSeparatorStyleNone;
    [ self.twoDTableView registerNib:[UINib nibWithNibName:@"MPDesignerDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"MPDesignerDetail"];
    self.twoDTableView.estimatedRowHeight = 500;
    [self.view addSubview: self.twoDTableView];
    WS(weakSelf)
    self.twoDTableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        weakSelf.isLoadMore = NO;
        weakSelf.offset = 0;
        [weakSelf requestData];
    }];
    
    self.twoDTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.isLoadMore = YES;
        [weakSelf requestData];
    }];
    
}

- (void)init3DTableView {
    self.threeDTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT)];
    self.threeDTableView.delegate = self;
    self.threeDTableView.dataSource = self;
    self.threeDTableView.showsVerticalScrollIndicator = NO;
    self.threeDTableView.backgroundColor = [UIColor whiteColor];
    self.threeDTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.threeDTableView registerNib:[UINib nibWithNibName:@"MPDesignerDetail3DTableViewCell" bundle:nil] forCellReuseIdentifier:@"MPDesignerDetail3D"];
    self.threeDTableView.estimatedRowHeight = 500;
    [self.view addSubview: self.threeDTableView];
    WS(weakSelf)
    self.threeDTableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        weakSelf.isLoadMore = NO;
        weakSelf.offset3D = 0;
        [weakSelf request3DData];
    }];
    
    self.threeDTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.isLoadMore = YES;
        [weakSelf request3DData];
    }];
    
}

- (void) setupNavigationBar
{
    [super setupNavigationBar];
    self.menuLabel.hidden = YES;
    self.leftButton.hidden = NO;
}
- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadBaseUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.rightButton.hidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 0084ff
    SHSegmentedControl *segment = [[SHSegmentedControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-90, NAVBAR_HEIGHT-44, 190, 44)];
    segment.lineColor = [UIColor stec_blueTextColor];
    segment.titleColor = [UIColor stec_blueTextColor];
    segment.titlePlaceColor = [UIColor stec_titleTextColor];
    segment.delegate = self;
    [segment createSegUIWithTitles:@[@"效果图",@"3D方案"]];
    [self.navgationImageview addSubview:segment];
    
    
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - NAVBAR_HEIGHT - 40)];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    
    [self.view bringSubviewToFront:self.navgationImageview];
}

#pragma mark - SHSegmentedControlDelegate
- (void)segBtnClickWithTitleIndex:(NSInteger)index
{
    if(index == 0) {
        SHLog(@"/N2D 加载在数据");
        [self.view bringSubviewToFront:_twoDTableView];
        if (_twoDdatas.count == 0) {
            [self createEmptyViewWithTitle:@"0"];
            _isLoadMore = NO;
            _offset = 0;
            [self requestData];
            
        } else {
            if (_emptyView) [_emptyView removeFromSuperview];
        }
        
    }else {
        [self.view bringSubviewToFront:_threeDTableView];
        SHLog(@"/N3D 加载在数据");
        if (_threeDdatas.count == 0) {
            _isLoadMore = NO;
            _offset3D = 0;
            [self createEmptyViewWithTitle:@"0"];
            [self request3DData];
            
        }else{
            if (_emptyView) [_emptyView removeFromSuperview];
        }
        
    }
}




// 2D请求数据
- (void)requestData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _designerID = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];//[SHMember shareMember].acs_member_id;
    
    if (_designerID == nil) {
        [SHAlertView showAlertForParameterError];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self createEmptyViewWithTitle:@"0"];
        return;
    }
    
    [MPCaseBaseModel getDataWithParameters:@{@"designer_id":_designerID,@"offset":@(_offset),@"limit":@(_limit)} success:^(NSArray *array,NSString *count) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!_isLoadMore) {
            [_twoDdatas removeAllObjects];
        }
        [weakSelf.twoDTableView.mj_header endRefreshing];
        [weakSelf.twoDTableView.mj_footer endRefreshing];
        [_twoDdatas addObjectsFromArray:array];
        _offset = _twoDdatas.count;
        
        if (_isLoadMore) {
            if (array.count != 0) {
                [weakSelf.twoDTableView reloadData];
            }
        }else{
            [weakSelf.twoDTableView reloadData];
        }
        
        if (_twoDdatas.count == 0) {
            [self createEmptyViewWithTitle:@"0"];
        } else {
            if (_emptyView) [_emptyView removeFromSuperview];
        }
        
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.twoDTableView.mj_header endRefreshing];
        [weakSelf.twoDTableView.mj_footer endRefreshing];
        [SHAlertView showAlertForNetError];
    }];
    
    
}

// 3D请求数据
- (void)request3DData {
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _designerID = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];//[SHMember shareMember].acs_member_id;
    
    if (_designerID == nil) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [SHAlertView showAlertForParameterError];
        
        return;
    }
    
    [MP3DCaseBaseModel getDataWithParameters:@{@"designer_id":_designerID,@"offset":@(_offset3D),@"limit":@(_limit)} success:^(NSArray *array,NSString *count) {
        if (!_isLoadMore) {
            [_threeDdatas removeAllObjects];
        }
        [weakSelf.threeDTableView.mj_header endRefreshing];
        [weakSelf.threeDTableView.mj_footer endRefreshing];
        [_threeDdatas addObjectsFromArray:array];
        _offset3D = _threeDdatas.count;
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (_isLoadMore) {
            if (array.count != 0) {
                [_threeDTableView reloadData];
            }
        }else{
            [_threeDTableView reloadData];
        }
        
        if (_threeDdatas.count == 0) {
            [self createEmptyViewWithTitle:@"0"];
        } else {
            if (_emptyView) [_emptyView removeFromSuperview];
        }
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.threeDTableView.mj_header endRefreshing];
        [weakSelf.threeDTableView.mj_footer endRefreshing];
        [SHAlertView showAlertForNetError];
        
    }];
    
}


- (void)createEmptyViewWithTitle:(NSString *)string{
    //    if (_emptyView) return;
    [_emptyView removeFromSuperview];
    _emptyView = [[[NSBundle mainBundle] loadNibNamed:@"MPOrderEmptyView" owner:self options:nil] lastObject];
    _emptyView.frame = CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT);
    
    _emptyView.imageViewY.constant = SCREEN_HEIGHT/2-50;
    
    NSString *emptyInfo;
    
    if ([string isEqualToString:@"0"]) {
        emptyInfo = @"暂无案例";
    }else {
        emptyInfo = string;
    }
    _emptyView.infoLabel.text = emptyInfo;
    //    [_designerDetailView.deisgnerTableView addSubview:_emptyView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    view.backgroundColor = [UIColor lightGrayColor];
    view.alpha = 0.3;
    [_emptyView addSubview:view];
    [self.view addSubview:_emptyView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_twoDTableView == tableView) {
        return _twoDdatas.count;
    } else {
        return _threeDdatas.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_twoDTableView == tableView) {
        ESDesignCaseList * model = [_twoDdatas objectAtIndex:indexPath.row];
        
        MPDesignerDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPDesignerDetail" forIndexPath:indexPath];
        [cell setModel:model];
        [cell updateCellForIndex:indexPath.row];
        return cell;
    } else {
        ESDesignCaseList * model = [_threeDdatas objectAtIndex:indexPath.row];
        MPDesignerDetail3DTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPDesignerDetail3D" forIndexPath:indexPath];
        [cell setModel:model];
        [cell update3DCellForIndex:indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_WIDTH * CASE_IMAGE_RATIO + 63;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_twoDTableView == tableView) {
        ESDesignCaseList * model = [_twoDdatas objectAtIndex:indexPath.row];
        UIViewController *caseDetailVC = nil;
        if (model.isNew)
        {
            ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
            [vc setCaseId:model.assetId caseStyle:CaseStyleType2D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
            caseDetailVC = vc;
        }
        else
        {
            caseDetailVC = [[CoCaseDetailController alloc] initWithCaseID:model.assetId];
        }
        [self.navigationController pushViewController:caseDetailVC animated:YES];
    } else {
        
        
        ESDesignCaseList * model = [_threeDdatas objectAtIndex:indexPath.row];
        if (model.designerId == nil || [model.designerId isKindOfClass:[NSNull class]] || [model.designerId isEqualToString:@""]) {
            
            if ([[JRKeychain loadSingleUserInfo:UserInfoCodeJId] isEqualToString:model.designerId]) {//[SHMember shareMember].acs_member_id
                [SHAlertView showAlertWithMessage:@"方案尚未完成，请至网页端完善设计" sureKey:nil];
                
            }else {
                [SHAlertView showAlertWithMessage:@"方案还在设计中，请浏览其他3D方案" sureKey:nil];
                
            }
            
            return;
        }
        
        ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
        [vc setCaseId:model.assetId caseStyle:CaseStyleType3D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

