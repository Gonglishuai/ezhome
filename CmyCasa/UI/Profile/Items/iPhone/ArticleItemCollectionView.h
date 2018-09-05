//
//  ArticleItemView.h
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import <UIKit/UIKit.h>
//#import "GalleryItemDO.h"
#import "ArticleItemView.h"
@class GalleryItemDO;

//#define ARTICLE_ITEM_CELL_HEIGHT     316
//#define ARTICLE_ITEM_CELL_IDENTIFIER @"ArticleItemCell"


@interface ArticleItemCollectionView : UICollectionViewCell

@property (nonatomic, strong) GalleryItemDO* article;

@property (nonatomic, weak) id<ArticleItemDelegate> delegate;

@end
