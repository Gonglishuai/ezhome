//
//  DesignItemLikeActionHelper.h
//  Homestyler
//
//  Created by Dong Shuyu on 04/10/18.
//
//

#import <UIKit/UIKit.h>
#import "ProfileProtocols.h"

@interface DesignItemLikeActionHelper : NSObject

@property (nonatomic, strong) UIImage * likeImage;
@property (nonatomic, strong) UIImage * activeLikeImage;

- (void)toggleLikeStateForDesign:(nonnull DesignBaseClass *)design
                  withLikeButton:(nonnull UIButton *)likeButton
               andViewController:(nonnull UIViewController *)viewController
                  preActionBlock:(nullable PreDesignLikeBlock)preActionBlock
                 completionBlock:(nullable DesignLikeCompletionBlock)completion;

@end
