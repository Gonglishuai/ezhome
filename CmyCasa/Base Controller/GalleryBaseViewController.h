//
//  GalleryBaseViewController.h
//  Homestyler
//
//  Created by xiefei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    APP_SJJ = 0,
    APP_DIY,
} ESAppState;

@protocol GalleryBaseDelegate <NSObject>
-(void)changeApp:(ESAppState)state;
@end

@interface GalleryBaseViewController : UIViewController
@property (nonatomic,weak) id <GalleryBaseDelegate>delegate;
@end
