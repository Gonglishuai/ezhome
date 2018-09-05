//
//  HSBrokenAnimatingView.m
//  EZHome
//
//  Created by xiefei on 8/10/17.
//

#import "HSBrokenAnimatingView.h"

@interface HSBrokenAnimatingView ()
{
    CGRect currentFrame;
}

@end

@implementation HSBrokenAnimatingView

- (id)initWithFrame:(CGRect)frame andBrokenAnimationBtn:(CGRect)BtnFrame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        currentFrame = BtnFrame;
    }
    return self;
}

- (void)animate
{
    dispatch_async(dispatch_get_main_queue(), ^
   {
       CGRect frameLeft = CGRectMake(currentFrame.origin.x - 10, currentFrame.origin.y - 80, currentFrame.size.width, currentFrame.size.height);
       CGRect frameRight = CGRectMake(currentFrame.origin.x + 10, currentFrame.origin.y - 80, currentFrame.size.width, currentFrame.size.height);
       CGRect position = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + 20, currentFrame.size.width, currentFrame.size.height);
       
       UIImageView *left = [[UIImageView alloc] initWithFrame:frameLeft];
       UIImageView *right = [[UIImageView alloc] initWithFrame:frameRight];

       [self addSubview:left];
       [self addSubview:right];
       
       left.image = [UIImage imageNamed:@"like_brokenheart_left"];
       right.image = [UIImage imageNamed:@"like_brokenheart_right"];
       
       [UIView animateWithDuration:0.8f animations:^{
           left.frame = position;
           right.frame = position;
           left.transform = CGAffineTransformMakeRotation (-M_PI_2);
           right.transform = CGAffineTransformMakeRotation (M_PI_2);
           left.alpha = 0;
           right.alpha = 0;
       }completion:^(BOOL finished) {
           left.alpha = 1;
           right.alpha = 1;
           [self removeFromSuperview];
       }];
   });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
