//
//  GalleryImageItemInfoCell.h
//  Homestyler
//
//  Created by Eric Dong on 05/04/2018.
//

#import <UIKit/UIKit.h>
#import "ProtocolsDef.h"

@class GalleryImageViewController;
@class DesignBaseClass;

@interface GalleryImageItemInfoCell : UITableViewCell
{
    DesignBaseClass * _itemDetail;
    
    __weak IBOutlet UIImageView *_designImage;
    __weak IBOutlet UILabel *_designTitle;
}

@property (weak, nonatomic) GalleryImageViewController * parentTableHolder;
@property (weak, nonatomic) id<GalleryImageDesignItemDelegate> delegate;

-(void)initData:(DesignBaseClass*)itemDetail;
-(void)getFullImage;
-(void)resetUI;

@end
