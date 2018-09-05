//
//  ESIMSessionListViewController.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESIMSessionListViewController.h"
#import "ESIMSessionViewController.h"
#import "ESNIMManager.h"
#import "Masonry.h"

#define SessionListTitle @"我的聊天"

@interface ESIMSessionListViewController ()
@property (nonatomic,assign) BOOL supportsForceTouch;
@property (nonatomic,strong) NSMutableDictionary *previews;
@property (nonatomic, strong) UIView *emptyView;
@end

@implementation ESIMSessionListViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        _previews = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //Temp
    self.navigationController.navigationBarHidden = NO;
    [self setUpNav];
    
    self.supportsForceTouch = [self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    self.emptyView.hidden = self.recentSessions.count;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)refresh{
    [super refresh];
    self.emptyView.hidden = self.recentSessions.count;
}

- (void)onSelectedRecent:(NIMRecentSession *)recent atIndexPath:(NSIndexPath *)indexPath{
    [ESNIMManager sharedManager].source = nil;
    ESIMSessionViewController *vc = [[ESIMSessionViewController alloc] initWithSession:recent.session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setUpNav{
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text =  SessionListTitle;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.0f];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [titleLabel sizeToFit];
    
    UIView *titleView = [[UIView alloc] init];
    CGRect frame = titleView.frame;
    frame.size.width = titleLabel.frame.size.width;
    frame.size.height = titleLabel.frame.size.height;
    titleView.frame = frame;
    
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
}

- (UIView *)emptyView {
    if (_emptyView == nil) {
        _emptyView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_emptyView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nodata_chat"]];
        [_emptyView addSubview:imageView];
        __block UIView *b_emptyView = _emptyView;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(121, 121));
            make.center.equalTo(b_emptyView).centerOffset(CGPointMake(0, -30));
        }];
        
        UILabel *textLabel = [[UILabel alloc] init];
        BOOL isLogin = [ESNIMManager sharedManager].isLogined;
        textLabel.text = isLogin ? @"暂时还没有会话哦~" : @"啊哦，出现错误了，请重新登录账号再试一下～";
        textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.0f];
        textLabel.textColor = [UIColor stec_grayTextColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        [_emptyView addSubview:textLabel];
        __block UIImageView *b_imageView = imageView;
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(b_emptyView.mas_left).with.offset(16);
            make.right.equalTo(b_emptyView.mas_right).with.offset(-16);
            make.height.equalTo(@(21));
            make.top.equalTo(b_imageView.mas_bottom).with.offset(8);
        }];
    }
    return _emptyView;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NIMRecentSession *recentSession = self.recentSessions[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SHAlertView showAlertWithTitle:@"提示" message:@"确认删除此会话吗?" sureKey:^{
            [self onDeleteRecentAtIndexPath:recentSession atIndexPath:indexPath];
        } cancelKey:nil];
    }
}
@end
