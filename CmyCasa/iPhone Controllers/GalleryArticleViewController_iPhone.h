//
//  ProgressPopupBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/22/13.
//
//

#import "GalleryArticleBaseViewController.h"

@interface GalleryArticleViewController_iPhone : GalleryArticleBaseViewController

@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButtonLiked;
@property (strong, nonatomic) IBOutlet UIView * bottomBarView;
@property (nonatomic) BOOL hideBottomBarView;
@property (nonatomic) BOOL isCommentsPresented;
@property (nonatomic) BOOL openCommentsRequested;

-(IBAction)likeAction:(id)sender;
@end
