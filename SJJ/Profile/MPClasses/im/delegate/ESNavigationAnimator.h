//
//  ESSubscribeManager.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ESNavigationAnimationType) {
    NTESNavigationAnimationTypeNormal,
    NTESNavigationAnimationTypeCross,
};

@class ESNavigationAnimator;

@protocol ESNavigationAnimatorDelegate <NSObject>

- (void)animationWillStart:(ESNavigationAnimator *)animator;

- (void)animationDidEnd:(ESNavigationAnimator *)animator;

@end


@interface ESNavigationAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic,weak)   UINavigationController *navigationController;

@property (nonatomic,assign) UINavigationControllerOperation currentOpearation;

@property (nonatomic,assign) ESNavigationAnimationType animationType;

@property (nonatomic,weak) id<ESNavigationAnimatorDelegate> delegate;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end
