//
//  ESMyMessageViewController.m
//  Consumer
//
//  Created by 张德凯 on 2017/11/13.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMyMessageViewController.h"
#import "ESMyMessageTableViewCell.h"
#import "ESMemberAPI.h"
#import "JRKeychain.h"
#import "ESMyMessageModel.h"
#import "ESDiyRefreshHeader.h"
#import "MBProgressHUD+NJ.h"
#import <ESNetworking/SHRequestTool.h>

@interface ESMyMessageViewController ()
<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray<ESMyMessageModel*> *datasource;
@property (nonatomic,assign) NSInteger pageNum;
@property (nonatomic,assign) BOOL hasInvoked;


@end

@implementation ESMyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeData];
    [self initilizeUI];
    [self requestData:0];
}
#pragma mark Initialize UI
- (void)initializeData {
    _datasource = [NSMutableArray new];
    _pageNum = 0;
    _hasInvoked = NO;
}
- (void)initilizeUI {
    self.titleLabel.text = @"消息中心";
    self.rightButton.hidden = YES;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT) style:(UITableViewStylePlain)];
    [self.view addSubview:_tableView];
    _tableView.estimatedRowHeight = 100;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[ESMyMessageTableViewCell class ] forCellReuseIdentifier:@"ESMyMessageTableViewCell"];
}

#pragma mark NetWork
- (void)requestData:(NSInteger)pageNum {
    WS(weakSelf)
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ////测试：@"35768796878733312"  [JRKeychain loadSingleUserInfo:UserInfoCodeJId]
    [ESMemberAPI getMyMessageListWithParam:@{@"receiver":[JRKeychain loadSingleUserInfo:UserInfoCodeJId],@"offset":@(pageNum),@"limit":@(20)} andSuccess:^(NSDictionary *dict) {
        
        [weakSelf loadNewData:pageNum dict:dict];
        
    } andFailure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        if (weakSelf.datasource.count == 0) {
            [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_chat" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf requestData:0];
            }];
            [weakSelf.view sendSubviewToBack:weakSelf.tableView];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
        }
    }];
}

#pragma mark UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESMyMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESMyMessageTableViewCell"];
    if (_datasource.count > 0) {
        [cell setMessageModel:_datasource[indexPath.row]];
    }
    return cell;
}

#pragma mark ovveride
- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Private Action
- (void)addRefresh {
    if (!_hasInvoked) {
        WS(weakSelf)
        _tableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
            weakSelf.pageNum = 0;
            [weakSelf requestData:0];
        }];
        
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            weakSelf.pageNum += 1;
            [weakSelf requestData:weakSelf.pageNum];
        }];
        _hasInvoked = YES;
    }
}

- (void)loadNewData:(NSInteger)pageNum dict:(NSDictionary *)dict {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SHLog(@"我的消息:%@",dict);
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer endRefreshing];
    
    if (pageNum == 0) {
        [_datasource removeAllObjects];
    } else if (pageNum>0 && dict == nil) {
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }
    
    NSMutableArray *tmpArray = [ESMyMessageModel getmodelArrayWithDic:dict];;
    for (ESMyMessageModel *model in tmpArray) {
        [_datasource  addObject:model];
    }
    
    if (_datasource.count == 0) {
        [self showNoDataIn:self.view imgName:@"nodata_chat" frame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT) Title:@"啊哦~暂时没有数据~" buttonTitle:nil Block:nil];
        [self.view sendSubviewToBack:_tableView];
        return ;
    } else {
        [self addRefresh];
        [self removeNoDataView];
        [self.view bringSubviewToFront:_tableView];
    }
    [_tableView reloadData];
    [self updateMessageStatus];
}

- (void)updateMessageStatus {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [ESMemberAPI updateMyMessageStatus:@{@"receiver":[JRKeychain loadSingleUserInfo:UserInfoCodeJId]} andSuccess:^(NSDictionary *dict) {
            BOOL sucess = dict[@"success"];
            if (sucess) {
                SHLog(@"更新成功");
            }
        } andFailure:^(NSError *error) {
            SHLog(@"更新失败");
        }];
    });
}

@end
