//
//  ESMyCommentViewController.m
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMyCommentViewController.h"
#import "ESDiyRefreshHeader.h"
#import "MBProgressHUD+NJ.h"
#import "ESMyCommentTableCell.h"
#import "ESGrayTableViewHeaderFooterView.h"
#import "ESCaseDetailViewController.h"
#import "ESCaseAPI.h"
#import "ESCaseCommentModel.h"
#import "ESProductDetailViewController.h"
#import <ESNetworking/SHRequestTool.h>
#import <ESMallAssets.h>

@interface ESMyCommentViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datasSource;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (assign, nonatomic) NSInteger commentAllNum;
@end

@implementation ESMyCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"我的评论";
    // Do any additional setup after loading the view.
    _pageNum = 1;
    _pageSize = 10;
    _datasSource = [NSMutableArray array];
    [self setTableView];
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 150;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    [_tableView registerNib:[UINib nibWithNibName:@"ESMyCommentTableCell" bundle:nil] forCellReuseIdentifier:@"ESMyCommentTableCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESGrayTableViewHeaderFooterView" bundle:[ESMallAssets hostBundle]] forHeaderFooterViewReuseIdentifier:@"ESGrayTableViewHeaderFooterView"];
    //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    [self.view addSubview:_tableView];
    
    WS(weakSelf)
    _tableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
    
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf nextpage];
    }];
    [self refresh];
}

- (void)refresh {
    _pageNum = 1;
    [self requestData];
}

- (void)nextpage {
    _pageNum = _pageNum+1;
    [self requestData];
}

-(void)requestData{
    WS(weakSelf)
    [ESCaseAPI getMyCommentListWithPageNum:_pageNum pageSize:_pageSize andSuccess:^(NSArray *array, NSInteger commentNum) {
        [weakSelf.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (weakSelf.pageNum == 1) {
            [weakSelf.datasSource removeAllObjects];
        }
        [weakSelf.datasSource addObjectsFromArray:array];
        if (weakSelf.datasSource.count == 0) {
            [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_datas" frame:weakSelf.view.frame Title:@"啊哦~暂时没有数据~" buttonTitle:nil Block:nil];
        } else {
            [weakSelf removeNoDataView];
        }
        if (weakSelf.datasSource.count>=weakSelf.commentAllNum) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [weakSelf.tableView reloadData];
    } andFailure:^(NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        if (weakSelf.datasSource.count == 0) {
            [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_net" frame:weakSelf.view.frame Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf.tableView.mj_header beginRefreshing];
            }];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
        }
    }];
}

- (void)deleteCommentWithCommentId:(NSString *)commentId andIndex:(NSIndexPath *)indexPath {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ESCaseAPI deleteCommentWithGoalId:commentId andSuccess:^(NSDictionary *dict) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.datasSource removeObjectAtIndex:indexPath.section];
        [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        if (weakSelf.datasSource.count == 0) { // 要根据情况直接删除section或者仅仅删除row
            [weakSelf showNoDataIn:weakSelf.tableView imgName:@"nodata_datas" frame:weakSelf.view.frame Title:@"啊哦~暂时没有数据~" buttonTitle:nil Block:nil];
        }
        [MBProgressHUD showSuccess:@"删除成功~"];
    } andFailure:^(NSError *error) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
    }];
}

- (void)endLoading {
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _datasSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ESGrayTableViewHeaderFooterView *footer = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ESGrayTableViewHeaderFooterView"];
    [footer setBackViewColor:[UIColor stec_viewBackgroundColor]];
    return footer;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ESMyCommentTableCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ESMyCommentTableCell" forIndexPath:indexPath];
    if (_datasSource.count>indexPath.section) {
        ESCaseCommentModel *model = (ESCaseCommentModel *)_datasSource[indexPath.section];
        [cell setInfo:model];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_datasSource.count>indexPath.section) {
        ESCaseCommentModel *model = _datasSource[indexPath.section];
        
        if (1 == model.type || 2 == model.type) {//案例详情评论
            ESCaseDetailViewController *detail = [[ESCaseDetailViewController alloc] init];
            CaseStyleType type = CaseStyleType2D;
            if (model.type == 2) {
                type = CaseStyleType3D;
            }
            NSString *caseId = [NSString stringWithFormat:@"%ld", (long)model.resourceId];
            [detail setCaseId:caseId caseStyle:type caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryNormal];
            detail.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detail animated:YES];
        } else if (3 == model.type) {//商品评论
            NSString *goodid = [NSString stringWithFormat:@"%ld", (long)model.resourceId];
            ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc]
                                                                   initWithProductId:goodid type:ESProductDetailTypeSpu designerId:nil];
            productDetailViewCon.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:productDetailViewCon animated:YES];
        }
        
    }
    
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_datasSource.count>indexPath.section) {
        ESCaseCommentModel *model = _datasSource[indexPath.section];
        [self deleteCommentWithCommentId:[NSString stringWithFormat:@"%ld", (long)model.commentId] andIndex:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
