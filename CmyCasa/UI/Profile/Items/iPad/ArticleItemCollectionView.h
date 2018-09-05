//
//  ArticleItemView.h
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import <UIKit/UIKit.h>
#import "ArticleItemView.h"
#import "ProfileProtocols.h"

@class GalleryItemDO;

@interface ArticleItemCollectionView : UICollectionViewCell<ProfileCellUnifiedInitProtocol>

@property (nonatomic, strong) GalleryItemDO* article;
@property (nonatomic, weak) id<ArticleItemDelegate, LikeDesignDelegate,CommentDesignDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton   *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnLikeLiked;
@property (weak, nonatomic) IBOutlet UILabel    *lblLikeCount;
@property (weak, nonatomic) IBOutlet UIButton   *btnComment;
@property (weak, nonatomic) IBOutlet UILabel    *lblCommentCount;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@end
