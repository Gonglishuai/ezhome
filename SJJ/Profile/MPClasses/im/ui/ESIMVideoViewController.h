//
//  ESIMVideoViewController.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <NIMSDK/NIMSDK.h>

@interface ESIMVideoViewController : UIViewController
- (instancetype)initWithVideoObject:(NIMVideoObject *)videoObject;

@property (nonatomic, readonly) MPMoviePlayerController *moviePlayer;
@end
