//
// Created by Berenson Sergei on 3/4/14.
// Copyright (c) 2014 SB Tech. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>



@protocol VideoPlayerDelegate <NSObject>

- (void)videoDonePressed;

@end

@interface VideoPlayer : NSObject

@property (nonatomic,strong) id<VideoPlayerDelegate> delegate;
@property(nonatomic, strong) MPMoviePlayerViewController *moviePlayer;

- (void)prepareVideoPlaybackForURL:(NSURL *)path withViewOwner:(UIView *)owner andRectSize:(CGRect)size;

- (MPMoviePlayerViewController *)getVideoPlayerController;

- (void)startVideoPlayback:(NSTimeInterval)videoPlaybackLimit videoOffset:(NSInteger)videoOffset;

- (void)releasePreviosPlaybackIfExists;
@end