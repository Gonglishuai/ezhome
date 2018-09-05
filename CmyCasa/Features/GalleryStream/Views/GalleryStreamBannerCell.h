//
//  GalleryStreamBannerCell.h
//  EZHome
//
//  Created by liuyufei on 4/18/18.
//

#import <UIKit/UIKit.h>

@protocol GalleryStreamBannerCellDelegate <NSObject>

- (void)openBannerLink:(NSString *)bannerUrl;

@end

@interface GalleryStreamBannerCell : UICollectionViewCell

@property (nonatomic, strong) GalleryBanneItem *bannerItem;
@property (nonatomic, weak) id <GalleryStreamBannerCellDelegate> delegate;

@end
