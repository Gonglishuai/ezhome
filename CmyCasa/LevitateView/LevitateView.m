//
//  LevitateView.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 12/16/15.
//
//

#import "LevitateView.h"

@implementation LevitateView

-(instancetype)init{
    
    self = [super init];
    if (self) {
        [self setTag:10];
        [self setUserInteractionEnabled:YES];
        _image = [[UIImageView alloc] initWithFrame:self.bounds];
        [self touchDown];
        [self addSubview:_image];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTag:10];
        [self setUserInteractionEnabled:YES];
        _image = [[UIImageView alloc] initWithFrame:self.bounds];
        [self touchDown];
        [self addSubview:_image];
    }
    return self;
}

-(void)touchDown{
    NSString* strIcon = IS_IPAD ? @"lift" : @"lift";
    [_image setImage:[UIImage imageNamed:strIcon]];
}

-(void)touchUp{
    NSString* strIcon = IS_IPAD ? @"lift_pressed" : @"lift_pressed";
    [_image setImage:[UIImage imageNamed:strIcon]];
}

@end