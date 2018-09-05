//
//  HSAnimatingView.h
//  Homestyler
//
//  Created by Ma'ayan on 10/24/13.
//
//

#import <UIKit/UIKit.h>

@interface HSAnimatingView : UIImageView

- (id)initWithFrame:(CGRect)frame andAnimationHeight:(CGFloat)height;

- (void)animate;
- (void)reset;

@end
