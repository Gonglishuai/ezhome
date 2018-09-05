//
//  GalleryStreamEmptyCell.h
//  Homestyler
//
//  Created by liuyufei on 5/9/18.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, GalleryStreamEmptyType)
{
    GalleryStreamEmptyNotSignIn = 0,
    GalleryStreamEmptyNoFollowing,
    GalleryStreamEmptyNoDesign,
    GalleryStreamEmptyNoEmptyRoom
};

@protocol GalleryStreamEmptyCellDelegate <NSObject>

@optional

- (void)signIn;

@end

@interface GalleryStreamEmptyCell : UICollectionViewCell

@property (nonatomic, assign) GalleryStreamEmptyType emptyType;
@property (nonatomic, weak) id<GalleryStreamEmptyCellDelegate> delegate;

@end
