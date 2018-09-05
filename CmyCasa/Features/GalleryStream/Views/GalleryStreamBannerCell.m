//
//  GalleryStreamBannerCell.m
//  EZHome
//
//  Created by liuyufei on 4/18/18.
//

#import "GalleryStreamBannerCell.h"
#import "UIImageView+LoadImage.h"
#import "NSString+Contains.h"

@interface GalleryStreamBannerCell()

@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;

@end

@implementation GalleryStreamBannerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    self.bannerImage.frame = self.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.bannerImage.image = nil;
}

- (void)setBannerItem:(GalleryBanneItem *)bannerItem
{
    _bannerItem = bannerItem;
    [self.bannerImage loadImageFromUrl:self.bannerItem.image defaultImageName:(IS_IPAD ? @"banner_ipad" : @"banner_iphone")];
}

- (IBAction)openLink:(UIButton *)sender {
    if ([NSString isNullOrEmpty:self.bannerItem.link])
        return;

    if (self.delegate && [self.delegate respondsToSelector:@selector(openBannerLink:)])
    {
        NSRange range = [self.bannerItem.link rangeOfString:@"src="];
        NSString *url = [self.bannerItem.link substringFromIndex:range.location + 4];
        [self.delegate openBannerLink:url];
    }
}

@end
