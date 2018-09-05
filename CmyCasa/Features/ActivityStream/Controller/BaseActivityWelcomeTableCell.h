//
//  ActivityWelcomeTableCell.h
//  Homestyler
//
//  Created by Avihay Assouline on 1/6/14.
//
//

#import "BaseActivityTableCell.h"

@interface BaseActivityWelcomeTableCell : BaseActivityTableCell

@property (nonatomic, weak) IBOutlet UIImageView        *ivOwner;
@property (weak, nonatomic) IBOutlet UIImageView        *ivThumbnail;
@property (weak, nonatomic) IBOutlet UIButton           *btnThumbnail;
@property (weak, nonatomic) IBOutlet UILabel            *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel            *lblSubtitle;

@property (weak, nonatomic) IBOutlet UILabel            *lblHeartAndComment;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lblFavoriteProffesionals;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lblFavoriteArticles;
@property (weak, nonatomic) IBOutlet UILabel            *lblFollowFriends;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lblHelpArticle;
@property (weak, nonatomic) IBOutlet UILabel            *lblHappyHomestylering;

// Icons
@property (weak, nonatomic) IBOutlet UIImageView *ivHeartIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivFavoriteProfessionalsIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivFavoriteArticlesIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivFindFriendsIcon;
@property (weak, nonatomic) IBOutlet UIImageView *ivHelpIcon;


- (void)arrangeWelcomeMessageWithMargin:(CGFloat)bottomMargin;

- (void)cleanFields;

@end
