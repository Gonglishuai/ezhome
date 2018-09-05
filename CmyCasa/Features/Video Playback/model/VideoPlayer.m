//
// Created by Berenson Sergei on 3/4/14.
// Copyright (c) 2014 SB Tech. All rights reserved.
//



#import "VideoPlayer.h"
#import "MPMoviePlayerWrapperViewController.h"

@interface VideoPlayer ()


@end
@implementation VideoPlayer


- (void)prepareVideoPlaybackForURL:(NSURL *)path withViewOwner:(UIView *)owner andRectSize:(CGRect)size
{

    [self releasePreviosPlaybackIfExists];
   // UIGraphicsBeginImageContext(CGSizeMake(1,1));
   // self.playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:path];
    
    self.moviePlayer = [[MPMoviePlayerWrapperViewController alloc] initWithContentURL:path];
    //self.playerController.view.frame = size;
   
    //self.moviePlayer.view.frame = size;
    [self.moviePlayer.moviePlayer prepareToPlay];
    [self.moviePlayer.moviePlayer play];
    //UIGraphicsEndImageContext();
}

- (MPMoviePlayerViewController*)getVideoPlayerController
{
    return self.moviePlayer;
}

- (void)startVideoPlayback:(NSTimeInterval)videoPlaybackLimit videoOffset:(NSInteger)videoOffset {

     //[self.moviePlayer.moviePlayer setFullscreen:YES animated:NO];
   // 4 - Register for the playback finished notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer.moviePlayer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieExitFullScreenCallback:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification object:self.moviePlayer.moviePlayer];
    
    
    
}
- (void)myMovieExitFullScreenCallback:(id)myMovieFinishedCallback {
    [self clearVideo:myMovieFinishedCallback];
}
- (void)myMovieFinishedCallback:(id)myMovieFinishedCallback {
    [self clearVideo:myMovieFinishedCallback];
}

- (void)clearVideo:(id)sender
{
    [self.moviePlayer.moviePlayer pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.moviePlayer.moviePlayer stop];
    
    self.moviePlayer = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoDonePressed)])
    {
        [self.delegate videoDonePressed];
    }
}

- (void)releasePreviosPlaybackIfExists
{

//    if (self.playerController)
//    {
//       // [self.playerController pause];
//        [self.playerController dismissViewControllerAnimated:YES completion:^{
//            [[NSNotificationCenter defaultCenter] removeObserver:self  name:MPMoviePlayerPlaybackDidFinishNotification object:self.playerController];
//
//        }];
//        self.playerController = nil;
//
//    }
}
@end