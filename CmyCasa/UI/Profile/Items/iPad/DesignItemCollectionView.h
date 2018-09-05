//
//  DesignItemView.h
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import <UIKit/UIKit.h>
#import "DesignItemView.h"

@class MyDesignDO;

@interface DesignItemCollectionView : UICollectionViewCell <ProfileCellUnifiedInitProtocol>

@property (nonatomic, strong) MyDesignDO* design;
@property (nonatomic) BOOL isCurrentUserDesign;
@property (nonatomic, weak) id <DesignItemDelegate, LikeDesignDelegate, CommentDesignDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *autosaveLayer;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnLikeLiked;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (weak, nonatomic) IBOutlet UIImageView *ivFeatureBadge;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *designImage;
@property (weak, nonatomic) IBOutlet UIButton *ribbonButton;
@property (weak, nonatomic) IBOutlet UIView *statsContainer;


@end
