//
//  GalleryImageEmptyRoomCell.m
//  Homestyler
//
//  Created by Eric Dong on 05/04/2018.
//

#import "GalleryImageEmptyRoomCell.h"

static const CGFloat MARGIN_IPAD = 50;
static const CGFloat MARGIN_IPHONE = 20;
//static const CGFloat IMAGE_ASPECT_RATIO_IPAD = 9.0 / 16.0;
static const CGFloat IMAGE_ASPECT_RATIO_IPHONE = 3.0 / 4.0;

@implementation GalleryImageEmptyRoomCell
{
    __weak IBOutlet NSLayoutConstraint *_viewLeadingConstraint;
    __weak IBOutlet NSLayoutConstraint *_viewTrailingConstraint;
    __weak IBOutlet NSLayoutConstraint *_imageAspectRatioConstraint;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _viewLeadingConstraint.constant = IS_IPAD ? MARGIN_IPAD : MARGIN_IPHONE;
    _viewTrailingConstraint.constant = IS_IPAD ? -MARGIN_IPAD : -MARGIN_IPHONE;
    if (IS_IPHONE) {
        [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObjects:_imageAspectRatioConstraint, nil]];

        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:_imageAspectRatioConstraint.firstItem attribute:_imageAspectRatioConstraint.firstAttribute relatedBy:_imageAspectRatioConstraint.relation toItem:_imageAspectRatioConstraint.secondItem attribute:_imageAspectRatioConstraint.secondAttribute multiplier:IMAGE_ASPECT_RATIO_IPHONE constant:_imageAspectRatioConstraint.constant];
        [newConstraint setPriority:_imageAspectRatioConstraint.priority];
        newConstraint.shouldBeArchived = _imageAspectRatioConstraint.shouldBeArchived;
        newConstraint.identifier = _imageAspectRatioConstraint.identifier;
        newConstraint.active = true;

        [NSLayoutConstraint activateConstraints:[NSArray arrayWithObjects:newConstraint, nil]];
    }
}

@end
