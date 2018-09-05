//
//  SHVersionView.m
//  Consumer
//
//  Created by 牛洋洋 on 2017/4/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "SHVersionView.h"
#import "SHVersionNoteCell.h"

@interface SHVersionView ()<UITableViewDelegate, UITableViewDataSource, SHVersionNoteCellDelagate>

@property (weak, nonatomic) IBOutlet UITableView *versionTableView;
@property (weak, nonatomic) IBOutlet UIButton *versionCloseButton;
@property (weak, nonatomic) IBOutlet UIView *versionBackgroundView;

@property (nonatomic, copy) void (^callback)(BOOL isClose, NSString *downloadUrl);

@end

@implementation SHVersionView
{
    NSArray *_releaseNotes;
    NSString *_downloadUrl;
    SHVersionViewType _versionType;
    
    SHVersionView *_versionView;
    UIView *_backgroundBlackView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _versionType = SHVersionViewTypeUnknow;
    
    self.versionBackgroundView.clipsToBounds = YES;
    self.versionBackgroundView.layer.cornerRadius = 6.0f;
    
    [self.versionTableView registerNib:[UINib nibWithNibName:@"SHVersionNoteCell" bundle:nil]
                forCellReuseIdentifier:@"SHVersionNoteCell"];
    self.versionTableView.estimatedRowHeight = 20.0f;
    self.versionTableView.rowHeight = UITableViewAutomaticDimension;
    self.versionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 创建背景遮罩
    _backgroundBlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _backgroundBlackView.alpha = 0.01f;
    _backgroundBlackView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:_backgroundBlackView];
}

- (IBAction)versionUpdateButtonDidTapped:(id)sender
{
    if (_versionType == SHVersionViewTypeClose)
    {
        [_versionView removeFromSuperview];
        [_backgroundBlackView removeFromSuperview];
    }
    if (self.callback)
        self.callback(NO, _downloadUrl);
}

- (IBAction)versionCloseButtonDidTapped:(id)sender
{
    // 动画关闭view.
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         _versionView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
         _backgroundBlackView.alpha = 0.01;
         
     } completion:^(BOOL finished) {
         [_versionView removeFromSuperview];
         [_backgroundBlackView removeFromSuperview];
     }];
    
    if (self.callback)
        self.callback(YES, nil);
}

- (void)showVersionView:(SHVersionView *)view
                   type:(SHVersionViewType)type
           releaseNotes:(NSArray *)releaseNotes
            downloadUrl:(NSString *)downloadUrl
               callback:(void(^)(BOOL isClose,
                                 NSString *downloadUrl))callback
{
    _versionView = view;
    _downloadUrl = downloadUrl;
    _releaseNotes = releaseNotes;
    _callback = callback;
    _versionType = type;
    
    if (type == SHVersionViewTypeUnknow
        || !_releaseNotes
        || ![_releaseNotes isKindOfClass:[NSArray class]])
    {
        [_backgroundBlackView removeFromSuperview];
        return ;
    }
    
    BOOL hideCloseButton = (type == SHVersionViewTypeCompulsion);
    self.versionCloseButton.hidden = hideCloseButton;
    
    view.frame = CGRectMake(0, SCREEN_HEIGHT, 1, 1);
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view layoutIfNeeded];
    
    // 动画展示view.
    [UIView animateWithDuration:0.8f
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
    {
        [_versionView layoutIfNeeded];
        _versionView.frame = [UIScreen mainScreen].bounds;
        _backgroundBlackView.alpha = 0.5;
        
    } completion:nil];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _releaseNotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SHVersionNoteCell";
    SHVersionNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                              forIndexPath:indexPath];
    cell.cellDelegate = self;
    [cell updateVersionCellAtIndex:indexPath.row];
    return cell;
}

#pragma mark - SHVersionNoteCellDelagate
- (NSString *)getVersionNoteAtIndex:(NSInteger)index
{
    return _releaseNotes[index];
}

#pragma mark - Public Mehods
+ (void)showVersionViewWithType:(SHVersionViewType)type
                   releaseNotes:(NSArray *)releaseNotes
                    downloadUrl:(NSString *)downloadUrl
                       callback:(void(^)(BOOL isClose,
                                         NSString *downloadUrl))callback
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SHVersionView"
                                                   owner:self
                                                 options:nil];
    SHVersionView *view = [array firstObject];
    [view showVersionView:view
                     type:type
             releaseNotes:releaseNotes
              downloadUrl:downloadUrl
                 callback:callback];
}

@end
