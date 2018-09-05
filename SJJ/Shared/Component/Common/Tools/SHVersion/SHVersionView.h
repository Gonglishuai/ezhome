//
//  SHVersionView.h
//  Consumer
//
//  Created by 牛洋洋 on 2017/4/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SHVersionViewType)
{
    SHVersionViewTypeUnknow = 0,
    SHVersionViewTypeClose,
    SHVersionViewTypeCompulsion,
};

@protocol SHVersionViewDelegate <NSObject>

- (void)versionVewUpdateButtonDidTapped:(NSString *)downloadUrl;

- (void)versionVewCloseButtonDidTapped;

@end

@interface SHVersionView : UIView

+ (void)showVersionViewWithType:(SHVersionViewType)type
                   releaseNotes:(NSArray *)releaseNotes
                    downloadUrl:(NSString *)downloadUrl
                       callback:(void(^)(BOOL isClose,
                                         NSString *downloadUrl))callback;

@end
