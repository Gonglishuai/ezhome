//
//  ESMemberInfoView.m
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMemberInfoView.h"
#import "ESMemberInfoCell.h"
#import <Masonry.h>
#import <UIButton+WebCache.h>

@interface ESMemberInfoView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *headerImgButton;
@property (nonatomic, weak) id<ESMemberInfoViewDelegate> delegate;
@end

@implementation ESMemberInfoView

- (instancetype)initWithDelegate:(id<ESMemberInfoViewDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self setUpTableView];
    }
    return self;
}

- (void)setUpTableView {
    UITableViewController *tvc = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.tableView = tvc.tableView;
    self.tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ESMemberInfoCell class] forCellReuseIdentifier:@"ESMemberInfoCell"];
    self.tableView.estimatedRowHeight = 50.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self addSubview:self.tableView];
    
    UIViewController *vc = (UIViewController *)self.delegate;
    [vc addChildViewController:tvc];
    
    __block UIView *b_self = self;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(b_self.mas_leading);
        make.top.equalTo(b_self.mas_top);
        make.trailing.equalTo(b_self.mas_trailing);
        make.bottom.equalTo(b_self.mas_bottom);
    }];
    
    self.tableView.tableHeaderView = [self headerView];
}

- (UIView *)headerView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 200)];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderView:)];
    [headerView addGestureRecognizer:tgr];
    headerView.backgroundColor = [UIColor whiteColor];
    
    self.headerImgButton = [[UIButton alloc] init];
    self.headerImgButton.layer.cornerRadius = 40.0f;
    self.headerImgButton.layer.masksToBounds = YES;
    [self.headerImgButton addTarget:self action:@selector(uploadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerImgButton sd_setBackgroundImageWithURL:[NSURL URLWithString:@""] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_header"]];
    [headerView addSubview:self.headerImgButton];
    
    UIButton *upLoadBtn = [[UIButton alloc] init];
    upLoadBtn.layer.cornerRadius = 15.0f;
    upLoadBtn.layer.masksToBounds = YES;
    [upLoadBtn setTitle:@"上传头像" forState:UIControlStateNormal];
    [upLoadBtn setBackgroundColor:ColorFromRGA(0xE7E7E6, 1)];
    [upLoadBtn addTarget:self action:@selector(uploadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:upLoadBtn];
    
    __block UIView *b_headerView = headerView;
    [self.headerImgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.top.equalTo(b_headerView.mas_top).with.offset(47);
        make.centerX.equalTo(b_headerView.mas_centerX);
    }];
    
    __block UIButton *b_headerImgButton = self.headerImgButton;
    [upLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.top.equalTo(b_headerImgButton.mas_bottom).with.offset(16);
        make.centerX.equalTo(b_headerView.mas_centerX);
    }];
    return headerView;
}

- (void)uploadBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(uploadButtonClick)]) {
        [self.delegate uploadButtonClick];
    }
}

- (void)refreshMainView {
    [self.tableView reloadData];
    NSString *url = @"";
    if ([self.delegate respondsToSelector:@selector(getHeaderUrl)]) {
        url = [self.delegate getHeaderUrl];
    }
    [self.headerImgButton sd_setBackgroundImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_header"]];
}

- (void)tapHeaderView:(UITapGestureRecognizer *)sender {
    [self endEditing:YES];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getItemNum)]) {
        return [self.delegate getItemNum];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ESMemberInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ESMemberInfoCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = (id)self.delegate;
    [cell updateCell:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(selectItem:)]) {
        [self.delegate selectItem:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}
@end
