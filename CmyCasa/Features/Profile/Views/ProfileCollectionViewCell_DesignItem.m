//
//  ProfileCollectionViewCell_DesignItem.m
//  EZHome
//
//  Created by xiefei on 5/3/18.
//

#import "ProfileCollectionViewCell_DesignItem.h"

#import "NSString+Contains.h"
#import "UIImageView+LoadImage.h"
#import "UIView+Border.h"

@interface ProfileCollectionViewCell_DesignItem () <UIGestureRecognizerDelegate>
{
    CGSize designImageSize;
}
@end

@implementation ProfileCollectionViewCell_DesignItem

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    designImageSize = CGSizeZero;

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnDesignImage:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self.designImageView addGestureRecognizer:tap];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetUI];
}

- (void)resetUI {
    designImageSize = CGSizeZero;
    self.designImageView.image = nil;
    self.designTag.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // load image when image view layout is done
    CGSize viewSize = CGSizeMake(self.designImageView.frame.size.width, self.designImageView.frame.size.height);
    if (!CGSizeEqualToSize(viewSize, designImageSize)) {
        designImageSize = viewSize;
        [self.designImageView loadImageFromUrl:self.designModel.url defaultImage:nil animated:YES completion:nil];
    }
}

- (void)setDesignModel:(MyDesignDO *)designModel {
    _designModel = designModel;
    [self refreshUI];
}

- (void)refreshUI {
    self.designTag.hidden = YES;
    if (STATUS_PUBLISHED == self.designModel.publishStatus) {
        self.designTag.hidden = NO;
        self.designTag.image = [UIImage imageNamed:@"tag_featured.png"];
    } else if (STATUS_PRIVATE == self.designModel.publishStatus) {
        self.designTag.hidden = NO;
        self.designTag.image = [UIImage imageNamed:@"tag_private.png"];
    }
}

- (void)tappedOnDesignImage:(UITapGestureRecognizer*)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(designPressed:)]) {
        [self.delegate designPressed:self.designModel];
    }
}

@end
