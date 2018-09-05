//
//  ArticleItemView.h
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import <UIKit/UIKit.h>
#import "GalleryItemDO.h"
#import "ProfilePageBaseViewController.h"
#import "ProfileProtocols.h"

#define ARTICLE_ITEM_CELL_HEIGHT     300
#define ARTICLE_ITEM_CELL_IDENTIFIER @"ArticleItemCell"

@interface ArticleItemView : UITableViewCell<ProfileCellUnifiedInitProtocol>

@property (nonatomic, strong) GalleryItemDO* article;

@property (nonatomic, weak) id <ArticleItemDelegate, LikeDesignDelegate, CommentDesignDelegate> delegate;

@end
