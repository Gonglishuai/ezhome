//
//  GalleryStreamEmptyRoomCell.h
//  Homestyler
//
//  Created by liuyufei on 4/27/18.
//

#import <UIKit/UIKit.h>

@interface GalleryStreamEmptyRoomCell : UICollectionViewCell

@property (nonatomic, strong) GalleryItemDO *item;
@property (nonatomic, weak) id<DesignItemDelegate> delegate;

@end
