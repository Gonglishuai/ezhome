//
//  DesignItemLikeActionHelper.m
//  Homestyler
//
//  Created by Dong Shuyu on 04/10/18.
//
//

#import "DesignItemLikeActionHelper.h"

#import "ConfigManager.h"
#import "UserManager.h"

#import "HSAnimatingView.h"
#import "HSBrokenAnimatingView.h"

#import "FlurryDefs.h"

#import "NSString+Contains.h"

@interface DesignItemLikeActionHelper ()
@property (nonatomic, weak) DesignBaseClass * design;
@property (nonatomic, weak) UIButton * likeButton;
@property (nonatomic, weak) UIViewController * viewController;
@property (nonatomic, copy) PreDesignLikeBlock preActionBlock;
@property (nonatomic, copy) DesignLikeCompletionBlock completionBlock;
@end

@implementation DesignItemLikeActionHelper

- (void)toggleLikeStateForDesign:(nonnull DesignBaseClass *)design withLikeButton:(nonnull UIButton *)likeButton andViewController:(nonnull UIViewController *)viewController preActionBlock:(nullable PreDesignLikeBlock)preActionBlock completionBlock:(nullable DesignLikeCompletionBlock)completionBlock {
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        if (completionBlock != nil) {
            completionBlock(design._id, NO);
        }
        return;
    }

    self.design = design;
    self.likeButton = likeButton;
    self.viewController = viewController;
    self.completionBlock = completionBlock;

    if (self.likeImage == nil) {
        self.likeImage = [UIImage imageNamed:@"like"];
    }
    if (self.activeLikeImage == nil) {
        self.activeLikeImage = [UIImage imageNamed:@"like_active"];
    }

    if ([[UserManager sharedInstance] isLoggedIn]) {
        if (preActionBlock != nil) {
            preActionBlock();
        }
        [self likePressedWithAnimation];
    } else {
        self.preActionBlock = preActionBlock;
        __weak typeof(self) weakSelf = self;
        [[UserManager sharedInstance] showLoginFromViewController:viewController
                                                  eventLoadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_LIKE
                                                    preLoginBlock:^{
//                                                        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:
//                                                         @{EVENT_PARAM_SIGNUP_TRIGGER: EVENT_PARAM_VAL_LIKE_3D,
//                                                           EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_LIKE}];
                                                    }
                                                  completionBlock:^(BOOL success) {
                                                      if (success && weakSelf != nil) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (weakSelf == nil)
                                                                  return;

                                                              __strong typeof(self) strongSelf = weakSelf;
                                                              if (strongSelf.preActionBlock != nil) {
                                                                  strongSelf.preActionBlock();
                                                                  strongSelf.preActionBlock = nil;
                                                              }

                                                              [strongSelf likePressedWithAnimation];
                                                          });
                                                      }
                                                  }];
    }
}

- (void)likePressedWithAnimation {
    __weak typeof(self) weakSelf = self;

    BOOL isLiked = [self.design isUserLikesDesign];
    if (isLiked) {
        [self performUnlikeAnimation];
    } else {
        [self performLikeAnimation];
    }

    [self setLikeButtonImage:!isLiked];

    self.likeButton.userInteractionEnabled = NO;
    
    [[DesignsManager sharedInstance] likeDesign:self.design
                                               :!isLiked
                                               :self.viewController
                                               :NO
                            withCompletionBlock:^(id serverResponse) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (weakSelf == nil)
                                        return;

                                    __strong typeof(self) strongSelf = weakSelf;
                                    strongSelf.likeButton.userInteractionEnabled = YES;
                                    BOOL success = NO;
                                    if (serverResponse != nil) {
                                        success = ([(BaseResponse*)serverResponse errorCode] == -1);
                                        if (success) {
                                        } else {
                                            [strongSelf setLikeButtonImage:[strongSelf.design isUserLikesDesign]];
                                        }
                                    }
                                    if (strongSelf.completionBlock != nil) {
                                        strongSelf.completionBlock(strongSelf.design._id, success);
                                    }
                                });
                            }];
}

- (void)setLikeButtonImage:(BOOL)isLiked {
    if (self.likeButton == nil)
        return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.likeButton setImage:isLiked ? self.activeLikeImage : self.likeImage forState:UIControlStateNormal];
    });
}

- (void)performLikeAnimation {
    CGRect frame = self.likeButton.frame;
    CGFloat cx = CGRectGetMidX(frame);
    CGFloat cy = CGRectGetMidY(frame);
    CGSize sz = self.activeLikeImage.size;
    CGFloat w = sz.width * 1.4;
    CGFloat h = sz.height * 1.4;
    frame = CGRectMake(cx - w * 0.5, cy - h * 0.5, w, h);
    HSAnimatingView *animView = [[HSAnimatingView alloc] initWithFrame:frame andAnimationHeight:100];
    animView.image = self.activeLikeImage;
    [self.likeButton.superview addSubview:animView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [animView animate];
    });
}

-(void)performUnlikeAnimation {
    CGRect frame = self.likeButton.frame;
    CGFloat cx = CGRectGetMidX(frame);
    CGFloat cy = CGRectGetMidY(frame);
    CGSize sz = self.likeImage.size;
    CGFloat w = sz.width * 1.4;
    CGFloat h = w; // broken-heart image is square
    frame = CGRectMake(cx - w * 0.5, cy - h * 0.5, w, h);
    UIView *parentView = self.likeButton.superview;
    // TODO: [WORKAROUND] child view will be affected if the shadow opacity of parent view is less than 1.0
    if (parentView.layer.shadowOpacity != 1.0) {
        UIView *superView = parentView.superview;
        frame = [superView convertRect:frame fromView:parentView];
        parentView = superView;
    }
    HSBrokenAnimatingView *animView = [[HSBrokenAnimatingView alloc] initWithFrame:CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height) andBrokenAnimationBtn:frame];
    [parentView addSubview:animView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [animView animate];
    });
}

@end
