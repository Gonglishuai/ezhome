//
//  ESIMVideoViewController.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESIMVideoViewController.h"
#import "UIView+Toast.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "ESNavigationHandler.h"
#import "Masonry.h"

@interface ESIMVideoViewController ()
@property (nonatomic,strong) NIMVideoObject *videoObject;
@property (nonatomic, strong) UIImageView *playImgView;
@end

@implementation ESIMVideoViewController
@synthesize moviePlayer = _moviePlayer;

- (instancetype)initWithVideoObject:(NIMVideoObject *)videoObject{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _videoObject = videoObject;
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].resourceManager cancelTask:_videoObject.path];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.navigationItem.title = @"视频";
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoObject.path]) {
        [self startPlay];
    }else{
        __weak typeof(self) wself = self;
        [self downLoadVideo:^(NSError *error) {
            if (!error) {
                [wself startPlay];
            }else{
                [wself.view makeToast:@"下载失败，请检查网络"
                             duration:2
                             position:CSToastPositionCenter];
            }
        }];
    }
    
    WS(weakSelf);
    self.playImgView = [[UIImageView alloc] init];
    self.playImgView.image = [UIImage imageNamed:@"im_video_play"];
    [self.view addSubview:self.playImgView];
    [self.playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (![[self.navigationController viewControllers] containsObject: self])
    {
        [self topStatusUIHidden:NO];
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.moviePlayer stop];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    if (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {//不要调用.get方法，会过早的初始化播放器
        [self topStatusUIHidden:YES];
    }else{
        [self topStatusUIHidden:NO];
    }
}



- (void)downLoadVideo:(void(^)(NSError *error))handler{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].resourceManager download:self.videoObject.url filepath:self.videoObject.path progress:^(float progress) {
        hud.progress = progress;
    } completion:^(NSError *error) {
        if (wself) {
            [hud hideAnimated:YES];
            if (handler) {
                handler(error);
            }
        }
    }];
}




- (void)startPlay{
    self.moviePlayer.view.frame = self.view.bounds;
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.moviePlayer play];
    [self.view addSubview:self.moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackComplete:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.moviePlayer];
    
    
    CGRect bounds = self.moviePlayer.view.bounds;
    CGRect tapViewFrame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    UIView *tapView = [[UIView alloc]initWithFrame:tapViewFrame];
    [tapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    tapView.backgroundColor = [UIColor clearColor];
    [self.moviePlayer.view addSubview:tapView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
    [tapView  addGestureRecognizer:tap];
}

- (void)moviePlaybackComplete: (NSNotification *)aNotification
{
    if (self.moviePlayer == aNotification.object)
    {
        [self topStatusUIHidden:NO];
        NSDictionary *notificationUserInfo = [aNotification userInfo];
        NSNumber *resultValue = [notificationUserInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        MPMovieFinishReason reason = [resultValue intValue];
        if (reason == MPMovieFinishReasonPlaybackError)
        {
            NSError *mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
            NSString *errorTip = [NSString stringWithFormat:@"播放失败: %@", [mediaPlayerError localizedDescription]];
            [self.view makeToast:errorTip
                        duration:2
                        position:CSToastPositionCenter];
        }
    }
    
}

- (void)moviePlayStateChanged: (NSNotification *)aNotification
{
    if (self.moviePlayer == aNotification.object)
    {
        switch (self.moviePlayer.playbackState)
        {
            case MPMoviePlaybackStatePlaying:
                [self topStatusUIHidden:YES];
                break;
            case MPMoviePlaybackStatePaused:
            case MPMoviePlaybackStateStopped:
            case MPMoviePlaybackStateInterrupted:
                [self topStatusUIHidden:NO];
            case MPMoviePlaybackStateSeekingBackward:
            case MPMoviePlaybackStateSeekingForward:
                break;
        }
        
    }
}

- (void)topStatusUIHidden:(BOOL)isHidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:isHidden];
    self.navigationController.navigationBar.hidden = isHidden;
    self.playImgView.hidden = isHidden;
    ESNavigationHandler *handler = (ESNavigationHandler *)self.navigationController.delegate;
    handler.recognizer.enabled = !isHidden;
}

- (void)onTap: (UIGestureRecognizer *)recognizer
{
    switch (self.moviePlayer.playbackState)
    {
        case MPMoviePlaybackStatePlaying:
            [self.moviePlayer pause];
            break;
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStateInterrupted:
            [self.moviePlayer play];
            break;
        default:
            break;
    }
}


- (MPMoviePlayerController*)moviePlayer{
    if (!_moviePlayer) {
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.videoObject.path]];
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayer.fullscreen = YES;
    }
    return _moviePlayer;
}


@end
