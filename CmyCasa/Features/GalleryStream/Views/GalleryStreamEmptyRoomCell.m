//
//  GalleryStreamEmptyRoomCell.m
//  Homestyler
//
//  Created by liuyufei on 4/27/18.
//

#import "GalleryStreamEmptyRoomCell.h"
#import "UIImageView+LoadImage.h"
#import "UIView+ReloadUI.h"
#import "UIView+Border.h"

@interface GalleryStreamEmptyRoomCell ()

@property (weak, nonatomic) IBOutlet UIImageView *emptyRoomImg;

@end

@implementation GalleryStreamEmptyRoomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    self.emptyRoomImg.frame = self.bounds;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.emptyRoomImg.image = nil;
}

- (void)setItem:(GalleryItemDO *)item
{
    if (!item)
        return;

    _item = item;
    [self.emptyRoomImg loadImageFromUrl:item.url defaultImage:nil animated:YES completion:nil];
}

@end
