//
//  ESSelectAddressView.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESSelectAddressView.h"
#import "ESSelectAddressCell.h"


@interface ESSelectAddressView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UIButton *addNewAddrBtn;

@end

@implementation ESSelectAddressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initTableView:frame];
    }
    return self;
}

- (void)initTableView: (CGRect)frame {
    self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height - TABBAR_HEIGHT-BOTTOM_SAFEAREA_HEIGHT) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"ESSelectAddressCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESSelectAddressCell"];
    self.tableView.estimatedRowHeight = 105.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self addMJRefresh];
    [self addSubview: self.tableView];
    
    self.addNewAddrBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, frame.size.height - TABBAR_HEIGHT-BOTTOM_SAFEAREA_HEIGHT, frame.size.width, TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT)];
    [self.addNewAddrBtn addTarget:self action:@selector(addNewAddrBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.addNewAddrBtn.backgroundColor = ColorFromRGA(0x2696C4, 1);
    [self.addNewAddrBtn setTitle:@"+ 添加收货地址" forState:UIControlStateNormal];
    [self.addNewAddrBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f]];
    [self addSubview:self.addNewAddrBtn];
    [self setNewAddressButtonVisible:NO];
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        self.addNewAddrBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
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

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESSelectAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESSelectAddressCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = (id)self.delegate;
    
    BOOL valid = NO;
    if ([self.delegate respondsToSelector:@selector(getAddressValidWithSection:)]) {
        valid = [self.delegate getAddressValidWithSection:indexPath.section];
    }
    
    cell.enabel = valid;
    [cell updateSelectAddrCellWithSection:indexPath.section andIndex:indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BOOL valid = NO;
    if ([self.delegate respondsToSelector:@selector(getAddressValidWithSection:)]) {
        valid = [self.delegate getAddressValidWithSection:section];
    }
    if (!valid) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        view.backgroundColor = ColorFromRGA(0xEEF1F4, 1);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 180, 30)];
        label.text = @"以下地址不在配送范围内";
        [label setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:14.0f]];
        label.textColor = ColorFromRGA(0xC2C2C9, 1);
        [view addSubview:label];
        
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    BOOL valid = NO;
    if ([self.delegate respondsToSelector:@selector(getAddressValidWithSection:)]) {
        valid = [self.delegate getAddressValidWithSection:section];
    }
    
    return valid ? 0.01 : 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(getAddressGroupNums)]) {
        return [self.delegate getAddressGroupNums];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getAddressNumsWithSection:)]) {
        return [self.delegate getAddressNumsWithSection:section];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(selectAddressWithSection:WithIndex:)]) {
        [self.delegate selectAddressWithSection:indexPath.section WithIndex:indexPath.row];
    }
}
@end
