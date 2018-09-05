//
//  ProfileMenuReusableView_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/29/13.
//
//

#import "ProfileMenuReusableView_iPhone.h"

@implementation ProfileMenuReusableView_iPhone

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.menuContainer=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.menuContainer setAutoresizingMask:    UIViewAutoresizingFlexibleLeftMargin  |
         UIViewAutoresizingFlexibleWidth|
         UIViewAutoresizingFlexibleRightMargin  |
         UIViewAutoresizingFlexibleTopMargin  |
         UIViewAutoresizingFlexibleHeight   |         UIViewAutoresizingFlexibleBottomMargin ];
        [self addSubview:self.menuContainer];
        
    }
    return self;
}

@end
