//
//  ESRecommendFromDesingerController.m
//  Consumer
//
//  Created by shejijia on 13/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
#import "ESRecommendFromDesingerController.h"
#import "RecommendFromDesingerCell.h"
#import "ESRecommendDetailViewController.h"
#import "ESCaseDetailViewController.h"
#import "ESBrandRecommendDetailViewController.h"
#import "MBProgressHUD+NJ.h"
#import <Masonry/Masonry.h>
#import "ESDiyRefreshHeader.h"
#import "ESRecommendAPI.h"
#import "ESRecommendRecordMemberModel.h"
#import <ESNetworking/SHRequestTool.h>
#import <JRKeychain.h>

#define RecommendOrderCellID  @"OrderCellID"

@interface ESRecommendFromDesingerController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableview;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger pageNum;
@property (strong, nonatomic) NSMutableArray *datasSource;
@property (strong, nonatomic) NSMutableArray *baseIDSource;

@end

@implementation ESRecommendFromDesingerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"设计师推荐";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTableview];
    _pageNum = 0;
    _pageSize = 20;
    _datasSource = [NSMutableArray array];
    _baseIDSource = [NSMutableArray array];
     [self requestData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setTableview{
    [self.view addSubview:self.tableview];
    WS(weakSelf);
    _tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refresh];
    }];
    
    _tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf nextpage];
    }];
}

- (void)refresh {
    _pageNum = 0;
    [self requestData];
}

- (void)nextpage {
    _pageNum = _pageNum+20;
    [self requestData];
}
#pragma  mark  ---- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecommendFromDesingerCell *cell = [tableView dequeueReusableCellWithIdentifier:RecommendOrderCellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_datasSource.count > 0) {
        [cell setInfo:[_datasSource objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section < _datasSource.count) {
        ESRecommendRecordMemberModel *info = [_datasSource objectAtIndex:indexPath.row];
        NSString *modelBaseID = [NSString stringWithFormat:@"%ld",(long)info.baseId];
        //得到当前点击的type
        NSString *typeID  = _baseIDSource[indexPath.row];
        NSInteger listID = typeID.integerValue;
        if (listID == 10) {
            ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
            NSString * caseId = [NSString stringWithFormat:@"%@", modelBaseID ? modelBaseID : @""];
            [vc setCaseId:[NSString stringWithFormat:@"%@",caseId] caseStyle:CaseStyleType3D caseSource:CaseSourceTypeBy3D caseCategory:CaseCategoryNormal];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (listID == 20){
            ESRecommendDetailViewController *vc = [[ESRecommendDetailViewController alloc] init];
            NSString *recommendId = [NSString stringWithFormat:@"%@", modelBaseID ? modelBaseID : @""];
            [vc setRecommendId:recommendId];
            [self.navigationController pushViewController:vc animated:YES];
        }else if(listID == 30) {
            ESBrandRecommendDetailViewController *vc = [[ESBrandRecommendDetailViewController alloc] init];
            NSString *brandId = [NSString stringWithFormat:@"%@", modelBaseID ? modelBaseID : @""];
            [vc setRecommendId:brandId];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
}

#pragma ---- mark NetWork
- (void)requestData {
    WS(weakSelf);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSString *userInfoID = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    [ESRecommendAPI getDesignerRecommendList:userInfoID withOffset:self.pageNum withLimit:self.pageSize withSuccess:^(NSDictionary *dict) {
        SHLog(@"%@", dict);
        [weakSelf loadNewData:self.pageNum dict:dict];
    } andFailure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self endLoading];
        if (weakSelf.datasSource.count == 0) {
            [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_chat" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf requestData];
            }];
            [weakSelf.view sendSubviewToBack:weakSelf.tableview];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
        }
    }];
}

- (void)loadNewData:(NSInteger)pageNum dict:(NSDictionary *)dict {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self endLoading];
    if (pageNum == 0) {
        [_datasSource removeAllObjects];
        [_baseIDSource removeAllObjects];
    } else if (pageNum>0 && dict == nil) {
        [_tableview.mj_footer endRefreshingWithNoMoreData];
    }
    NSMutableArray *tmpArray = [ESRecommendRecordMemberModel getmodelArrayWithDic:dict];;
    for (ESRecommendRecordMemberModel *model in tmpArray) {
        NSString * dataId = [NSString stringWithFormat:@"%ld",model.sourceType];
        [_baseIDSource addObject:dataId];
        [_datasSource  addObject:model];
    }
    if (_datasSource.count == 0) {
        [self showNoDataIn:self.view imgName:@"nodata_chat" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"啊哦~暂时没有数据~" buttonTitle:nil Block:nil];
        [self.view sendSubviewToBack:_tableview];
        return ;
    } else {
        [self removeNoDataView];
        [self.view bringSubviewToFront:_tableview];
    }
     [_tableview reloadData];
    [self endLoading];
    
}

#pragma mark ---- Private Action

- (void)endLoading {
    [_tableview.mj_header endRefreshing];
    [_tableview.mj_footer endRefreshing];
}

#pragma mark ---- ovveride
- (void)tapOnLeftButton:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---- Lazy loading
- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.rowHeight = 148;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableview registerClass:[RecommendFromDesingerCell class] forCellReuseIdentifier:RecommendOrderCellID];
    }

    return _tableview;
}


@end


                                
