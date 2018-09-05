//
//  ProfileCollectionViewHeader.m
//  EZHome
//
//  Created by xiefei on 5/3/18.
//

#import "ProfileCollectionViewHeader.h"

@interface ProfileCollectionViewHeader()
@property (weak, nonatomic) IBOutlet UIButton *designsButton;
@property (weak, nonatomic) IBOutlet UIButton *featuredButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *underlineCenterXConstraint;
@end


@implementation ProfileCollectionViewHeader

- (void)awakeFromNib {
    [super awakeFromNib];

    self.designsButton.selected = YES;
}

- (void)setDesignsCount:(NSInteger)count {
    NSString * title = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"profile_tab_design", @"Designs"), count];
    [self.designsButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Action

- (IBAction)changeViewDataType:(UIButton *)sender {
    if (sender == nil || sender.selected)
        return;

    CGFloat srcX = 0;
    CGFloat dstX = srcX;

    self.designsButton.selected = sender == self.designsButton;
    self.featuredButton.selected = sender == self.featuredButton;

    ProfileViewDataType dataType = DesignsData;
    if (sender == self.designsButton) {
        dataType = DesignsData;
        dstX = self.designsButton.frame.origin.x + self.designsButton.frame.size.width * 0.5;
    } else if (sender == self.featuredButton) {
        dataType = FeaturedData;
        dstX = self.featuredButton.frame.origin.x + self.featuredButton.frame.size.width * 0.5;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(setViewDataType:)]) {
        [self.delegate setViewDataType:self.designsButton.selected ? DesignsData : FeaturedData];
    }

    self.underlineCenterXConstraint.constant = dstX - srcX;

    [UIView animateWithDuration:0.25f animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

@end
