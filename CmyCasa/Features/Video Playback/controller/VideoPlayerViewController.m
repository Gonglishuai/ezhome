//
//  VideoPlayerViewController.m
//  Videodate
//
//  Created by Berenson Sergei on 3/7/14.
//  Copyright (c) 2014 SB Tech. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "VideoPlayer.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

+ (VideoPlayerViewController*)newPlayer
{
    
    VideoPlayerViewController * playerVC;
    
    if (IS_IPAD) {
        playerVC = [[VideoPlayerViewController alloc] initWithNibName:@"VideoPlayerViewController_iPad" bundle:nil];
        
    }else{
        playerVC = [[VideoPlayerViewController alloc] initWithNibName:@"VideoPlayerViewController_iPhone" bundle:nil];
    }
    
    return playerVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performSelector:@selector(initializeVideo) withObject:nil afterDelay:0.1];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark Video Actions
-(void)initializeVideo
{
    if (self.vPlayer) {
        [self.vPlayer releasePreviosPlaybackIfExists];
        self.vPlayer = nil;
    }
    
    self.vPlayer = [VideoPlayer  new];
    self.vPlayer.delegate = self;
    
    
    [self.vPlayer prepareVideoPlaybackForURL:self.videoPathURL withViewOwner:self.view andRectSize:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    MPMoviePlayerViewController *mpmpvc = [self.vPlayer getVideoPlayerController];
    
    // 3 - Play the video
    [self presentMoviePlayerViewControllerAnimated:mpmpvc];
    
    [self.vPlayer startVideoPlayback:0 videoOffset:0];
}

- (void)videoDonePressed
{
    [self closeVideoPlayback:nil];
}

- (void)closeVideoPlayback:(id)sender
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end
