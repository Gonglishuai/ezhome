//
//  HSFollowButton.m
//  Homestyler
//
//  Created by Eric Dong on 05/09/18.
//

#import "HSFollowButton.h"


@interface HSFollowButton()

@property (strong, nonatomic) NSString * followButtonTitle;
@property (strong, nonatomic) UIImage * followedImage;

@end

@implementation HSFollowButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self commonInit];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.followButtonTitle = NSLocalizedString(@"follow", @"Follow");
    self.followedImage = [UIImage imageNamed:@"profile_followed"];
    [self setTitle:self.followButtonTitle forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateNormal];
    [self setTitle:nil forState:UIControlStateSelected];
}

- (void)setIsFollowed:(BOOL)isFollowed {
    if (_isFollowed == isFollowed)
        return;

    if (_isFollowing) {
        [self setTitle:nil forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateSelected];
        return;
    }

    _isFollowed = isFollowed;

    if (_isFollowed) {
        self.selected = YES;
        [self setTitle:nil forState:UIControlStateNormal];
        [self setImage:self.followedImage forState:UIControlStateSelected];
    } else {
        self.selected = NO;
        [self setTitle:self.followButtonTitle forState:UIControlStateNormal];
    }
}

- (void)setIsFollowing:(BOOL)isFollowing {
    if (_isFollowing == isFollowing)
        return;

    _isFollowing = isFollowing;
    self.userInteractionEnabled = !_isFollowing;

    BOOL prevState = _isFollowed;
    _isFollowed = !_isFollowed;
    self.isFollowed = prevState;
}

@end
