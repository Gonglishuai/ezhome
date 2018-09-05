//
//  ESAddressManagementView.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESAddressManagementView.h"
#import "ESDiyRefreshHeader.h"
#import "ESAddressManagementCell.h"


@interface ESAddressManagementView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIButton *addNewAddrBtn;

@end

@implementation ESAddressManagementView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initTableView:frame];
    }
    return self;
}

- (void)initTableView: (CGRect)frame {
    self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height - (TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT)) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"ESAddressManagementCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESAddressManagementCell"];
    self.tableView.estimatedRowHeight = 200.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self addMJRefresh];
    [self addSubview: self.tableView];
    
    self.addNewAddrBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, frame.size.height - (TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT), frame.size.width, (TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT))];
    [self.addNewAddrBtn addTarget:self action:@selector(addNewAddrBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.addNewAddrBtn.backgroundColor = ColorFromRGA(0x2696C4, 1);
    [self.addNewAddrBtn setTitle:@"+ 添加收货地址" forState:UIControlStateNormal];
    [self.addNewAddrBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f]];
    [self addSubview:self.addNewAddrBtn];
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        self.addNewAddrBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
    [self setNewAddressButtonVisible:NO];
    
}

- (void)setNewAddressButtonVisible:(BOOL)visible {
    self.addNewAddrBtn.hidden = !visible;
}

- (void)refreshMainView {
    [self.tableView reloadData];
}

- (void)addNewAddrBtnClick: (UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(addNewAddress)]) {
        [self.delegate addNewAddress];
    }
}

- (void)addMJRefresh {
    WS(weakSelf);
    self.tableView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        if ([weakSelf.delegate respondsToSelector:@selector(refreshLoadNewData)]) {
            [weakSelf.delegate refreshLoadNewData];
        }
    }];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)startFreshHeaderView {
    [self.tableView.mj_header beginRefreshing];
}

- (void)stopFreshHeaderView {
    [self.tableView.mj_header endRefreshing];
}

- (void)deleteAddressWithIndex:(NSInteger)index {
    @try {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESAddressManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESAddressManagementCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = (id)self.delegate;
    [cell updateAddrManagementCell:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getAddressNums)]) {
        return [self.delegate getAddressNums];
    }
    return 0;
}

@end
