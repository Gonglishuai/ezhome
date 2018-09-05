//
//  GalleryStreamEmptyCell.m
//  Homestyler
//
//  Created by liuyufei on 5/9/18.
//

#import "GalleryStreamEmptyCell.h"

@interface GalleryStreamEmptyCell()

@property (weak, nonatomic) IBOutlet UIImageView *emptyImageView;
@property (weak, nonatomic) IBOutlet UILabel *emptyText;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTextSpacing;

@end

@implementation GalleryStreamEmptyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.signInButton setTitle:NSLocalizedString(@"sign_in", @"Sign In") forState:UIControlStateNormal];
}

- (void)setEmptyType:(GalleryStreamEmptyType)emptyType
{
    _emptyType = emptyType;
    self.signInButton.hidden = YES;
    switch (emptyType) {
        case GalleryStreamEmptyNotSignIn:
        {
            self.emptyText.text = NSLocalizedString(@"not_sign_in", nil);
            self.emptyImageView.image = (IS_IPAD ? [UIImage imageNamed:@"not_signIn_ipad"] : [UIImage imageNamed:@"not_signIn_mobile"]);
            self.signInButton.hidden = NO;
            self.imageTextSpacing.constant = 25;
            break;
        }

        case GalleryStreamEmptyNoFollowing:
        {
            self.emptyText.text = NSLocalizedString(@"no_following", nil);
            self.emptyImageView.image = [UIImage imageNamed:@"cat"];
            self.imageTextSpacing.constant = 25;
            break;
        }

        case GalleryStreamEmptyNoDesign:
        {
            self.emptyText.text = NSLocalizedString(@"No designs yet", nil);
            self.emptyImageView.image = [UIImage imageNamed:@"no_designs"];
            self.imageTextSpacing.constant = 15;
            break;
        }
        case GalleryStreamEmptyNoEmptyRoom:
        {
            self.emptyText.text = NSLocalizedString(@"No empty rooms yet", nil);
            self.emptyImageView.image = [UIImage imageNamed:@"no_designs"];
            self.imageTextSpacing.constant = 15;
            break;
        }
    }
}

#pragma mark - Action
- (IBAction)signIn:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(signIn)])
    {
        [self.delegate signIn];
    }
}


@end
