//
//  DesignItemView.h
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import <UIKit/UIKit.h>
//#import "MyDesignDO.h"
#import "DesignItemView.h"
@class MyDesignDO;

//#define DESIGN_ITEM_CELL_HEIGHT 316
//#define DESIGN_ITEM_CELL_IDENTIFIER @"DesignItemCell"

@interface DesignItemCollectionView : UICollectionViewCell

@property (nonatomic, strong) MyDesignDO* design;
@property (nonatomic)         BOOL        isCurrentUserDesign;

@property (nonatomic, weak) id<DesignItemDelegate> delegate;

@end
