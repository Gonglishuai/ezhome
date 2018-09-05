//
//  ESReturnGoodsDetailView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnGoodsDetailView.h"

@interface ESReturnGoodsDetailView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *bottomBtn;
@end
@implementation ESReturnGoodsDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initTableView:frame];
    }
    return self;
}

- (void)initTableView:(CGRect)frame {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESOrderStatusCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderStatusCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESReturnGoodsPriceCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESReturnGoodsPriceCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESOrderDescriptionCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderDescriptionCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESTitleTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESTitleTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESReturnGoodsItemCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESReturnGoodsItemCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESClickCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESClickCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESReturnGoodsOrderInfoCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESReturnGoodsOrderInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ESOrderDetailPersonTableViewCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESOrderDetailPersonTableViewCell"];
    
    self.tableView.estimatedRowHeight = 250;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    self.bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, frame.size.height - 49, frame.size.width, 49)];
    [self.bottomBtn setBackgroundColor:[UIColor stec_blueTextColor]];
    [self.bottomBtn setTitle:@"确认退款成功" forState:UIControlStateNormal];
    [self.bottomBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f]];
    [self.bottomBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.bottomBtn.hidden = YES;
    [self addSubview:self.bottomBtn];
}


- (void)refreshMainView {
    [self.tableView reloadData];
}

- (void)confirmBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(confirmReturnTap)]) {
        [self.delegate confirmReturnTap];
    }
}

- (void)showBottomView:(BOOL)show {
    self.bottomBtn.hidden = !show;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(getSectionNums)]) {
        return [self.delegate getSectionNums];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getItemsNums:)]) {
        return [self.delegate getItemsNums:section];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(getCellWithTableView:andIndexPath:)]) {
        
        UITableViewCell *cell = [self.delegate getCellWithTableView:tableView andIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectCellWithCellClass:)]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *className = [NSString stringWithUTF8String:object_getClassName(cell)];
        [self.delegate didSelectCellWithCellClass:className];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
        view.backgroundColor = [UIColor stec_viewBackgroundColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 100, 19)];
        label.textColor = [UIColor stec_subTitleTextColor];
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0];
        label.text = @"退款信息";
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat height = section == 4 ? 160.0f : 10.0f;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    view.backgroundColor = [UIColor stec_viewBackgroundColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return 35.0f;
    }
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    BOOL isFromRecommend = NO;
    if ([self.delegate respondsToSelector:@selector(getFromRecommend)]) {
        isFromRecommend = [self.delegate getFromRecommend];
    }
    if (isFromRecommend) {
        if (section == 5) {
            return 70.0f;
        }
    } else {
        if (section == 4) {
            return 70.0f;
        }
    }
    return 10.0f;
}
@end
