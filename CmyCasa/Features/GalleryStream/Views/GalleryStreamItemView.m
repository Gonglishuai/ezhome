//
//  GalleryStreamItemView.m
//  EZHome
//
//  Created by liuyufei on 4/18/18.
//

#import "GalleryStreamItemView.h"

#import "NSString+Time.h"
#import "NSString+Contains.h"
#import "NSString+FormatNumber.h"
#import "UIImageView+LoadImage.h"
#import "UIImageView+ViewMasking.h"
#import "UIView+Border.h"

static const NSInteger DESCRIPTION_MAX_LINES = 4;

@interface GalleryStreamItemView()

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateTime;

@property (weak, nonatomic) IBOutlet UIImageView *designImage;

@property (weak, nonatomic) IBOutlet UILabel *designTitle;
@property (weak, nonatomic) IBOutlet UILabel *designDescription;

@property (weak, nonatomic) IBOutlet UIView *bgViewForTouch;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UIButton *like;

@end

@implementation GalleryStreamItemView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.avatar setMaskToCircleWithBorderWidth:1.0f andColor:[UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0]];

    UITapGestureRecognizer *profileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile)];
    [self.topBar addGestureRecognizer:profileTap];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNothing)];
    [self.bgViewForTouch addGestureRecognizer:tap];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.avatar.image = nil;
    self.designImage.image = nil;
    self.like.userInteractionEnabled = YES;
    [self reloadUI];
}

- (void)setItem:(GalleryItemDO *)item
{
    if (!item)
        return;
    _item = item;
    self.author.text = item.author;
    self.lastUpdateTime.text = [item.timestamp smartTime];
    self.designTitle.text = item.title;
    self.commentsCount.text = [NSString formatNumber:item.commentsCount.integerValue];
    self.likeCount.text = [NSString formatNumber:item.tempLikeCount.integerValue];
    self.designDescription.text = [item._description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self setLikeButtonImage:[item isUserLikesDesign]];
    self.avatar.image = [UIImage imageNamed:@"user_avatar"];
    [self.avatar loadImageFromUrl:item.uthumb defaultImage:nil];
    [self.designImage loadImageFromUrl:item.url defaultImage:nil animated:YES completion:nil];
}

+ (CGFloat)calcDesignDescrtiptionTextHeightForDesign:(GalleryItemDO *)item cellWidth:(CGFloat)width {
    NSString *text = [item._description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([NSString isNullOrEmpty:text])
        return 0;

    const CGFloat margin = 12;
    const CGFloat spacing = 10;

    width -= 2 * margin;

    // NOTE: use the font with style settings for this label
    UIFont * font = [UIFont fontWithName:@".SFUIText-Light" size:14]; // Text_Body3_Light in nss

    CGFloat maxLines = DESCRIPTION_MAX_LINES;
    CGSize maxSize = CGSizeMake(width, font.lineHeight * maxLines);
    CGRect textRect = [text boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];

    return ceil(textRect.size.height + spacing);
}

- (void)toggleLikeState {
    int likesCount = [self.item getLikesCountForDesign];
    likesCount += [self.item isUserLikesDesign] ? -1 : 1;
    [self setLikeCountNumber:likesCount];
}

- (void)setLikeCountNumber:(int)likeCountNum {
    self.likeCount.text = [NSString formatNumber:likeCountNum];
}

- (void)restoreLikeState {
    [self setLikeCountNumber:[self.item getLikesCountForDesign]];
    [self setLikeButtonImage:[self.item isUserLikesDesign]];
}

- (void)setLikeButtonImage:(BOOL)isLiked {
    if (self.like == nil)
        return;
    [self.like setImage:[UIImage imageNamed:isLiked ? @"like_active" : @"like"] forState:UIControlStateNormal];
}

- (void)doNothing {

}

- (void)showDesignDetail
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(designPressed:)]) {
        [self.delegate designPressed:self.item];
    }
}

- (void)showProfile
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(showUserProfile:)]) {
        [self.delegate showUserProfile:self.item.uid];
    }
}

- (void)updateLikeStatus
{
    [self restoreLikeState];
}

- (void)updateCommentsCount
{
    self.commentsCount.text = [NSString formatNumber:self.item.commentsCount.integerValue];
}

- (IBAction)comments:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(designPressed:)]) {
        [self.delegate designPressed:self.item];
    }
}

- (IBAction)share:(UIButton *)sender {
    if (self.designImage.image == nil || self.item == nil)
        return;

    if (self.delegate && [self.delegate respondsToSelector:@selector(shareDesign:withDesignImage:)]) {
        [self.delegate shareDesign:self.item withDesignImage:self.designImage.image];
    }
}

- (IBAction)like:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toggleLikeStateForDesign: withLikeButton: preActionBlock: completionBlock:)]) {
        __weak typeof(self) weakSelf = self;
        [self.delegate toggleLikeStateForDesign:self.item
                                 withLikeButton:sender
                                 preActionBlock:^{
                                     if (weakSelf != nil) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [weakSelf toggleLikeState];
                                         });
                                     }
                                 }
                                completionBlock:^(NSString* designId, BOOL success) {
                                    if (weakSelf != nil) {
                                        __strong typeof(self) strongSelf = weakSelf;
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (success) {
                                            } else  {
                                                [strongSelf restoreLikeState];
                                            }
                                        });
                                    }
                                }];
    }
}

@end
