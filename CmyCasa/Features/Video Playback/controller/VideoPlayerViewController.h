//
//  VideoPlayerViewController.h
//  Videodate
//
//  Created by Berenson Sergei on 3/7/14.
//  Copyright (c) 2014 SB Tech. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "VideoPlayer.h"


@interface VideoPlayerViewController : UIViewController <VideoPlayerDelegate>


@property(nonatomic, strong) VideoPlayer *vPlayer;
@property(nonatomic, strong) NSURL * videoPathURL;

- (void)closeVideoPlayback:(id)sender;
+ (VideoPlayerViewController*)newPlayer;

@end
